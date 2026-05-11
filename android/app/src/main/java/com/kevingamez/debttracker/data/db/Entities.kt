package com.kevingamez.debttracker.data.db

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import com.kevingamez.debttracker.domain.model.DebtCategoryType
import com.kevingamez.debttracker.domain.model.DebtDirection
import com.kevingamez.debttracker.domain.model.DebtStatus
import java.math.BigDecimal
import java.time.Instant
import java.util.UUID

/// Mirrors iOS [Person] @Model. Optional relationships preserved so the
/// Supabase mirror can `NULL`-out a person reference without dropping debts.
@Entity(tableName = "persons")
data class PersonEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val name: String,
    val phone: String? = null,
    val email: String? = null,
    val photoPath: String? = null,
    val createdAt: Instant = Instant.now(),
)

@Entity(
    tableName = "categories",
    indices = [Index("type", unique = true)]
)
data class CategoryEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val type: DebtCategoryType,
    val customName: String? = null,
) {
    val name: String get() = customName ?: type.displayName
}

@Entity(
    tableName = "debts",
    foreignKeys = [
        ForeignKey(
            entity = PersonEntity::class,
            parentColumns = ["id"],
            childColumns = ["personId"],
            onDelete = ForeignKey.SET_NULL
        ),
        ForeignKey(
            entity = CategoryEntity::class,
            parentColumns = ["id"],
            childColumns = ["categoryId"],
            onDelete = ForeignKey.SET_NULL
        ),
    ],
    indices = [Index("personId"), Index("categoryId")]
)
data class DebtEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val title: String,
    val totalAmount: BigDecimal,
    val direction: DebtDirection,
    val status: DebtStatus = DebtStatus.ACTIVE,
    val dueDate: Instant? = null,
    val notes: String? = null,
    val personId: String? = null,
    val categoryId: String? = null,
    val reminderEnabled: Boolean = false,
    val reminderDate: Instant? = null,
    val notificationIdentifier: String? = null,
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now(),
)

@Entity(
    tableName = "payments",
    foreignKeys = [
        ForeignKey(
            entity = DebtEntity::class,
            parentColumns = ["id"],
            childColumns = ["debtId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("debtId")]
)
data class PaymentEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val debtId: String,
    val amount: BigDecimal,
    val date: Instant = Instant.now(),
    val notes: String? = null,
)
