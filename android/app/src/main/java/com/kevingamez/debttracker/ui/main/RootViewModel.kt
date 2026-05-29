package com.kevingamez.debttracker.ui.main

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.services.SampleDataService
import com.kevingamez.debttracker.services.SupabaseAuthService
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import javax.inject.Inject

@HiltViewModel
class RootViewModel @Inject constructor(
    private val authService: SupabaseAuthService,
    private val repository: DebtRepository,
    private val sampleData: SampleDataService,
    @ApplicationContext private val appContext: Context,
) : ViewModel() {

    val currentUser: StateFlow<com.kevingamez.debttracker.services.AuthUser?> = authService.currentUser

    private val seedMutex = Mutex()
    private val prefs by lazy {
        appContext.getSharedPreferences("debt_tracker_flags", Context.MODE_PRIVATE)
    }

    init {
        viewModelScope.launch {
            authService.refreshSession()
            seedIfEmpty()
        }
    }

    fun refresh() {
        viewModelScope.launch {
            authService.refreshSession()
            seedIfEmpty()
        }
    }

    /// Mirrors iOS `seedSampleDataIfNeeded`: seed the sample fixtures at most
    /// ONCE per install. Gating only on a live empty-DB check (as before) let
    /// two concurrent callers (init + refresh on first sign-in) both seed —
    /// doubling every fixture — and re-seeded fake data after the user wiped
    /// everything. A persistent flag (like iOS's UserDefaults boolean) plus a
    /// mutex makes it idempotent.
    private suspend fun seedIfEmpty() {
        if (prefs.getBoolean(KEY_SEEDED, false)) return
        seedMutex.withLock {
            if (prefs.getBoolean(KEY_SEEDED, false)) return@withLock
            val debts = repository.debtsStream.first()
            if (debts.isEmpty()) sampleData.seed()
            // Mark seeded whether we seeded or the user already had data, so we
            // never seed over real data later (e.g. after a "Clear All Data").
            prefs.edit().putBoolean(KEY_SEEDED, true).apply()
        }
    }

    private companion object {
        const val KEY_SEEDED = "sample_data_seeded"
    }
}
