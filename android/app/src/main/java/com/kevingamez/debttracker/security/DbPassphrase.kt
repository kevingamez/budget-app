package com.kevingamez.debttracker.security

import android.content.Context
import android.util.Base64
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.io.File
import java.security.SecureRandom

/// Thrown when the SQLCipher passphrase cannot be read or persisted AND an
/// encrypted database already exists — i.e. silently minting a new key would
/// permanently brick the user's data. Failing loud is strictly safer than the
/// previous behaviour of overwriting the only key.
internal class DbPassphraseUnavailableException(
    message: String,
    cause: Throwable? = null,
) : Exception(message, cause)

/// Generates and persists a 32-byte SQLCipher passphrase for the Room DB.
///
/// The passphrase lives in [EncryptedSharedPreferences], which is wrapped by
/// the Android Keystore via [MasterKey]. The key material never appears on
/// disk in plaintext, never crosses a process boundary, and is bound to this
/// install — uninstalling the app destroys it along with the encrypted DB.
///
/// We return the passphrase as a `ByteArray` so the caller can hand it to
/// SQLCipher's `SupportFactory` without it touching `String`'s immutable
/// heap allocation (which would leave the secret resident until GC).
internal object DbPassphrase {
    private const val PREFS_NAME = "debt_tracker_db_secret"
    private const val KEY_PASSPHRASE = "passphrase_b64"
    private const val PASSPHRASE_BYTES = 32

    fun get(context: Context, dbName: String): ByteArray {
        val prefs = try {
            encryptedPrefs(context)
        } catch (e: Throwable) {
            // Keystore / MasterKey unreadable (e.g. lock-screen change, OS
            // upgrade, library corruption). If an encrypted DB already exists we
            // must NOT recreate prefs with a new key — that orphans the data.
            if (encryptedDbExists(context, dbName)) {
                throw DbPassphraseUnavailableException(
                    "Keystore unavailable but an encrypted DB exists; refusing to regenerate the key", e,
                )
            }
            throw e
        }

        val existing = prefs.getString(KEY_PASSPHRASE, null)
        if (existing != null) {
            // Base64-decoded bytes — SQLCipher accepts raw key bytes.
            return Base64.decode(existing, Base64.NO_WRAP)
        }

        // No stored passphrase. If an encrypted DB is already on disk,
        // generating a fresh key would lock its data away forever — fail loud
        // instead of silently destroying it. (A plaintext pre-migration DB is
        // fine: it gets a brand-new key and is re-encrypted by the migration.)
        if (encryptedDbExists(context, dbName)) {
            throw DbPassphraseUnavailableException(
                "Stored passphrase missing but an encrypted DB exists; refusing to regenerate the key",
            )
        }

        val fresh = ByteArray(PASSPHRASE_BYTES).also { SecureRandom().nextBytes(it) }
        // commit() (synchronous + durable) — NOT apply(). The key must be on
        // disk before SQLCipher opens the DB with it; an apply() that hasn't
        // flushed when the process dies would leave the DB encrypted under a key
        // the next launch can't find.
        val committed = prefs.edit()
            .putString(KEY_PASSPHRASE, Base64.encodeToString(fresh, Base64.NO_WRAP))
            .commit()
        if (!committed) {
            throw DbPassphraseUnavailableException("Failed to persist the DB passphrase")
        }
        return fresh
    }

    /// True when a database file exists that is already SQLCipher-encrypted
    /// (i.e. NOT a pre-encryption plaintext file awaiting migration).
    private fun encryptedDbExists(context: Context, dbName: String): Boolean {
        val db: File = context.getDatabasePath(dbName) ?: return false
        return db.exists() && !PlaintextDbMigration.isPlaintextSqlite(db)
    }

    private fun encryptedPrefs(context: Context) = EncryptedSharedPreferences.create(
        context,
        PREFS_NAME,
        MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
    )
}
