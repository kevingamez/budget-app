package com.kevingamez.debttracker.ui.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.services.SupabaseAuthService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AuthUiState(
    val loading: Boolean = false,
    val errorMessage: String? = null,
    val authenticated: Boolean = false,
)

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authService: SupabaseAuthService,
) : ViewModel() {

    val isConfigured: Boolean = authService.isConfigured

    private val _state = MutableStateFlow(AuthUiState())
    val state: StateFlow<AuthUiState> = _state.asStateFlow()

    fun signIn(email: String, password: String) = launchAuth {
        authService.signInWithEmail(email.trim(), password)
    }

    fun signUp(email: String, password: String) = launchAuth {
        authService.signUpWithEmail(email.trim(), password)
    }

    private fun launchAuth(block: suspend () -> Result<Unit>) {
        viewModelScope.launch {
            _state.update { it.copy(loading = true, errorMessage = null) }
            val result = block()
            _state.update {
                it.copy(
                    loading = false,
                    errorMessage = result.exceptionOrNull()?.message,
                    authenticated = result.isSuccess,
                )
            }
        }
    }
}
