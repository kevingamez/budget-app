package com.kevingamez.debttracker.ui.activity

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.kevingamez.debttracker.R
import com.kevingamez.debttracker.services.CurrencyFormatter
import com.kevingamez.debttracker.ui.theme.DebtColors

/// Minimal Activity feed: flat list of payments grouped by date label. The
/// fuller iOS version has Incoming/Outgoing filters; deferred to a follow-up.
@Composable
fun ActivityScreen(vm: ActivityViewModel = hiltViewModel()) {
    val state by vm.state.collectAsStateWithLifecycle()
    LazyColumn(
        modifier = Modifier.fillMaxSize().background(DebtColors.Background),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        item {
            Text(stringResource(R.string.activity_title),
                color = DebtColors.TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(4.dp))
        }
        items(state.rows, key = { it.id }) { row ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
            ) {
                Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                    Column(Modifier.weight(1f)) {
                        Text(row.personName, color = DebtColors.TextPrimary, fontWeight = FontWeight.SemiBold)
                        Text(row.subtitle, color = DebtColors.TextTertiary, fontSize = 12.sp)
                    }
                    Text(CurrencyFormatter.format(row.amount),
                        color = if (row.incoming) DebtColors.Green else DebtColors.Red,
                        fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}
