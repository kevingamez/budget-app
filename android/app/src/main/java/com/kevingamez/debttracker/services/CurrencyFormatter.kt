package com.kevingamez.debttracker.services

import java.math.BigDecimal
import java.math.RoundingMode
import java.text.DecimalFormatSymbols
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

    /// Locale-aware parse for user-entered amounts (iOS `AmountInput` analog).
    /// The Decimal keyboard shows the device-locale decimal separator (a comma
    /// across much of Europe/Latin America); naive `toBigDecimalOrNull()` only
    /// accepts '.', so comma input is silently rejected or mangled. Strips
    /// grouping separators, normalizes the decimal mark, and returns null for
    /// blank/invalid input.
    fun parseAmount(input: String, locale: Locale = Locale.getDefault()): BigDecimal? {
        if (input.isBlank()) return null
        val decimalSep = DecimalFormatSymbols.getInstance(locale).decimalSeparator
        // If the locale separator appears, it's the decimal mark and '.' is
        // grouping; otherwise '.' is the decimal mark.
        val mark = if (decimalSep != '.' && input.contains(decimalSep)) decimalSep else '.'
        val sb = StringBuilder()
        var hasDecimal = false
        for (ch in input) {
            when {
                ch.isDigit() -> sb.append(ch)
                ch == mark && !hasDecimal -> { hasDecimal = true; sb.append('.') }
            }
            // Everything else (grouping separators, symbols, spaces) is dropped.
        }
        val canonical = sb.toString()
        if (canonical.isEmpty() || canonical == ".") return null
        return canonical.toBigDecimalOrNull()
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
