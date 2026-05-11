package com.kevingamez.debttracker.data.db

import androidx.room.TypeConverter
import com.kevingamez.debttracker.domain.model.DebtCategoryType
import com.kevingamez.debttracker.domain.model.DebtDirection
import com.kevingamez.debttracker.domain.model.DebtStatus
import java.math.BigDecimal
import java.time.Instant

/// Type converters for Room. `BigDecimal` is stored as TEXT (exact, no
/// floating-point drift), `Instant` as epoch milliseconds, and enums as their
/// `name` string so additions/removals don't shift ordinal-based IDs.
class Converters {
    @TypeConverter fun instantToEpoch(value: Instant?): Long? = value?.toEpochMilli()
    @TypeConverter fun epochToInstant(value: Long?): Instant? = value?.let { Instant.ofEpochMilli(it) }

    @TypeConverter fun decimalToString(value: BigDecimal?): String? = value?.toPlainString()
    @TypeConverter fun stringToDecimal(value: String?): BigDecimal? = value?.let { BigDecimal(it) }

    @TypeConverter fun directionToString(value: DebtDirection?): String? = value?.name
    @TypeConverter fun stringToDirection(value: String?): DebtDirection? = value?.let { DebtDirection.valueOf(it) }

    @TypeConverter fun statusToString(value: DebtStatus?): String? = value?.name
    @TypeConverter fun stringToStatus(value: String?): DebtStatus? = value?.let { DebtStatus.valueOf(it) }

    @TypeConverter fun categoryTypeToString(value: DebtCategoryType?): String? = value?.name
    @TypeConverter fun stringToCategoryType(value: String?): DebtCategoryType? = value?.let { DebtCategoryType.valueOf(it) }
}
