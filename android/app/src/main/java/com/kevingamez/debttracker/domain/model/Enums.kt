package com.kevingamez.debttracker.domain.model

/// Mirrors iOS [DebtDirection]. The enum value names are the canonical Kotlin
/// identifiers and are persisted as-is to Room.
enum class DebtDirection { OWED_TO_ME, I_OWE }

/// Mirrors iOS [DebtStatus]. `derivedStatus` on the model recomputes most of
/// these from payments; only FORGIVEN is mutated by the user directly.
enum class DebtStatus { ACTIVE, PARTIALLY_PAID, PAID_OFF, OVERDUE, FORGIVEN }

enum class DebtCategoryType(val displayName: String, val emoji: String) {
    FOOD("Food", "🍽"),       // 🍽
    PERSONAL("Personal", "👤"),
    RENT("Rent", "🏠"),       // 🏠
    BUSINESS("Business", "💼"),
    TRAVEL("Travel", "✈️"),     // ✈
    EDUCATION("Education", "🎓"),
    FAMILY("Family", "👪"),
    MEDICAL("Medical", "🩺"),  // 🩺
    OTHER("Other", "📦"),     // 📦
}
