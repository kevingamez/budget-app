package com.kevingamez.debttracker.security

import android.content.Context
import android.util.Base64
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.security.SecureRandom

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

    fun get(context: Context): ByteArray {
        val prefs = encryptedPrefs(context)
        val existing = prefs.getString(KEY_PASSPHRASE, null)
        if (existing != null) {
            // Base64-decoded bytes — SQLCipher accepts raw key bytes.
            return Base64.decode(existing, Base64.NO_WRAP)
        }
        val fresh = ByteArray(PASSPHRASE_BYTES).also { SecureRandom().nextBytes(it) }
        prefs.edit()
            .putString(KEY_PASSPHRASE, Base64.encodeToString(fresh, Base64.NO_WRAP))
            .apply()
        return fresh
    }

    private fun encryptedPrefs(context: Context) = EncryptedSharedPreferences.create(
        context,
        PREFS_NAME,
        MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
    )
}
