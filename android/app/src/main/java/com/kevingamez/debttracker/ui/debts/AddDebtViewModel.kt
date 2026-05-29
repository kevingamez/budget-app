package com.kevingamez.debttracker.ui.debts

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.db.DebtEntity
import com.kevingamez.debttracker.data.db.PersonEntity
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.domain.model.DebtDirection
import com.kevingamez.debttracker.services.CurrencyFormatter
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import java.math.BigDecimal
import javax.inject.Inject

@HiltViewModel
class AddDebtViewModel @Inject constructor(
    private val repository: DebtRepository,
) : ViewModel() {

    /// Mirrors iOS [InputBounds]. Caps live in the VM so every screen / test
    /// that calls `save(...)` inherits the same limits — `AddDebtScreen` used
    /// to truncate at the UI layer, which left the rule fragile to new
    /// callers.
    private val maxAmount: BigDecimal = BigDecimal("1000000000000")
    private val titleMaxLength = 120
    private val notesMaxLength = 2000

    fun save(
        title: String,
        amountString: String,
        direction: DebtDirection,
        personName: String,
        notes: String?,
    ) {
        val raw = CurrencyFormatter.parseAmount(amountString) ?: return
        if (raw.signum() <= 0) return
        val amount = raw.min(maxAmount)

        val boundedTitle = title.trim().take(titleMaxLength)
        if (boundedTitle.isEmpty()) return
        val boundedPerson = personName.trim().take(titleMaxLength)
        val boundedNotes = notes?.trim()?.take(notesMaxLength)?.ifBlank { null }

        viewModelScope.launch {
            val personId = if (boundedPerson.isBlank()) null else {
                val person = PersonEntity(name = boundedPerson)
                repository.upsertPerson(person)
                person.id
            }
            repository.upsertDebt(
                DebtEntity(
                    title = boundedTitle,
                    totalAmount = amount,
                    direction = direction,
                    personId = personId,
                    notes = boundedNotes,
                )
            )
        }
    }
}
