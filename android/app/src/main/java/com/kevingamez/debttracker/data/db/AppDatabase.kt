package com.kevingamez.debttracker.data.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

@Database(
    entities = [DebtEntity::class, PaymentEntity::class, PersonEntity::class, CategoryEntity::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun debtDao(): DebtDao
    abstract fun paymentDao(): PaymentDao
    abstract fun personDao(): PersonDao
    abstract fun categoryDao(): CategoryDao

    companion object {
        const val DB_NAME = "debt_tracker.db"
    }
}
