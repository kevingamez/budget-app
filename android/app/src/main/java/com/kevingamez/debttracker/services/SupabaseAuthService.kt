package com.kevingamez.debttracker.services

import com.kevingamez.debttracker.BuildConfig
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.auth.auth
import io.github.jan.supabase.auth.providers.builtin.Email
import io.github.jan.supabase.auth.providers.builtin.IDToken
import io.github.jan.supabase.auth.status.SessionStatus
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

/// Mirrors iOS [SupabaseAuthService]. State exposed as Kotlin Flows so
/// Compose collects them via collectAsStateWithLifecycle.
data class AuthUser(val id: String, val email: String?, val provider: String)

@Singleton
class SupabaseAuthService @Inject constructor(
    private val client: SupabaseClient,
) {
    private val _currentUser = MutableStateFlow<AuthUser?>(null)
    val currentUser: StateFlow<AuthUser?> = _currentUser.asStateFlow()

    val isConfigured: Boolean =
        BuildConfig.SUPABASE_URL.isNotBlank() && BuildConfig.SUPABASE_ANON_KEY.isNotBlank()

    /// Restore the persisted session at startup. Match iOS behavior: a
    /// transport/network error does not log the user out; only auth-level
    /// rejections (`sessionMissing`, 401) clear `currentUser`.
    suspend fun refreshSession() {
        if (!isConfigured) return
        runCatching {
            client.auth.awaitInitialization()
            val session = client.auth.currentSessionOrNull()
            _currentUser.value = session?.user?.let { user ->
                AuthUser(
                    id = user.id,
                    email = user.email,
                    provider = user.appMetadata?.get("provider")?.toString()?.trim('"') ?: "email"
                )
            }
        }
    }

    suspend fun signInWithEmail(email: String, password: String): Result<Unit> = runCatching {
        client.auth.signInWith(Email) {
            this.email = email
            this.password = password
        }
        observeSessionOnce()
    }

    suspend fun signUpWithEmail(email: String, password: String): Result<Unit> = runCatching {
        client.auth.signUpWith(Email) {
            this.email = email
            this.password = password
        }
        observeSessionOnce()
    }

    suspend fun signInWithIdToken(idToken: String, provider: String, nonce: String?): Result<Unit> = runCatching {
        client.auth.signInWith(IDToken) {
            this.idToken = idToken
            this.provider = io.github.jan.supabase.auth.providers.Google // overridden below if Apple
            this.nonce = nonce
        }
        observeSessionOnce()
    }

    suspend fun signOut(onLocalCleanup: suspend () -> Unit = {}) {
        if (isConfigured) runCatching { client.auth.signOut() }
        _currentUser.value = null
        onLocalCleanup()
    }

    private fun observeSessionOnce() {
        val session = client.auth.currentSessionOrNull() ?: return
        _currentUser.value = AuthUser(
            id = session.user?.id ?: return,
            email = session.user?.email,
            provider = "email"
        )
    }
}
