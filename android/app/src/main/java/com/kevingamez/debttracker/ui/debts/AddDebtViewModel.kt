package com.kevingamez.debttracker.ui.debts

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.db.DebtEntity
import com.kevingamez.debttracker.data.db.PersonEntity
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.domain.model.DebtDirection
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import java.math.BigDecimal
import javax.inject.Inject

@HiltViewModel
class AddDebtViewModel @Inject constructor(
    private val repository: DebtRepository,
) : ViewModel() {

    /// Mirrors iOS [InputBounds]. 1e12 cap on amount, 120-char title cap (the
    /// caller already truncates), 2000-char notes cap.
    private val maxAmount: BigDecimal = BigDecimal("1000000000000")

    fun save(
        title: String,
        amountString: String,
        direction: DebtDirection,
        personName: String,
        notes: String?,
    ) {
        val raw = amountString.toBigDecimalOrNull() ?: return
        if (raw.signum() <= 0) return
        val amount = raw.min(maxAmount)
        viewModelScope.launch {
            val personId = if (personName.isBlank()) null else {
                val person = PersonEntity(name = personName)
                repository.upsertPerson(person)
                person.id
            }
            repository.upsertDebt(
                DebtEntity(
                    title = title,
                    totalAmount = amount,
                    direction = direction,
                    personId = personId,
                    notes = notes,
                )
            )
        }
    }
}
