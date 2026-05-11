package com.kevingamez.debttracker.ui.dashboard

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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.kevingamez.debttracker.R
import com.kevingamez.debttracker.services.CurrencyFormatter
import com.kevingamez.debttracker.ui.theme.DebtColors

@Composable
fun DashboardScreen(vm: DashboardViewModel = hiltViewModel()) {
    val s by vm.state.collectAsStateWithLifecycle()
    LazyColumn(
        modifier = Modifier.fillMaxSize().background(DebtColors.Background),
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        item { Header() }
        item { HeroBalance(s) }
        item { AccountCards(s) }
        item { InsightTiles(s) }
        item { RecentPaymentsHeader() }
        items(s.recentPayments, key = { it.id }) { p ->
            RecentPaymentRow(p.amount, p.date.toString())
        }
        item { LifetimeStats(s) }
    }
}

@Composable
private fun Header() {
    Column {
        Text(stringResource(R.string.dashboard_greeting),
            color = DebtColors.TextSecondary, fontSize = 14.sp)
        Text(stringResource(R.string.dashboard_overview),
            color = DebtColors.TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun HeroBalance(s: DashboardState) {
    Column(
        modifier = Modifier.fillMaxWidth().padding(vertical = 12.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(stringResource(R.string.dashboard_net_balance).uppercase(),
            color = DebtColors.TextTertiary, fontSize = 11.sp, letterSpacing = 1.5.sp)
        Spacer(Modifier.height(6.dp))
        Text(CurrencyFormatter.format(s.netBalance),
            color = DebtColors.TextPrimary, fontSize = 44.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(10.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Chip(stringResource(R.string.dashboard_owed_to_me) + "  " + CurrencyFormatter.format(s.totalOwedToMe), DebtColors.Green)
            Chip(stringResource(R.string.dashboard_i_owe) + "  " + CurrencyFormatter.format(s.totalIOwe), DebtColors.Red)
        }
    }
}

@Composable
private fun Chip(text: String, accent: androidx.compose.ui.graphics.Color) {
    Box(
        Modifier.clip(RoundedCornerShape(50)).background(accent.copy(alpha = 0.18f))
            .padding(horizontal = 12.dp, vertical = 6.dp)
    ) { Text(text, color = DebtColors.TextPrimary, fontSize = 13.sp) }
}

@Composable
private fun AccountCards(s: DashboardState) {
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        AccountCard(
            label = stringResource(R.string.dashboard_owed_to_me),
            amount = CurrencyFormatter.format(s.totalOwedToMe),
            sub = "${stringResource(R.string.dashboard_active_debts)} · ${s.activeDebtCount}",
            accent = DebtColors.Green,
            modifier = Modifier.weight(1f)
        )
        AccountCard(
            label = stringResource(R.string.dashboard_i_owe),
            amount = CurrencyFormatter.format(s.totalIOwe),
            sub = "${stringResource(R.string.dashboard_overdue)} · ${s.overdueCount}",
            accent = DebtColors.Red,
            modifier = Modifier.weight(1f)
        )
    }
}

@Composable
private fun AccountCard(
    label: String, amount: String, sub: String,
    accent: androidx.compose.ui.graphics.Color, modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
    ) {
        Column(Modifier.padding(16.dp)) {
            Text(label, color = accent, fontSize = 13.sp, fontWeight = FontWeight.Medium)
            Spacer(Modifier.height(4.dp))
            Text(amount, color = DebtColors.TextPrimary, fontSize = 22.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(4.dp))
            Text(sub, color = DebtColors.TextTertiary, fontSize = 12.sp)
        }
    }
}

@Composable
private fun InsightTiles(s: DashboardState) {
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        InsightTile(s.activeDebtCount.toString(), stringResource(R.string.dashboard_active_debts), DebtColors.PrimaryAccent, Modifier.weight(1f))
        InsightTile(s.overdueCount.toString(), stringResource(R.string.dashboard_overdue), DebtColors.Red, Modifier.weight(1f))
        InsightTile(s.almostPaidCount.toString(), stringResource(R.string.dashboard_almost_paid), DebtColors.Gold, Modifier.weight(1f))
    }
}

@Composable
private fun InsightTile(
    big: String, label: String,
    accent: androidx.compose.ui.graphics.Color, modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
    ) {
        Column(Modifier.padding(14.dp)) {
            Text(big, color = accent, fontSize = 26.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(2.dp))
            Text(label, color = DebtColors.TextTertiary, fontSize = 11.sp)
        }
    }
}

@Composable
private fun RecentPaymentsHeader() {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(stringResource(R.string.dashboard_recent_payments),
            color = DebtColors.TextPrimary, fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
        Spacer(Modifier.weight(1f))
        Text(stringResource(R.string.dashboard_see_all),
            color = DebtColors.PrimaryAccent, fontSize = 13.sp)
    }
}

@Composable
private fun RecentPaymentRow(amount: java.math.BigDecimal, isoDate: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
    ) {
        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(CurrencyFormatter.format(amount),
                color = DebtColors.Green, fontWeight = FontWeight.SemiBold)
            Spacer(Modifier.weight(1f))
            Text(isoDate.take(10), color = DebtColors.TextTertiary, fontSize = 12.sp)
        }
    }
}

@Composable
private fun LifetimeStats(s: DashboardState) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
    ) {
        Column(Modifier.padding(16.dp)) {
            Text(stringResource(R.string.dashboard_lifetime_stats).uppercase(),
                color = DebtColors.TextTertiary, fontSize = 11.sp, letterSpacing = 1.5.sp)
            Spacer(Modifier.height(10.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                StatCell(s.totalDebts.toString(), "Total Debts", Modifier.weight(1f))
                StatCell(CurrencyFormatter.compact(s.totalAmountTracked), "Amount Tracked", Modifier.weight(1f))
            }
            Spacer(Modifier.height(10.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                StatCell(s.paidOffCount.toString(), "Paid Off", Modifier.weight(1f))
                StatCell(CurrencyFormatter.format(s.averageAmount), "Avg. Debt", Modifier.weight(1f))
            }
        }
    }
}

@Composable
private fun StatCell(value: String, label: String, modifier: Modifier = Modifier) {
    Column(modifier) {
        Text(value, color = DebtColors.TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold)
        Text(label, color = DebtColors.TextTertiary, fontSize = 11.sp)
    }
}
