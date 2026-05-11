package com.kevingamez.debttracker.services

import com.kevingamez.debttracker.data.db.CategoryEntity
import com.kevingamez.debttracker.data.db.DebtEntity
import com.kevingamez.debttracker.data.db.PaymentEntity
import com.kevingamez.debttracker.data.db.PersonEntity
import com.kevingamez.debttracker.data.repository.DebtRepository
import com.kevingamez.debttracker.domain.model.DebtCategoryType
import com.kevingamez.debttracker.domain.model.DebtDirection
import java.math.BigDecimal
import java.time.Instant
import java.time.temporal.ChronoUnit
import javax.inject.Inject
import javax.inject.Singleton

/// Direct port of iOS [SampleDataService]. Same 12 fixtures, same payments,
/// so screenshots between platforms line up.
@Singleton
class SampleDataService @Inject constructor(private val repo: DebtRepository) {

    suspend fun seed() {
        // Categories — one per type, ensure-once.
        val categoryByType = DebtCategoryType.values().associateWith { type ->
            CategoryEntity(type = type).also { repo.ensureCategory(it) }
        }

        // People.
        val alex = PersonEntity(name = "Alex Johnson", phone = "555-0101")
        val maria = PersonEntity(name = "Maria Garcia", email = "maria@email.com")
        val james = PersonEntity(name = "James Wilson")
        val sarah = PersonEntity(name = "Sarah Chen", phone = "555-0204", email = "sarah@email.com")
        val david = PersonEntity(name = "David Kim")
        val emma = PersonEntity(name = "Emma Thompson", phone = "555-0306")
        listOf(alex, maria, james, sarah, david, emma).forEach { repo.upsertPerson(it) }

        val now = Instant.now()
        fun days(offset: Long): Instant = now.plus(offset, ChronoUnit.DAYS)

        data class Seed(
            val title: String,
            val amount: String,
            val direction: DebtDirection,
            val person: PersonEntity,
            val dueOffsetDays: Long?,
            val notes: String? = null,
            val category: DebtCategoryType,
        )

        val seeds = listOf(
            Seed("Dinner at Nobu", "120.50", DebtDirection.OWED_TO_ME, alex, 14, null, DebtCategoryType.FOOD),
            Seed("Concert tickets", "85.00", DebtDirection.OWED_TO_ME, maria, 7, "Two tickets for the show", DebtCategoryType.PERSONAL),
            Seed("Rent share - Feb", "750.00", DebtDirection.I_OWE, james, -3, null, DebtCategoryType.RENT),
            Seed("Business supplies", "340.00", DebtDirection.OWED_TO_ME, sarah, 30, "Office equipment", DebtCategoryType.BUSINESS),
            Seed("Flight to NYC", "450.00", DebtDirection.I_OWE, david, 21, "Spring break trip", DebtCategoryType.TRAVEL),
            Seed("Textbooks", "200.00", DebtDirection.OWED_TO_ME, maria, null, "Semester books", DebtCategoryType.EDUCATION),
            Seed("Family dinner", "95.00", DebtDirection.I_OWE, emma, -1, null, DebtCategoryType.FAMILY),
            Seed("Gym membership", "60.00", DebtDirection.OWED_TO_ME, alex, 10, null, DebtCategoryType.PERSONAL),
            Seed("Prescription meds", "180.00", DebtDirection.I_OWE, sarah, 5, null, DebtCategoryType.MEDICAL),
            Seed("Grocery run", "67.30", DebtDirection.OWED_TO_ME, james, null, "Weekly groceries", DebtCategoryType.FOOD),
            Seed("Uber rides", "42.00", DebtDirection.I_OWE, david, null, null, DebtCategoryType.TRAVEL),
            Seed("Birthday gift", "55.00", DebtDirection.OWED_TO_ME, emma, 3, "Group gift contribution", DebtCategoryType.PERSONAL),
        )

        for (s in seeds) {
            val debt = DebtEntity(
                title = s.title,
                totalAmount = BigDecimal(s.amount),
                direction = s.direction,
                personId = s.person.id,
                categoryId = categoryByType[s.category]?.id,
                dueDate = s.dueOffsetDays?.let { days(it) },
                notes = s.notes,
            )
            repo.upsertDebt(debt)

            // Same payment fixtures as iOS so the Dashboard tile totals match.
            when (s.title) {
                "Rent share - Feb" ->
                    repo.upsertPayment(PaymentEntity(debtId = debt.id, amount = BigDecimal("375.00"), date = days(-5), notes = "First half"))
                "Concert tickets" ->
                    repo.upsertPayment(PaymentEntity(debtId = debt.id, amount = BigDecimal("40.00"), date = days(-2)))
                "Grocery run" ->
                    repo.upsertPayment(PaymentEntity(debtId = debt.id, amount = BigDecimal("67.30"), date = days(-1), notes = "Paid in full"))
                "Family dinner" -> {
                    repo.upsertPayment(PaymentEntity(debtId = debt.id, amount = BigDecimal("50.00"), date = days(-3)))
                    repo.upsertPayment(PaymentEntity(debtId = debt.id, amount = BigDecimal("45.00"), date = now, notes = "Remaining balance"))
                }
            }
        }
    }
}
