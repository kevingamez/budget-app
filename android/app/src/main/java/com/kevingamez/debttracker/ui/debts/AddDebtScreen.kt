package com.kevingamez.debttracker.ui.debts

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.kevingamez.debttracker.R
import com.kevingamez.debttracker.domain.model.DebtDirection
import com.kevingamez.debttracker.ui.theme.DebtColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddDebtScreen(onDone: () -> Unit, vm: AddDebtViewModel = hiltViewModel()) {
    var title by remember { mutableStateOf("") }
    var amount by remember { mutableStateOf("") }
    var direction by remember { mutableStateOf(DebtDirection.OWED_TO_ME) }
    var personName by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.add_debt_title)) },
                navigationIcon = {
                    TextButton(onClick = onDone) { Text(stringResource(R.string.common_cancel)) }
                },
                actions = {
                    TextButton(
                        enabled = title.isNotBlank() && amount.toBigDecimalOrNull() != null,
                        onClick = {
                            vm.save(
                                title = title.trim().take(120),
                                amountString = amount,
                                direction = direction,
                                personName = personName.trim().take(120),
                                notes = notes.trim().take(2000).ifBlank { null }
                            )
                            onDone()
                        }
                    ) { Text(stringResource(R.string.add_debt_save)) }
                }
            )
        }
    ) { padding ->
        Column(
            Modifier.fillMaxSize().background(DebtColors.Background).padding(padding)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Spacer(Modifier.height(12.dp))
            Text("$ ${amount.ifBlank { "0.00" }}",
                color = DebtColors.TextPrimary, fontSize = 36.sp, fontWeight = FontWeight.Bold)
            OutlinedTextField(
                value = amount, onValueChange = { amount = it.filter { c -> c.isDigit() || c == '.' } },
                placeholder = { Text("0.00") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp)
            )
            DirectionPicker(direction, { direction = it })
            OutlinedTextField(
                value = title, onValueChange = { title = it },
                label = { Text(stringResource(R.string.add_debt_description)) },
                placeholder = { Text(stringResource(R.string.add_debt_description_hint)) },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp)
            )
            OutlinedTextField(
                value = personName, onValueChange = { personName = it },
                label = { Text(stringResource(R.string.add_debt_person)) },
                placeholder = { Text(stringResource(R.string.add_debt_person_hint)) },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp)
            )
            OutlinedTextField(
                value = notes, onValueChange = { notes = it },
                label = { Text(stringResource(R.string.add_debt_notes)) },
                placeholder = { Text(stringResource(R.string.add_debt_notes_hint)) },
                minLines = 3,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp)
            )
        }
    }
}

@Composable
private fun DirectionPicker(current: DebtDirection, onChange: (DebtDirection) -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        DirectionButton(
            label = stringResource(R.string.add_debt_someone_owes),
            selected = current == DebtDirection.OWED_TO_ME,
            accent = DebtColors.Green,
            modifier = Modifier.weight(1f),
            onClick = { onChange(DebtDirection.OWED_TO_ME) }
        )
        DirectionButton(
            label = stringResource(R.string.add_debt_i_owe),
            selected = current == DebtDirection.I_OWE,
            accent = DebtColors.Red,
            modifier = Modifier.weight(1f),
            onClick = { onChange(DebtDirection.I_OWE) }
        )
    }
}

@Composable
private fun DirectionButton(
    label: String, selected: Boolean,
    accent: androidx.compose.ui.graphics.Color,
    modifier: Modifier, onClick: () -> Unit
) {
    val bg = if (selected) accent.copy(alpha = 0.18f) else DebtColors.Surface
    OutlinedButton(
        onClick = onClick,
        modifier = modifier.height(56.dp),
        shape = RoundedCornerShape(14.dp),
        colors = ButtonDefaults.outlinedButtonColors(containerColor = bg),
        border = ButtonDefaults.outlinedButtonBorder.copy(
            brush = androidx.compose.ui.graphics.SolidColor(if (selected) accent else DebtColors.SurfaceBorder)
        )
    ) { Text(label, color = if (selected) accent else DebtColors.TextSecondary) }
}
