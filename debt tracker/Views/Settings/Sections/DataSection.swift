import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private let S = AppStrings.shared

struct DataSection: View {
    let onExport: () -> Void
    let onLoadSample: () -> Void
    let onClearAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(title: S.tr("settings.data"), icon: "externaldrive.fill")
                .padding(.bottom, 12)

            SettingsCard {
                VStack(spacing: 0) {
                    Button(action: onExport) {
                        SettingsRow(
                            icon: "doc.on.clipboard.fill",
                            iconColor: ColorTokens.primaryAccent,
                            title: S.tr("settings.exportSummary")
                        )
                    }

                    Divider().background(ColorTokens.surfaceBorder)

                    Button(action: onLoadSample) {
                        SettingsRow(
                            icon: "tray.and.arrow.down.fill",
                            iconColor: ColorTokens.gold,
                            title: S.tr("settings.loadSample")
                        )
                    }

                    Divider().background(ColorTokens.surfaceBorder)

                    Button(action: onClearAll) {
                        SettingsRow(
                            icon: "trash.fill",
                            iconColor: ColorTokens.red,
                            title: S.tr("settings.clearAll")
                        )
                    }
                }
            }
        }
    }
}

/// Pasteboard helper used by Settings's "Export Summary" action.
///
/// On iOS the payload is marked `.localOnly` (so it isn't pushed to other
/// devices via Universal Clipboard) and given a 60-second expiry so debt
/// names + amounts don't linger indefinitely in system paste history.
/// AppKit's NSPasteboard offers no equivalent expiration knob, so on macOS
/// the user must clear the clipboard themselves.
enum ClipboardWriter {
    static func write(_ string: String) {
        #if canImport(UIKit)
        let expiry = Date().addingTimeInterval(60)
        UIPasteboard.general.setItems(
            [["public.utf8-plain-text": string]],
            options: [
                .localOnly: true,
                .expirationDate: expiry,
            ]
        )
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #endif
    }
}
