package com.kevingamez.debttracker.ui.activity

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.domain.model.DebtDirection
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import java.math.BigDecimal
import javax.inject.Inject

data class ActivityRow(
    val id: String,
    val personName: String,
    val subtitle: String,
    val amount: BigDecimal,
    val incoming: Boolean,
)

data class ActivityState(val rows: List<ActivityRow> = emptyList())

@HiltViewModel
class ActivityViewModel @Inject constructor(
    private val repository: DebtRepository,
) : ViewModel() {

    val state: StateFlow<ActivityState> = combine(
        repository.paymentsStream,
        repository.debtsStream,
        repository.personsStream,
    ) { payments, debts, persons ->
        val debtsById = debts.associateBy { it.id }
        val personsById = persons.associateBy { it.id }
        val rows = payments
            .sortedByDescending { it.date }
            .mapNotNull { p ->
                val debt = debtsById[p.debtId] ?: return@mapNotNull null
                val person = personsById[debt.personId]
                ActivityRow(
                    id = p.id,
                    personName = person?.name ?: "—",
                    subtitle = debt.title + (p.notes?.let { " · $it" }.orEmpty()),
                    amount = p.amount,
                    incoming = debt.direction == DebtDirection.OWED_TO_ME,
                )
            }
        ActivityState(rows)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), ActivityState())
}
