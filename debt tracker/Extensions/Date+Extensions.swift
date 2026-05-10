import Foundation

private let cachedRelativeFormatter: RelativeDateTimeFormatter = {
    let f = RelativeDateTimeFormatter()
    f.unitsStyle = .short
    return f
}()

private let cachedShortDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .none
    return f
}()

extension Date {
    var relativeFormatted: String {
        cachedRelativeFormatter.locale = Locale(identifier: AppStrings.shared.language)
        return cachedRelativeFormatter.localizedString(for: self, relativeTo: Date())
    }

    var shortFormatted: String {
        cachedShortDateFormatter.locale = Locale(identifier: AppStrings.shared.language)
        return cachedShortDateFormatter.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
}
