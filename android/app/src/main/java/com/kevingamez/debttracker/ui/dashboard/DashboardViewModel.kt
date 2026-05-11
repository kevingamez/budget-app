package com.kevingamez.debttracker.ui.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.db.PaymentEntity
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.domain.model.DebtDirection
import com.kevingamez.debttracker.domain.model.DebtStatus
import com.kevingamez.debttracker.domain.model.DerivedDebt
import com.kevingamez.debttracker.domain.model.joinPayments
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import java.math.BigDecimal
import javax.inject.Inject

/// Equivalent of iOS DashboardViewModel.refresh — same aggregates, exposed
/// as a single StateFlow<DashboardState> so the Compose screen just reads it.
data class DashboardState(
    val totalOwedToMe: BigDecimal = BigDecimal.ZERO,
    val totalIOwe: BigDecimal = BigDecimal.ZERO,
    val netBalance: BigDecimal = BigDecimal.ZERO,
    val activeDebtCount: Int = 0,
    val overdueCount: Int = 0,
    val almostPaidCount: Int = 0,
    val totalAmountTracked: BigDecimal = BigDecimal.ZERO,
    val paidOffCount: Int = 0,
    val averageAmount: BigDecimal = BigDecimal.ZERO,
    val totalPaymentAmount: BigDecimal = BigDecimal.ZERO,
    val totalDebts: Int = 0,
    val totalPersons: Int = 0,
    val recentPayments: List<PaymentEntity> = emptyList(),
)

@HiltViewModel
class DashboardViewModel @Inject constructor(repository: DebtRepository) : ViewModel() {

    val state: StateFlow<DashboardState> = repository.debtsWithPayments()
        .map { (debts, payments) ->
            val derived: List<DerivedDebt> = debts.joinPayments(payments)
            val active = derived.filter { it.derivedStatus != DebtStatus.PAID_OFF && it.derivedStatus != DebtStatus.FORGIVEN }

            val owedToMe = active.filter { it.entity.direction == DebtDirection.OWED_TO_ME }
                .fold(BigDecimal.ZERO) { acc, d -> acc + d.remainingAmount }
            val iOwe = active.filter { it.entity.direction == DebtDirection.I_OWE }
                .fold(BigDecimal.ZERO) { acc, d -> acc + d.remainingAmount }

            DashboardState(
                totalOwedToMe = owedToMe,
                totalIOwe = iOwe,
                netBalance = owedToMe - iOwe,
                activeDebtCount = active.size,
                overdueCount = active.count { it.isOverdue },
                almostPaidCount = active.count { it.progressFraction in 0.5..0.99 },
                totalAmountTracked = debts.fold(BigDecimal.ZERO) { acc, d -> acc + d.totalAmount },
                paidOffCount = derived.count { it.derivedStatus == DebtStatus.PAID_OFF || it.derivedStatus == DebtStatus.FORGIVEN },
                averageAmount = if (debts.isEmpty()) BigDecimal.ZERO
                    else debts.fold(BigDecimal.ZERO) { acc, d -> acc + d.totalAmount } / BigDecimal(debts.size),
                totalPaymentAmount = payments.fold(BigDecimal.ZERO) { acc, p -> acc + p.amount },
                totalDebts = debts.size,
                totalPersons = derived.mapNotNull { it.entity.personId }.distinct().size,
                recentPayments = payments.sortedByDescending { it.date }.take(5),
            )
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DashboardState())
}
