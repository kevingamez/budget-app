package com.kevingamez.debttracker.di

import android.content.Context
import androidx.room.Room
import com.kevingamez.debttracker.BuildConfig
import com.kevingamez.debttracker.data.db.AppDatabase
import com.kevingamez.debttracker.data.db.CategoryDao
import com.kevingamez.debttracker.data.db.DebtDao
import com.kevingamez.debttracker.data.db.PaymentDao
import com.kevingamez.debttracker.data.db.PersonDao
import com.kevingamez.debttracker.security.DbPassphrase
import com.kevingamez.debttracker.security.PlaintextDbMigration
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.auth.Auth
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.functions.Functions
import io.github.jan.supabase.postgrest.Postgrest
import net.sqlcipher.database.SQLiteDatabase
import net.sqlcipher.database.SupportFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides @Singleton
    fun database(@ApplicationContext ctx: Context): AppDatabase {
        // SQLCipher needs its native library loaded before any DB open.
        SQLiteDatabase.loadLibs(ctx)
        val passphrase = DbPassphrase.get(ctx)
        // Pre-encryption installs left a plaintext SQLite file on disk that
        // SupportFactory can't open. Migrate it in place before Room tries.
        // The migration uses a copy of the key because SupportFactory zeroes
        // the array it owns once the DB is open.
        PlaintextDbMigration.maybeMigrate(ctx, AppDatabase.DB_NAME, passphrase.copyOf())
        val factory = SupportFactory(passphrase, null, /* clearPassphrase = */ true)
        return Room.databaseBuilder(ctx, AppDatabase::class.java, AppDatabase.DB_NAME)
            .openHelperFactory(factory)
            .fallbackToDestructiveMigration()
            .build()
    }

    @Provides fun debtDao(db: AppDatabase): DebtDao = db.debtDao()
    @Provides fun paymentDao(db: AppDatabase): PaymentDao = db.paymentDao()
    @Provides fun personDao(db: AppDatabase): PersonDao = db.personDao()
    @Provides fun categoryDao(db: AppDatabase): CategoryDao = db.categoryDao()

    /// Built once per process from BuildConfig values that come out of
    /// local.properties (mirrors the iOS Secrets.plist pattern). When the
    /// URL is blank we still build a client against a placeholder so the
    /// rest of DI doesn't NPE — `isConfigured` gates the auth UI.
    @Provides @Singleton
    fun supabaseClient(): SupabaseClient {
        val url = BuildConfig.SUPABASE_URL.ifBlank { "https://placeholder.supabase.co" }
        val key = BuildConfig.SUPABASE_ANON_KEY.ifBlank { "placeholder" }
        return createSupabaseClient(url, key) {
            install(Auth)
            install(Postgrest)
            install(Functions)
        }
    }
}
