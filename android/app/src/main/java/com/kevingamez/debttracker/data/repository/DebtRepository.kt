package com.kevingamez.debttracker.data.repository

import androidx.room.withTransaction
import com.kevingamez.debttracker.data.db.AppDatabase
import com.kevingamez.debttracker.data.db.CategoryDao
import com.kevingamez.debttracker.data.db.CategoryEntity
import com.kevingamez.debttracker.data.db.DebtDao
import com.kevingamez.debttracker.data.db.DebtEntity
import com.kevingamez.debttracker.data.db.PaymentDao
import com.kevingamez.debttracker.data.db.PaymentEntity
import com.kevingamez.debttracker.data.db.PersonDao
import com.kevingamez.debttracker.data.db.PersonEntity
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import javax.inject.Inject
import javax.inject.Singleton

/// Single facade over the four DAOs. Mirrors what the iOS views get from
/// `@Query` + ViewModel logic — Flow streams of entities the UI observes.
@Singleton
class DebtRepository @Inject constructor(
    private val db: AppDatabase,
    private val debts: DebtDao,
    private val payments: PaymentDao,
    private val persons: PersonDao,
    private val categories: CategoryDao,
) {
    val debtsStream: Flow<List<DebtEntity>> = debts.observeAll()
    val paymentsStream: Flow<List<PaymentEntity>> = payments.observeAll()
    val personsStream: Flow<List<PersonEntity>> = persons.observeAll()
    val categoriesStream: Flow<List<CategoryEntity>> = categories.observeAll()

    /// Pair the debt list with all payments so the UI can compute remaining
    /// balances without an N+1 query. Same pattern as the iOS DashboardVM.
    fun debtsWithPayments(): Flow<Pair<List<DebtEntity>, List<PaymentEntity>>> =
        combine(debtsStream, paymentsStream) { d, p -> d to p }

    suspend fun upsertDebt(debt: DebtEntity) = debts.upsert(debt)
    suspend fun deleteDebt(debt: DebtEntity) = debts.delete(debt)
    suspend fun debt(id: String) = debts.byId(id)

    suspend fun upsertPayment(payment: PaymentEntity) = payments.upsert(payment)
    suspend fun deletePayment(payment: PaymentEntity) = payments.delete(payment)
    fun paymentsForDebt(debtId: String) = payments.observeForDebt(debtId)

    suspend fun upsertPerson(person: PersonEntity) = persons.upsert(person)
    suspend fun deletePerson(person: PersonEntity) = persons.delete(person)
    suspend fun person(id: String) = persons.byId(id)

    suspend fun ensureCategory(category: CategoryEntity) = categories.insert(category)

    /// Used by Settings → "Clear All Data" and by sign-out cleanup. Wrapped in a
    /// single Room transaction so the four deletes commit atomically: a
    /// cancellation (navigating away tears down the caller's scope) or process
    /// death mid-wipe can no longer leave a half-cleared DB (e.g. payments gone
    /// but debts remaining, or residual PII after a "successful" sign-out wipe).
    /// Order matters: payments first (FK to debts), then debts/people/categories.
    suspend fun wipeAll() = db.withTransaction {
        payments.deleteAll()
        debts.deleteAll()
        persons.deleteAll()
        categories.deleteAll()
    }
}
