package com.kevingamez.debttracker.ui.debts

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.kevingamez.debttracker.R
import com.kevingamez.debttracker.domain.model.DebtDirection
import com.kevingamez.debttracker.domain.model.DerivedDebt
import com.kevingamez.debttracker.services.CurrencyFormatter
import com.kevingamez.debttracker.ui.theme.DebtColors

@Composable
fun DebtsListScreen(
    onAddDebt: () -> Unit,
    onDebtTap: (String) -> Unit,
    vm: DebtsListViewModel = hiltViewModel(),
) {
    val state by vm.state.collectAsStateWithLifecycle()
    Box(Modifier.fillMaxSize().background(DebtColors.Background)) {
        LazyColumn(
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            item {
                Text(stringResource(R.string.debts_title),
                    color = DebtColors.TextPrimary,
                    fontSize = 28.sp, fontWeight = FontWeight.Bold)
            }
            item { SearchBar(state.searchText, vm::setSearch) }
            item { FilterRow(state.filterDirection, vm::setFilter) }
            if (state.debts.isEmpty()) {
                item { Empty() }
            } else {
                items(state.debts, key = { it.entity.id }) { d ->
                    DebtRow(
                        derived = d,
                        personName = state.persons[d.entity.personId]?.name ?: "—",
                        onTap = { onDebtTap(d.entity.id) }
                    )
                }
            }
        }
        FloatingActionButton(
            onClick = onAddDebt,
            containerColor = DebtColors.PrimaryAccent,
            modifier = Modifier.align(Alignment.BottomEnd).padding(20.dp)
        ) { Icon(Icons.Filled.Add, null, tint = Color.White) }
    }
}

@Composable
private fun SearchBar(text: String, onChange: (String) -> Unit) {
    OutlinedTextField(
        value = text, onValueChange = onChange,
        placeholder = { Text(stringResource(R.string.debts_search)) },
        leadingIcon = { Icon(Icons.Filled.Search, null) },
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(14.dp),
        singleLine = true,
    )
}

@Composable
private fun FilterRow(current: DebtDirection?, onChange: (DebtDirection?) -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Pill(stringResource(R.string.debts_filter_all), current == null) { onChange(null) }
        Pill(stringResource(R.string.dashboard_owed_to_me), current == DebtDirection.OWED_TO_ME) { onChange(DebtDirection.OWED_TO_ME) }
        Pill(stringResource(R.string.dashboard_i_owe), current == DebtDirection.I_OWE) { onChange(DebtDirection.I_OWE) }
    }
}

@Composable
private fun Pill(label: String, selected: Boolean, onClick: () -> Unit) {
    val bg = if (selected) DebtColors.PrimaryAccent else DebtColors.Surface
    val fg = if (selected) Color.White else DebtColors.TextSecondary
    Box(
        Modifier.clip(RoundedCornerShape(50)).background(bg).clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp)
    ) { Text(label, color = fg, fontSize = 13.sp, fontWeight = FontWeight.Medium) }
}

@Composable
private fun DebtRow(derived: DerivedDebt, personName: String, onTap: () -> Unit) {
    val amountColor = when (derived.entity.direction) {
        DebtDirection.OWED_TO_ME -> DebtColors.Green
        DebtDirection.I_OWE -> DebtColors.Red
    }
    Card(
        modifier = Modifier.fillMaxWidth().clickable(onClick = onTap),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
    ) {
        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(40.dp).clip(CircleShape).background(DebtColors.PrimaryAccentMuted),
                contentAlignment = Alignment.Center
            ) {
                Text(personName.take(2).uppercase(),
                    color = DebtColors.PrimaryAccent, fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(personName, color = DebtColors.TextPrimary, fontWeight = FontWeight.SemiBold)
                Text(derived.entity.title, color = DebtColors.TextTertiary, fontSize = 12.sp)
            }
            Text(CurrencyFormatter.format(derived.remainingAmount),
                color = amountColor, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
private fun Empty() {
    Column(
        Modifier.fillMaxWidth().padding(top = 64.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(stringResource(R.string.debts_empty_title),
            color = DebtColors.TextPrimary, fontWeight = FontWeight.SemiBold, fontSize = 18.sp)
        Spacer(Modifier.height(4.dp))
        Text(stringResource(R.string.debts_empty_subtitle), color = DebtColors.TextTertiary)
    }
}
