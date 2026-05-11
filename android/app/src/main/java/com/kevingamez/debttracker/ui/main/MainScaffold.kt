package com.kevingamez.debttracker.ui.main

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.kevingamez.debttracker.R
import com.kevingamez.debttracker.ui.activity.ActivityScreen
import com.kevingamez.debttracker.ui.dashboard.DashboardScreen
import com.kevingamez.debttracker.ui.debts.AddDebtScreen
import com.kevingamez.debttracker.ui.debts.DebtDetailScreen
import com.kevingamez.debttracker.ui.debts.DebtsListScreen
import com.kevingamez.debttracker.ui.settings.SettingsScreen

private enum class Tab(val route: String, val labelRes: Int) {
    Dashboard("dashboard", R.string.tab_dashboard),
    Debts("debts", R.string.tab_debts),
    Activity("activity", R.string.tab_activity),
    Settings("settings", R.string.tab_settings),
}

@Composable
fun MainScaffold() {
    val nav = rememberNavController()
    val backStack by nav.currentBackStackEntryAsState()
    val currentRoute = backStack?.destination?.route

    Scaffold(
        bottomBar = {
            NavigationBar {
                Tab.values().forEach { tab ->
                    NavigationBarItem(
                        // Stable testTag so instrumentation tests can find each
                        // tab regardless of the device's UI locale.
                        modifier = Modifier.testTag("tab-${tab.route}"),
                        selected = currentRoute == tab.route,
                        onClick = {
                            nav.navigate(tab.route) {
                                popUpTo(nav.graph.startDestinationId) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = { Icon(iconFor(tab), null) },
                        label = { Text(androidx.compose.ui.res.stringResource(tab.labelRes)) }
                    )
                }
            }
        }
    ) { padding ->
        NavHost(
            navController = nav,
            startDestination = Tab.Dashboard.route,
            modifier = Modifier.padding(padding)
        ) {
            composable(Tab.Dashboard.route) { DashboardScreen() }
            composable(Tab.Debts.route) {
                DebtsListScreen(
                    onAddDebt = { nav.navigate("add-debt") },
                    onDebtTap = { id -> nav.navigate("debt-detail/$id") }
                )
            }
            composable("add-debt") { AddDebtScreen(onDone = { nav.popBackStack() }) }
            composable("debt-detail/{id}") { entry ->
                val id = entry.arguments?.getString("id") ?: return@composable
                DebtDetailScreen(debtId = id, onClose = { nav.popBackStack() })
            }
            composable(Tab.Activity.route) { ActivityScreen() }
            composable(Tab.Settings.route) { SettingsScreen() }
        }
    }
}

private fun iconFor(tab: Tab) = when (tab) {
    Tab.Dashboard -> Icons.Filled.BarChart
    Tab.Debts -> Icons.Filled.AttachMoney
    Tab.Activity -> Icons.Filled.History
    Tab.Settings -> Icons.Filled.Settings
}
