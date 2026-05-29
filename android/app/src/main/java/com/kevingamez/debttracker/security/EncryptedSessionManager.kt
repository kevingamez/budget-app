package com.kevingamez.debttracker.security

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.github.jan.supabase.auth.SessionManager
import io.github.jan.supabase.auth.user.UserSession
import kotlinx.serialization.json.Json

/// Persists the Supabase auth session (access + refresh JWT) in
/// [EncryptedSharedPreferences], which is wrapped by the Android Keystore via
/// [MasterKey]. supabase-kt's default [io.github.jan.supabase.auth.SettingsSessionManager]
/// stores the session JSON in plaintext SharedPreferences, where a refresh
/// token — which grants full access to the user's synced financial data — is
/// recoverable via adb backup, `run-as`, or any read of the app's data dir on a
/// rooted/compromised device. This brings Android in line with the iOS Keychain
/// and the app's own SQLCipher passphrase storage.
internal class EncryptedSessionManager(context: Context) : SessionManager {

    private val prefs = EncryptedSharedPreferences.create(
        context,
        PREFS_NAME,
        MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
    )

    private val json = Json { ignoreUnknownKeys = true }

    override suspend fun saveSession(session: UserSession) {
        prefs.edit()
            .putString(KEY_SESSION, json.encodeToString(UserSession.serializer(), session))
            .apply()
    }

    override suspend fun loadSession(): UserSession? {
        val raw = prefs.getString(KEY_SESSION, null) ?: return null
        return runCatching { json.decodeFromString(UserSession.serializer(), raw) }.getOrNull()
    }

    override suspend fun deleteSession() {
        prefs.edit().remove(KEY_SESSION).apply()
    }

    private companion object {
        const val PREFS_NAME = "debt_tracker_session"
        const val KEY_SESSION = "supabase_session"
    }
}
