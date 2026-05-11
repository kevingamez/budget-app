package com.kevingamez.debttracker.data.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

/// Schema is exported to `app/schemas/` so every version change shows up in
/// code review. The KSP `room.schemaLocation` argument in `build.gradle.kts`
/// wires the generator output to that folder.
@Database(
    entities = [DebtEntity::class, PaymentEntity::class, PersonEntity::class, CategoryEntity::class],
    version = 1,
    exportSchema = true,
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun debtDao(): DebtDao
    abstract fun paymentDao(): PaymentDao
    abstract fun personDao(): PersonDao
    abstract fun categoryDao(): CategoryDao

    companion object {
        const val DB_NAME = "debt_tracker.db"

        /// When the entities change, bump `version` above and append a
        /// hand-written `Migration(N, N+1)` here. The destructive fallback
        /// is intentionally NOT registered — a finance app must not silently
        /// wipe user data on schema drift.
        val ALL_MIGRATIONS: Array<androidx.room.migration.Migration> = arrayOf(
            // no migrations yet — DB is on v1
        )
    }
}
