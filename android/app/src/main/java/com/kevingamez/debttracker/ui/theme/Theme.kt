package com.kevingamez.debttracker.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DebtDarkColorScheme = darkColorScheme(
    primary = DebtColors.PrimaryAccent,
    onPrimary = Color.White,
    primaryContainer = DebtColors.PrimaryAccentMuted,
    onPrimaryContainer = DebtColors.PrimaryAccent,
    secondary = DebtColors.Green,
    tertiary = DebtColors.Gold,
    background = DebtColors.Background,
    onBackground = DebtColors.TextPrimary,
    surface = DebtColors.Surface,
    onSurface = DebtColors.TextPrimary,
    surfaceVariant = DebtColors.Card,
    onSurfaceVariant = DebtColors.TextSecondary,
    error = DebtColors.Red,
    onError = Color.White,
)

/// Mirrors iOS — dark mode is enforced. `darkTheme` argument is honored for
/// preview tooling but the production scheme is always dark.
@Composable
fun DebtTrackerTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = DebtDarkColorScheme,
        typography = DebtTypography,
        content = content
    )
}
