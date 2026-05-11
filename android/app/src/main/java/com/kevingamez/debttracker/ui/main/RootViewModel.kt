package com.kevingamez.debttracker.ui.main

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.services.SampleDataService
import com.kevingamez.debttracker.services.SupabaseAuthService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class RootViewModel @Inject constructor(
    private val authService: SupabaseAuthService,
    private val repository: DebtRepository,
    private val sampleData: SampleDataService,
) : ViewModel() {

    val currentUser: StateFlow<com.kevingamez.debttracker.services.AuthUser?> = authService.currentUser

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

    /// Mirrors iOS `seedSampleDataIfNeeded`: the first time the local DB is
    /// empty, populate it so a fresh install isn't a blank dashboard.
    private suspend fun seedIfEmpty() {
        val debts = repository.debtsStream.first()
        if (debts.isEmpty()) sampleData.seed()
    }
}
