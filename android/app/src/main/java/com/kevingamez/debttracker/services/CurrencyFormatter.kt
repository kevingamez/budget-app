package com.kevingamez.debttracker.services

import java.math.BigDecimal
import java.math.RoundingMode
import java.text.NumberFormat
import java.util.Currency
import java.util.Locale

/// Currency formatting that matches iOS `Decimal.currencyFormatted`. Uses
/// the user's locale by default but accepts an explicit currency code so
/// the app can render in USD even when running on a phone set to PEN.
object CurrencyFormatter {
    fun format(amount: BigDecimal, currencyCode: String = "USD", locale: Locale = Locale.getDefault()): String {
        val nf = NumberFormat.getCurrencyInstance(locale).apply {
            currency = runCatching { Currency.getInstance(currencyCode) }.getOrDefault(Currency.getInstance("USD"))
            maximumFractionDigits = 2
            minimumFractionDigits = 2
            roundingMode = RoundingMode.HALF_EVEN
        }
        return nf.format(amount)
    }

    /// "$1.2K" / "$3.4M" — used in dashboard tiles where space is tight.
    fun compact(amount: BigDecimal, currencyCode: String = "USD"): String {
        val abs = amount.abs()
        val sign = if (amount.signum() < 0) "-" else ""
        val symbol = runCatching { Currency.getInstance(currencyCode).symbol }.getOrDefault("$")
        return when {
            abs >= BigDecimal(1_000_000) -> "$sign$symbol${abs.divide(BigDecimal(1_000_000), 1, RoundingMode.HALF_EVEN)}M"
            abs >= BigDecimal(1_000) -> "$sign$symbol${abs.divide(BigDecimal(1_000), 1, RoundingMode.HALF_EVEN)}K"
            else -> format(amount, currencyCode)
        }
    }
}
