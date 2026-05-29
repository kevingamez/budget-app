package com.kevingamez.debttracker.security

import android.content.Context
import android.database.Cursor
import android.util.Log
import net.sqlcipher.database.SQLiteDatabase
import java.io.File
import java.io.FileInputStream

/// One-shot migration from a pre-encryption plaintext Room DB to a SQLCipher
/// encrypted DB. Runs on every cold launch, but only does work the first time
/// (when the file's header still reads `SQLite format 3\0`).
///
/// Why: the security audit added SQLCipher mid-release cycle. Devices that
/// installed before the audit have a plaintext SQLite file that the SQLCipher
/// SupportFactory cannot open ("file is not a database"). Without this
/// migration, upgrading would crash the app on first launch.
///
/// Strategy: read the source with the standard Android SDK SQLite (SQLCipher
/// 4.x cannot reliably open a no-header plaintext DB — empty-password mode
/// still tries to consume an encrypted header). Create a fresh SQLCipher DB
/// at the destination, replay table schema + rows + indices, preserve the
/// Room user_version PRAGMA so Room recognises the schema, then swap files
/// atomically.
internal object PlaintextDbMigration {
    private const val TAG = "DbMigration"

    // The SQLite plaintext magic is the 16-byte sequence "SQLite format 3"
    // followed by a NUL. Compare against bytes (not strings) so a future
    // editor doesn't silently swap the trailing NUL for a space — an earlier
    // revision had that exact bug and the migration never ran.
    private val PLAINTEXT_HEADER: ByteArray = byteArrayOf(
        0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66,
        0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00,
    )

    fun maybeMigrate(context: Context, dbName: String, passphrase: ByteArray) {
        val dbFile = context.getDatabasePath(dbName) ?: return
        if (!dbFile.exists() || !isPlaintextSqlite(dbFile)) return

        Log.i(TAG, "Re-encrypting plaintext Room DB at ${dbFile.absolutePath}")
        val tmp = File(dbFile.parentFile, "${dbFile.name}.encrypted.tmp")
        if (tmp.exists()) tmp.delete()
        File(dbFile.parentFile, "${tmp.name}-shm").delete()
        File(dbFile.parentFile, "${tmp.name}-wal").delete()

        // Checkpoint the WAL into the main file FIRST. Room runs in WAL mode by
        // default, so committed-but-uncheckpointed rows live in `${dbName}-wal`
        // and are invisible to the OPEN_READONLY copy below — without this they
        // would be lost. Open read-write once and force a TRUNCATE checkpoint so
        // every row lands in the main file before we read it.
        runCatching {
            android.database.sqlite.SQLiteDatabase.openDatabase(
                dbFile.absolutePath,
                null,
                android.database.sqlite.SQLiteDatabase.OPEN_READWRITE,
            ).use { wdb ->
                wdb.rawQuery("PRAGMA wal_checkpoint(TRUNCATE)", null).use { it.moveToFirst() }
            }
        }.onFailure { Log.w(TAG, "WAL checkpoint before migration failed (continuing): ${it.message}") }

        val src = android.database.sqlite.SQLiteDatabase.openDatabase(
            dbFile.absolutePath,
            null,
            android.database.sqlite.SQLiteDatabase.OPEN_READONLY,
        )
        // Open the destination via the byte[] overload so SQLCipher consumes
        // the 32-byte passphrase as a raw key (no KDF). This matches what
        // SupportFactory does in production — if we went through the String
        // overload SQLCipher would PBKDF2 the passphrase and produce a key
        // that SupportFactory could not later reopen.
        val dest = SQLiteDatabase.openOrCreateDatabase(tmp.absolutePath, passphrase, null)
        try {
            dest.beginTransaction()
            copySchemaAndRows(src, dest)
            preserveUserVersion(src, dest)
            dest.setTransactionSuccessful()
        } finally {
            if (dest.inTransaction()) dest.endTransaction()
            dest.close()
            src.close()
        }

        // Verify the freshly encrypted DB actually opens with the SAME raw key
        // SupportFactory will use in production — BEFORE we touch the original.
        // If this throws we bail with the plaintext DB still intact, and the
        // next cold launch simply retries the migration.
        SQLiteDatabase.openOrCreateDatabase(tmp.absolutePath, passphrase.copyOf(), null).use { verify ->
            verify.rawQuery("SELECT count(*) FROM sqlite_master", null).use { it.moveToFirst() }
        }

        // Crash-atomic swap: move the plaintext file aside as a backup rather
        // than deleting it outright, so a crash mid-swap can never leave the
        // user with no database at all. Only drop the backup once the encrypted
        // DB is verified and in place.
        val backup = File(dbFile.parentFile, "${dbFile.name}.plaintext.bak")
        if (backup.exists()) backup.delete()
        if (!dbFile.renameTo(backup)) error("Failed to set aside plaintext DB during migration")
        if (!tmp.renameTo(dbFile)) {
            backup.renameTo(dbFile) // roll back to the plaintext DB
            error("Failed to swap encrypted DB into place")
        }
        File(dbFile.parentFile, "${dbFile.name}-shm").delete()
        File(dbFile.parentFile, "${dbFile.name}-wal").delete()
        backup.delete()
        Log.i(TAG, "Plaintext DB migrated to SQLCipher.")
    }

    private fun copySchemaAndRows(
        src: android.database.sqlite.SQLiteDatabase,
        dest: SQLiteDatabase,
    ) {
        val tables = mutableListOf<Pair<String, String>>()
        src.rawQuery(
            "SELECT name, sql FROM sqlite_master WHERE type='table' AND " +
                "name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
            null,
        ).use { c ->
            while (c.moveToNext()) tables += c.getString(0) to c.getString(1)
        }
        for ((name, ddl) in tables) {
            dest.execSQL(ddl)
            copyRows(src, dest, name)
        }
        src.rawQuery(
            "SELECT sql FROM sqlite_master WHERE type='index' AND sql IS NOT NULL",
            null,
        ).use { c ->
            while (c.moveToNext()) dest.execSQL(c.getString(0))
        }
    }

    private fun copyRows(
        src: android.database.sqlite.SQLiteDatabase,
        dest: SQLiteDatabase,
        table: String,
    ) {
        src.rawQuery("SELECT * FROM \"$table\"", null).use { rows ->
            val colCount = rows.columnCount
            if (colCount == 0) return
            val cols = (0 until colCount).joinToString(",") { "\"${rows.getColumnName(it)}\"" }
            val placeholders = (1..colCount).joinToString(",") { "?" }
            val insertSql = "INSERT INTO \"$table\"($cols) VALUES($placeholders)"
            while (rows.moveToNext()) {
                val args = arrayOfNulls<Any>(colCount)
                for (i in 0 until colCount) {
                    args[i] = when (rows.getType(i)) {
                        Cursor.FIELD_TYPE_NULL -> null
                        Cursor.FIELD_TYPE_INTEGER -> rows.getLong(i)
                        Cursor.FIELD_TYPE_FLOAT -> rows.getDouble(i)
                        Cursor.FIELD_TYPE_BLOB -> rows.getBlob(i)
                        else -> rows.getString(i)
                    }
                }
                dest.execSQL(insertSql, args)
            }
        }
    }

    private fun preserveUserVersion(
        src: android.database.sqlite.SQLiteDatabase,
        dest: SQLiteDatabase,
    ) {
        // Room reads PRAGMA user_version to decide whether migrations are
        // needed. Without preserving it the freshly encrypted DB would look
        // like v0 and Room would refuse to use it (no destructive fallback).
        src.rawQuery("PRAGMA user_version", null).use { c ->
            if (c.moveToFirst()) dest.rawExecSQL("PRAGMA user_version = ${c.getInt(0)}")
        }
    }

    internal fun isPlaintextSqlite(file: File): Boolean = try {
        FileInputStream(file).use { input ->
            val header = ByteArray(16)
            val read = input.read(header)
            read == 16 && header.contentEquals(PLAINTEXT_HEADER)
        }
    } catch (_: Throwable) {
        false
    }
}
