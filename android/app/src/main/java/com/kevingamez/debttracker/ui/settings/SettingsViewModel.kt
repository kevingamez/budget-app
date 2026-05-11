package com.kevingamez.debttracker.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.services.AuthUser
import com.kevingamez.debttracker.services.SampleDataService
import com.kevingamez.debttracker.services.SupabaseAuthService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val authService: SupabaseAuthService,
    private val repository: DebtRepository,
    private val sampleData: SampleDataService,
) : ViewModel() {

    val user: StateFlow<AuthUser?> = authService.currentUser

    /// Same wipe semantics as iOS: SwiftData equivalent (Room) + local prefs.
    fun signOut() = viewModelScope.launch {
        authService.signOut { repository.wipeAll() }
    }

    fun clearAllData() = viewModelScope.launch { repository.wipeAll() }

    fun loadSampleData() = viewModelScope.launch {
        repository.wipeAll()
        sampleData.seed()
    }
}
