package com.kevingamez.debttracker.ui.debts

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.kevingamez.debttracker.R
import com.kevingamez.debttracker.domain.model.DebtDirection
import com.kevingamez.debttracker.services.CurrencyFormatter
import com.kevingamez.debttracker.ui.theme.DebtColors
import java.math.BigDecimal

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DebtDetailScreen(
    debtId: String,
    onClose: () -> Unit,
    vm: DebtDetailViewModel = hiltViewModel(),
) {
    LaunchedEffect(debtId) { vm.load(debtId) }
    val state by vm.state.collectAsStateWithLifecycle()
    var payDialog by remember { mutableStateOf(false) }
    var payAmount by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(state.derived?.entity?.title.orEmpty()) },
                navigationIcon = {
                    TextButton(onClick = onClose) { Text(stringResource(R.string.common_done)) }
                },
                actions = {
                    TextButton(onClick = { vm.delete(); onClose() }) {
                        Text(stringResource(R.string.common_delete), color = DebtColors.Red)
                    }
                }
            )
        },
        floatingActionButton = {
            if (state.derived?.let { it.remainingAmount.signum() > 0 } == true) {
                ExtendedFloatingActionButton(
                    onClick = { payDialog = true },
                    containerColor = DebtColors.PrimaryAccent
                ) { Text(stringResource(R.string.common_pay)) }
            }
        }
    ) { padding ->
        val derived = state.derived ?: return@Scaffold
        val amountColor = when (derived.entity.direction) {
            DebtDirection.OWED_TO_ME -> DebtColors.Green
            DebtDirection.I_OWE -> DebtColors.Red
        }
        LazyColumn(
            modifier = Modifier.fillMaxSize().background(DebtColors.Background).padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            item {
                Column(horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth().padding(vertical = 16.dp)) {
                    Text(state.personName ?: "—", color = DebtColors.TextSecondary)
                    Spacer(Modifier.height(8.dp))
                    Text(CurrencyFormatter.format(derived.remainingAmount),
                        color = amountColor, fontSize = 38.sp, fontWeight = FontWeight.Bold)
                    Text("of ${CurrencyFormatter.format(derived.entity.totalAmount)}",
                        color = DebtColors.TextTertiary, fontSize = 13.sp)
                }
            }
            item { InfoCard(derived) }
            item {
                Text("Payments (${derived.payments.size})",
                    color = DebtColors.TextPrimary, fontWeight = FontWeight.SemiBold)
            }
            items(derived.payments, key = { it.id }) { p ->
                Card(
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = DebtColors.Surface),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(Modifier.padding(12.dp)) {
                        Text(CurrencyFormatter.format(p.amount),
                            color = DebtColors.Green, fontWeight = FontWeight.SemiBold)
                        Spacer(Modifier.weight(1f))
                        Text(p.date.toString().take(10), color = DebtColors.TextTertiary, fontSize = 12.sp)
                    }
                }
            }
        }
    }

    if (payDialog) {
        AlertDialog(
            onDismissRequest = { payDialog = false },
            title = { Text("Record payment") },
            text = {
                OutlinedTextField(
                    value = payAmount, onValueChange = { payAmount = it.filter { c -> c.isDigit() || c == '.' || c == ',' } },
                    label = { Text("Amount") },
                    singleLine = true
                )
            },
            confirmButton = {
                TextButton(onClick = {
                    CurrencyFormatter.parseAmount(payAmount)?.let {
                        vm.recordPayment(it)
                        payAmount = ""
                        payDialog = false
                    }
                }) { Text("Save") }
            },
            dismissButton = { TextButton(onClick = { payDialog = false }) { Text("Cancel") } }
        )
    }
}

@Composable
private fun InfoCard(derived: com.kevingamez.debttracker.domain.model.DerivedDebt) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = DebtColors.Surface),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row {
                Text("Total", color = DebtColors.TextTertiary)
                Spacer(Modifier.weight(1f))
                Text(CurrencyFormatter.format(derived.entity.totalAmount), color = DebtColors.TextPrimary)
            }
            Row {
                Text("Paid", color = DebtColors.TextTertiary)
                Spacer(Modifier.weight(1f))
                Text(CurrencyFormatter.format(derived.paidAmount), color = DebtColors.Green)
            }
            Row {
                Text("Remaining", color = DebtColors.TextTertiary)
                Spacer(Modifier.weight(1f))
                Text(CurrencyFormatter.format(derived.remainingAmount), color = DebtColors.TextPrimary)
            }
            derived.entity.notes?.let {
                Spacer(Modifier.height(4.dp))
                Text(it, color = DebtColors.TextSecondary, fontSize = 14.sp)
            }
        }
    }
}
