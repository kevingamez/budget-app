package com.kevingamez.debttracker.ui.debts

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.kevingamez.debttracker.data.db.PersonEntity
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.domain.model.DebtDirection
import com.kevingamez.debttracker.domain.model.DerivedDebt
import com.kevingamez.debttracker.domain.model.joinPayments
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DebtsListState(
    val debts: List<DerivedDebt> = emptyList(),
    val persons: Map<String, PersonEntity> = emptyMap(),
    val filterDirection: DebtDirection? = null,
    val searchText: String = "",
)

@HiltViewModel
class DebtsListViewModel @Inject constructor(
    private val repository: DebtRepository,
) : ViewModel() {

    private val filterDirection = MutableStateFlow<DebtDirection?>(null)
    private val searchText = MutableStateFlow("")

    /// Combine the four streams. Matches iOS pattern where the View owns
    /// @Query results and the VM exposes a filtered/sorted slice.
    val state: StateFlow<DebtsListState> = combine(
        repository.debtsWithPayments(),
        repository.personsStream,
        filterDirection,
        searchText,
    ) { (debts, payments), persons, direction, search ->
        val byPerson = persons.associateBy { it.id }
        val derived = debts.joinPayments(payments)
            .let { list -> if (direction == null) list else list.filter { it.entity.direction == direction } }
            .let { list ->
                if (search.isBlank()) list
                else list.filter {
                    it.entity.title.contains(search, ignoreCase = true) ||
                        byPerson[it.entity.personId]?.name?.contains(search, ignoreCase = true) == true
                }
            }
            .sortedByDescending { it.entity.createdAt }
        DebtsListState(derived, byPerson, direction, search)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DebtsListState())

    fun setFilter(direction: DebtDirection?) { filterDirection.value = direction }
    fun setSearch(text: String) { searchText.value = text }

    fun delete(derived: DerivedDebt) {
        viewModelScope.launch { repository.deleteDebt(derived.entity) }
    }
}
