package com.kevingamez.debttracker.ui.theme

import androidx.compose.ui.graphics.Color

/// Color tokens that mirror iOS [ColorTokens]. Hex values match the Swift side
/// so a screenshot from each platform is interchangeable.
object DebtColors {
    val Background = Color(0xFF0A0A0F)
    val Surface = Color(0xFF1A1A2E)
    val SurfaceBorder = Color(0x33FFFFFF)
    val Card = Color(0xFF151528)

    val TextPrimary = Color(0xFFFFFFFF)
    val TextSecondary = Color(0xCCFFFFFF)
    val TextTertiary = Color(0x99FFFFFF)

    val PrimaryAccent = Color(0xFF7C5CFC)
    val PrimaryAccentMuted = Color(0x337C5CFC)
    val Green = Color(0xFF10B981)
    val Red = Color(0xFFEF4444)
    val Gold = Color(0xFFF59E0B)
}
