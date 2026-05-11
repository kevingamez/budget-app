package com.kevingamez.debttracker.ui.debts

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.db.PaymentEntity
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.domain.model.DerivedDebt
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.math.BigDecimal
import javax.inject.Inject

data class DebtDetailState(
    val derived: DerivedDebt? = null,
    val personName: String? = null,
)

@HiltViewModel
class DebtDetailViewModel @Inject constructor(
    private val repository: DebtRepository,
) : ViewModel() {

    private val debtId = MutableStateFlow<String?>(null)

    val state: StateFlow<DebtDetailState> = debtId.flatMapLatest { id ->
        if (id == null) flowOf(DebtDetailState())
        else combine(
            repository.debtsStream,
            repository.paymentsForDebt(id),
            repository.personsStream,
        ) { debts, payments, persons ->
            val debt = debts.firstOrNull { it.id == id } ?: return@combine DebtDetailState()
            val person = persons.firstOrNull { it.id == debt.personId }
            DebtDetailState(
                derived = DerivedDebt(debt, payments),
                personName = person?.name
            )
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DebtDetailState())

    fun load(id: String) { debtId.value = id }

    /// Clamp the payment at the remaining balance — matches iOS recordPayment.
    fun recordPayment(amount: BigDecimal) {
        val derived = state.value.derived ?: return
        val capped = amount.min(derived.remainingAmount)
        if (capped.signum() <= 0) return
        viewModelScope.launch {
            repository.upsertPayment(PaymentEntity(debtId = derived.entity.id, amount = capped))
        }
    }

    fun delete() {
        val d = state.value.derived?.entity ?: return
        viewModelScope.launch { repository.deleteDebt(d) }
    }
}
