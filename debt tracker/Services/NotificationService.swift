import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestPermission() async -> Bool
    func scheduleReminder(id: String, personName: String, title: String, direction: DebtDirection, reminderDate: Date, existingIdentifier: String?) async -> String?
    func cancelReminder(identifier: String)
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
        content.title = "Debt Reminder"

        // Keep notification content generic for privacy
        let directionText = direction == .owedToMe ? "owes you" : "you owe"
        content.body = "Reminder: \(personName) \(directionText) — \(title)"
        content.sound = .default

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
    }
}
