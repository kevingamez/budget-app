# Debt Tracker

A modern iOS app for tracking personal debts and payments, built with SwiftUI and SwiftData.

## Features

- **Debt Management** — Track money owed to you and money you owe others
- **Payment Tracking** — Record partial and full payments with notes
- **Dashboard** — Visual overview with balance cards and progress indicators
- **Activity Feed** — Chronological payment history with filters
- **Multi-Language** — English, Spanish, French, Portuguese, Japanese, Korean with instant in-app switching
- **Multi-Currency** — Support for USD, EUR, GBP, JPY, MXN, BRL, and more
- **Smart Reminders** — Local notifications for upcoming due dates
- **iCloud Sync** — CloudKit-backed SwiftData for cross-device sync
- **Dark Mode** — Modern dark theme with purple/green/red accent system

## Tech Stack

- **SwiftUI** + **SwiftData** (iOS 17+)
- **MVVM** architecture with `@Observable` ViewModels
- **CloudKit** for sync
- **Zero third-party dependencies**

## Requirements

- Xcode 16+
- iOS 17+ deployment target
- macOS for building

## Build

```bash
xcodebuild -project "debt tracker.xcodeproj" \
  -scheme "debt tracker" \
  -destination "generic/platform=iOS Simulator" \
  -configuration Debug \
  build
```

## Project Structure

```
debt tracker/
├── Models/        — SwiftData models + Enums
├── ViewModels/    — @Observable ViewModels
├── Views/         — SwiftUI views (Dashboard, Debts, Activity, Settings, Onboarding)
├── Theme/         — Design tokens (colors, typography, animations)
├── Services/      — AppStrings (i18n), Notifications, Sample Data
└── Extensions/    — Color+, Decimal+, Date+, View+
```

## Localization

The app uses a centralized `AppStrings` singleton for runtime language switching. All ~200 strings are translated into 6 languages. Language can be changed in onboarding or settings without restarting the app.

## License

Private project by Kevin Gamez.
