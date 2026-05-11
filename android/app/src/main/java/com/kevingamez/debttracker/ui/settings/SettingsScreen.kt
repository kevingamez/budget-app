package com.kevingamez.debttracker.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.kevingamez.debttracker.R
import com.kevingamez.debttracker.ui.theme.DebtColors

/// Stub Settings screen. Top sections + sign-out wired; appearance picker,
/// biometric toggle, notification settings, and export-to-clipboard deferred
/// (those map 1:1 from iOS — easy to fill in next pass).
@Composable
fun SettingsScreen(vm: SettingsViewModel = hiltViewModel()) {
    val user by vm.user.collectAsState()
    Column(
        Modifier.fillMaxSize().background(DebtColors.Background).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(stringResource(R.string.settings_title),
            color = DebtColors.TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)

        SectionHeader(stringResource(R.string.settings_section_account))
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
        ) {
            Column(Modifier.padding(14.dp)) {
                Text(user?.email ?: stringResource(R.string.settings_signed_out),
                    color = DebtColors.TextPrimary)
                Text(stringResource(R.string.settings_signed_in_with, user?.provider ?: "—"),
                    color = DebtColors.TextTertiary, fontSize = 12.sp)
            }
        }
        Text(
            stringResource(R.string.auth_signout),
            color = DebtColors.Red,
            modifier = Modifier.clickable { vm.signOut() }.padding(8.dp)
        )

        SectionHeader(stringResource(R.string.settings_section_data))
        ActionRow(stringResource(R.string.settings_clear_all_data), DebtColors.Red) { vm.clearAllData() }
        ActionRow(stringResource(R.string.settings_load_sample_data), DebtColors.Gold) { vm.loadSampleData() }

        SectionHeader(stringResource(R.string.settings_section_about))
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
        ) {
            Column(Modifier.padding(14.dp)) {
                Row {
                    Text(stringResource(R.string.settings_version), color = DebtColors.TextSecondary)
                    Spacer(Modifier.weight(1f))
                    Text("1.0.0", color = DebtColors.TextPrimary)
                }
                Row {
                    Text(stringResource(R.string.settings_developer), color = DebtColors.TextSecondary)
                    Spacer(Modifier.weight(1f))
                    Text(stringResource(R.string.settings_developer_name), color = DebtColors.TextPrimary)
                }
            }
        }
    }
}

@Composable
private fun SectionHeader(text: String) {
    Text(text.uppercase(),
        color = DebtColors.TextTertiary, fontSize = 11.sp, letterSpacing = 1.5.sp,
        modifier = Modifier.padding(top = 12.dp, start = 4.dp))
}

@Composable
private fun ActionRow(label: String, color: androidx.compose.ui.graphics.Color, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = DebtColors.Surface)
    ) { Text(label, color = color, modifier = Modifier.padding(14.dp), fontWeight = FontWeight.Medium) }
}
