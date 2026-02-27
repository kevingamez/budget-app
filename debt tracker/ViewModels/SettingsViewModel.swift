import Foundation
import SwiftData
import UserNotifications
import LocalAuthentication

private let S = AppStrings.shared

@Observable
final class SettingsViewModel {
    var notificationsEnabled = false
    var notificationStatus: UNAuthorizationStatus = .notDetermined
    var showClearConfirmation = false
    var showSeedConfirmation = false
    var dataSeedComplete = false
    var showExportedAlert = false

    // Stats
    var totalDebtsCount: Int = 0
    var totalAmountTracked: Decimal = 0
    var totalPaidOff: Int = 0
    var averageDebtAmount: Decimal = 0
    var totalPersons: Int = 0
    var totalPayments: Int = 0
    var totalPaymentAmount: Decimal = 0

    // Biometrics
    var biometricsAvailable = false
    var biometricType: LABiometryType = .none

    func refreshStats(debts: [Debt], payments: [Payment], persons: [Person]) {
        totalDebtsCount = debts.count
        totalAmountTracked = debts.reduce(Decimal.zero) { $0 + $1.totalAmount }
        totalPaidOff = debts.filter { $0.derivedStatus == .paidOff || $0.derivedStatus == .forgiven }.count
        averageDebtAmount = debts.isEmpty ? 0 : totalAmountTracked / Decimal(debts.count)
        totalPersons = persons.count
        totalPayments = payments.count
        totalPaymentAmount = payments.reduce(Decimal.zero) { $0 + $1.amount }
    }

    func checkBiometrics() {
        let context = LAContext()
        var error: NSError?
        biometricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometricType = context.biometryType
    }

    var biometricLabel: String {
        switch biometricType {
        case .faceID: S.tr("biometric.faceId")
        case .touchID: S.tr("biometric.touchId")
        case .opticID: S.tr("biometric.opticId")
        default: S.tr("biometric.biometrics")
        }
    }

    var biometricIcon: String {
        switch biometricType {
        case .faceID: "faceid"
        case .touchID: "touchid"
        default: "lock.shield.fill"
        }
    }

    func checkNotificationStatus() async {
        notificationStatus = await NotificationService.shared.checkPermissionStatus()
        notificationsEnabled = notificationStatus == .authorized
    }

    func seedSampleData(context: ModelContext) {
        SampleDataService.seedSampleData(context: context)
        dataSeedComplete = true
    }

    func clearAllData(context: ModelContext) {
        SampleDataService.clearAll(context: context)
    }

    func exportSummary(debts: [Debt], payments: [Payment]) -> String {
        var lines: [String] = []
        lines.append(S.tr("export.title"))
        lines.append(S.tr("export.generated", Date().shortFormatted))
        lines.append(String(repeating: "\u{2014}", count: 40))
        lines.append("")

        let activeDebts = debts.filter { $0.derivedStatus != .paidOff && $0.derivedStatus != .forgiven }
        let owedToMe = activeDebts.filter { $0.direction == .owedToMe }
        let iOwe = activeDebts.filter { $0.direction == .iOwe }

        let owedToMeTotal = owedToMe.reduce(Decimal.zero) { $0 + $1.remainingAmount }
        let iOweTotal = iOwe.reduce(Decimal.zero) { $0 + $1.remainingAmount }

        lines.append(S.tr("export.overview"))
        lines.append("  \(S.tr("export.totalActive", "\(activeDebts.count)"))")
        lines.append("  \(S.tr("export.owedToMe", "\(owedToMeTotal.currencyFormatted) (\(owedToMe.count))"))")
        lines.append("  \(S.tr("export.iOwe", "\(iOweTotal.currencyFormatted) (\(iOwe.count))"))")
        lines.append("  \(S.tr("export.netBalance", (owedToMeTotal - iOweTotal).currencyFormatted))")
        lines.append("")

        if !owedToMe.isEmpty {
            lines.append(S.tr("export.owedToMeSection"))
            for debt in owedToMe {
                lines.append("  \u{2022} \(debt.personName) \u{2014} \(debt.remainingAmount.currencyFormatted) \u{2014} \(debt.title)")
            }
            lines.append("")
        }

        if !iOwe.isEmpty {
            lines.append(S.tr("export.iOweSection"))
            for debt in iOwe {
                lines.append("  \u{2022} \(debt.personName) \u{2014} \(debt.remainingAmount.currencyFormatted) \u{2014} \(debt.title)")
            }
            lines.append("")
        }

        let completed = debts.filter { $0.derivedStatus == .paidOff || $0.derivedStatus == .forgiven }
        if !completed.isEmpty {
            lines.append(S.tr("export.completed", "\(completed.count)"))
            for debt in completed {
                let status = debt.derivedStatus == .forgiven ? S.tr("status.forgiven") : S.tr("status.paidOff")
                lines.append("  \u{2022} \(debt.personName) \u{2014} \(debt.totalAmount.currencyFormatted) \u{2014} \(status)")
            }
        }

        return lines.joined(separator: "\n")
    }
}
