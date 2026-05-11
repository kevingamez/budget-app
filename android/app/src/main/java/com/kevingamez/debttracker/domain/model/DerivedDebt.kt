package com.kevingamez.debttracker.domain.model

import com.kevingamez.debttracker.data.db.DebtEntity
import com.kevingamez.debttracker.data.db.PaymentEntity
import java.math.BigDecimal
import java.time.Instant

/// View-layer composite. Pulls the cascade-like derived fields out of the
/// entity so the UI doesn't have to remember the rules. Mirrors the
/// computed properties on the Swift `Debt` @Model.
data class DerivedDebt(
    val entity: DebtEntity,
    val payments: List<PaymentEntity>,
) {
    val paidAmount: BigDecimal = payments.fold(BigDecimal.ZERO) { acc, p -> acc + p.amount }
    val remainingAmount: BigDecimal = (entity.totalAmount - paidAmount).max(BigDecimal.ZERO)
    val progressFraction: Double =
        if (entity.totalAmount.signum() == 0) 0.0
        else paidAmount.toDouble() / entity.totalAmount.toDouble()

    val isOverdue: Boolean = entity.dueDate?.let { it.isBefore(Instant.now()) } == true
            && entity.status != DebtStatus.FORGIVEN
            && remainingAmount.signum() > 0

    val derivedStatus: DebtStatus = when {
        entity.status == DebtStatus.FORGIVEN -> DebtStatus.FORGIVEN
        remainingAmount.signum() <= 0 -> DebtStatus.PAID_OFF
        paidAmount.signum() > 0 -> DebtStatus.PARTIALLY_PAID
        isOverdue -> DebtStatus.OVERDUE
        else -> DebtStatus.ACTIVE
    }
}

fun List<DebtEntity>.joinPayments(payments: List<PaymentEntity>): List<DerivedDebt> {
    val byDebt = payments.groupBy { it.debtId }
    return this.map { DerivedDebt(it, byDebt[it.id].orEmpty()) }
}
