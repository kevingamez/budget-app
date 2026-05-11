import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestPermission() async -> Bool
    func checkPermissionStatus() async -> UNAuthorizationStatus
    func scheduleReminder(id: String, personName: String, title: String, direction: DebtDirection, reminderDate: Date, existingIdentifier: String?) async -> String?
    func cancelReminder(identifier: String)
    func cancelAllReminders()
}

final class NotificationService: NotificationServiceProtocol, Sendable {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleReminder(
        id: String,
        personName: String,
        title: String,
        direction: DebtDirection,
        reminderDate: Date,
        existingIdentifier: String?
    ) async -> String? {
        // Cancel existing reminder if any
        if let existingId = existingIdentifier {
            cancelReminder(identifier: existingId)
        }

        let identifier = "debt-reminder-\(id)"

        let content = UNMutableNotificationContent()
        content.title = AppStrings.shared.tr("notification.title")
        // Body intentionally PII-free: counterparty names, debt titles, and amounts
        // would be visible on the lock screen without authentication.
        // Details are revealed in-app via the userInfo deep-link payload.
        content.body = AppStrings.shared.tr("notification.body.generic")
        content.sound = .default
        content.userInfo = [
            "debtId": id,
            "direction": direction == .owedToMe ? "owedToMe" : "iOwe",
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
            return identifier
        } catch {
            return nil
        }
    }

    func cancelReminder(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
