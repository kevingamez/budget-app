# Debt Tracker

A production-grade iOS app for managing personal debts and payments. Built entirely with SwiftUI and SwiftData, featuring a modern dark UI, real-time multi-language support, live currency conversion, biometric security, and iCloud sync readiness. Zero third-party dependencies.

## Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Features](#features)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Design System](#design-system)
- [Localization](#localization)
- [Services](#services)
- [CI/CD](#cicd)

## Project Overview

Debt Tracker is a personal finance tool for keeping track of money owed to you and money you owe others. It provides a unified interface for:

- Creating and managing debts with categories, due dates, and notes.
- Recording partial and full payments against any debt.
- Viewing a real-time dashboard with balance breakdowns and progress tracking.
- Browsing a chronological activity feed of all payments.
- Getting smart reminders via local notifications before due dates.
- Switching between 6 languages and 9 currencies instantly, without restarting.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | SwiftUI (Declarative UI) |
| **Persistence** | SwiftData (Swift-native ORM over Core Data) |
| **Sync** | CloudKit-ready architecture (all models compatible) |
| **Concurrency** | Swift 6 strict concurrency (`MainActor` isolation) |
| **Auth** | LocalAuthentication (Face ID, Touch ID, Optic ID) |
| **Notifications** | UserNotifications (local, on-device) |
| **Exchange Rates** | open.er-api.com (free tier, no API key, 1hr cache) |
| **Localization** | Custom runtime i18n engine (`AppStrings` singleton) |
| **CI** | GitHub Actions (Xcode build on macOS runner) |
| **Dependencies** | None. 100% Apple first-party frameworks |

## Architecture

The app follows **MVVM + SwiftData @Query**:

- **Views** own `@Query` for reactive data from SwiftData (source of truth).
- **ViewModels** use `@Observable` (Observation framework). They hold UI state (filters, sort, form fields) and mutation logic. They receive `ModelContext` as method parameters, never stored.
- **Models** are `@Model` (SwiftData) entities with computed properties.
- **Services** are singletons for cross-cutting concerns (localization, notifications, currency, sample data).
- **Theme** is a set of static enums for colors, typography, animations, and layout constants.

Data flow: `@Query` in Views &rarr; ViewModel filters/transforms &rarr; display. Mutations go through ViewModel methods that take `ModelContext` as a parameter.

## Features

### 1. Dashboard
Real-time financial overview with animated cards:
- **Balance Overview** &mdash; Net balance with "Owed to Me" vs "I Owe" breakdown and proportional bar.
- **Summary Cards** &mdash; Active debt count and overdue count (red gradient when > 0).
- **Debt Progress** &mdash; Up to 3 in-progress debts with animated progress bars.
- **Recent Activity** &mdash; Last 5 payments with person, amount, and relative date.
- **Lifetime Stats** &mdash; 6-card grid: Total Debts, Amount Tracked, Paid Off, Average Debt, People, Payments.

### 2. Debt Management
Full CRUD for debts with rich metadata:
- Create debts with amount, direction, person, category, due date, notes, and optional reminder.
- Filter by direction (All / Owed to Me / I Owe).
- Sort by date, due date, amount, or person name.
- Native `.searchable` search bar.
- Swipe actions for quick mark-as-paid and delete.
- Detail view with payment history, progress bar, and status badges.
- Edit title, category, due date, and notes inline.
- Forgive debt or delete with confirmation alerts.

### 3. Payment Tracking
- Record partial or full payments with optional notes.
- "Pay Full Amount" shortcut fills remaining balance.
- Payments are cascade-deleted when their parent debt is removed.
- Color-coded by debt direction (green for incoming, red for outgoing).

### 4. Activity Feed
- Chronological payment history grouped by: Today, Yesterday, This Week, This Month, Earlier.
- Filter by direction (All / Incoming / Outgoing).
- Timeline-style UI with colored dots and connecting lines.

### 5. Multi-Language Support
Instant runtime language switching across the entire app, no restart required:

| Code | Language | Flag |
|------|----------|------|
| `en` | English | US |
| `es` | Espanol | ES |
| `fr` | Francais | FR |
| `pt` | Portugues | BR |
| `ja` | Japanese | JP |
| `ko` | Korean | KR |

Language can be changed during onboarding or anytime in Settings > Profile.

### 6. Multi-Currency Support
9 currencies with live exchange rates:

| Code | Symbol | Name |
|------|--------|------|
| USD | $ | US Dollar |
| COP | $ | Peso Colombiano |
| EUR | &euro; | Euro |
| GBP | &pound; | Pound |
| MXN | $ | Peso Mexicano |
| JPY | &yen; | Yen |
| INR | &#8377; | Rupee |
| KRW | &#8361; | Won |
| BRL | R$ | Real |

Live exchange rates fetched from `open.er-api.com` with 1-hour cache. Includes a live currency converter widget in Appearance settings.

### 7. Smart Reminders
- Per-debt local notifications with custom date/time.
- Scheduled via `UNCalendarNotificationTrigger`.
- Generic notification content to protect financial privacy.
- Managed through the debt creation flow.

### 8. Biometric Security
- Face ID, Touch ID, and Optic ID (Vision Pro) support.
- Toggle in Settings > Security.
- Detects available biometric hardware and adapts UI accordingly.

### 9. Onboarding
Three-page guided setup:
1. **Welcome** &mdash; App intro with animated feature highlights.
2. **Language Selection** &mdash; Pick from 6 languages with live preview.
3. **Currency Selection** &mdash; Pick from 9 currencies.

### 10. Profile
- Profile photo via PhotosPicker (resized to 500x500, JPEG 80%).
- Display name.
- Language and currency preferences.

## Getting Started

### Prerequisites

- macOS with Xcode 16+
- iOS 17+ simulator or device

### Build & Run

```bash
# Clone
git clone git@github.com:kevingamez/budget-app.git
cd budget-app

# Build
xcodebuild -project "debt tracker.xcodeproj" \
  -scheme "debt tracker" \
  -destination "generic/platform=iOS Simulator" \
  -configuration Debug \
  build

# Or open in Xcode
open "debt tracker.xcodeproj"
```

### Sample Data

In **Debug** builds, sample data (6 people, 12 debts, payments) is automatically seeded on first launch. You can also load/clear sample data from Settings > Data Management.

## Project Structure

```
debt tracker/
├── Models/
│   ├── Debt.swift              — Central debt model (amount, direction, status, dates)
│   ├── Payment.swift           — Payment records linked to debts
│   ├── Person.swift            — People involved in debts (name, phone, email, photo)
│   ├── Category.swift          — Debt categories with icons and colors
│   └── Enums.swift             — DebtDirection, DebtStatus, DebtCategoryType
│
├── ViewModels/
│   ├── DebtsListViewModel.swift    — Filtering, sorting, bulk actions
│   ├── AddDebtViewModel.swift      — Debt creation form logic
│   ├── ActivityViewModel.swift     — Payment feed grouping and filtering
│   ├── SettingsViewModel.swift     — Export, biometrics, data management
│   └── OnboardingViewModel.swift   — Onboarding page navigation
│
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift         — Main dashboard screen
│   │   ├── BalanceOverviewCard.swift    — Net balance card
│   │   ├── SummaryCardView.swift       — Active/overdue count cards
│   │   ├── DebtProgressCard.swift      — In-progress debts
│   │   └── RecentActivityCard.swift    — Recent payments
│   ├── Debts/
│   │   ├── DebtsListView.swift         — Searchable debt list
│   │   ├── DebtRowView.swift           — Individual debt row
│   │   ├── DebtDetailView.swift        — Full debt detail
│   │   ├── AddDebtView.swift           — Create debt sheet
│   │   ├── EditDebtView.swift          — Edit debt sheet
│   │   └── PaymentEntryView.swift      — Record payment sheet
│   ├── Activity/
│   │   ├── ActivityFeedView.swift      — Payment timeline
│   │   └── ActivityRowView.swift       — Timeline row
│   ├── Settings/
│   │   ├── SettingsView.swift              — Settings hub
│   │   ├── ProfileSettingsView.swift       — Profile & preferences
│   │   ├── AppearanceSettingsView.swift    — Currency & direction
│   │   ├── NotificationSettingsView.swift  — Notification permissions
│   │   └── StatsView.swift                 — Lifetime stats grid
│   ├── Onboarding/
│   │   ├── OnboardingView.swift        — Paged onboarding container
│   │   ├── WelcomePage.swift           — Welcome screen
│   │   ├── LanguageSelectionPage.swift — Language picker
│   │   └── CurrencySelectionPage.swift — Currency picker
│   └── Components/
│       ├── AmountTextField.swift       — Currency input with formatting
│       ├── AnimatedProgressBar.swift   — Spring-animated progress bar
│       ├── GradientCard.swift          — Reusable gradient card
│       ├── EmptyStateView.swift        — Empty state placeholder
│       ├── CategoryPickerView.swift    — Horizontal category chips
│       └── PersonAvatarView.swift      — Circle avatar (photo or initials)
│
├── Theme/
│   ├── ColorTokens.swift       — Color palette and gradients
│   ├── Typography.swift        — Font styles (.rounded system-wide)
│   ├── Animations.swift        — Spring animation presets
│   └── AppTheme.swift          — Layout constants and view modifiers
│
├── Services/
│   ├── AppStrings.swift            — Runtime i18n engine (6 languages, ~200 keys)
│   ├── NotificationService.swift   — Local notification scheduling
│   ├── CurrencyService.swift       — Live exchange rates (open.er-api.com)
│   ├── SampleDataService.swift     — Demo data seeding
│   └── ProfilePhotoStorage.swift   — Profile image persistence
│
└── Extensions/
    ├── Color+.swift            — Hex color initializer
    ├── Date+.swift             — Relative date formatting
    ├── Decimal+.swift          — Currency formatting
    └── View+.swift             — Card style, pressable, staggered appear modifiers
```

## Data Models

### Debt
The central entity. Tracks a financial obligation between the user and another person.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `UUID` | Unique identifier |
| `title` | `String` | Description of the debt |
| `totalAmount` | `Decimal` | Original debt amount |
| `direction` | `DebtDirection` | `.owedToMe` or `.iOwe` |
| `status` | `DebtStatus` | `.active`, `.partiallyPaid`, `.paidOff`, `.overdue`, `.forgiven` |
| `dueDate` | `Date?` | Optional deadline |
| `notes` | `String?` | Optional notes |
| `reminderEnabled` | `Bool` | Whether a reminder is set |
| `reminderDate` | `Date?` | Reminder trigger date |
| `person` | `Person?` | Who the debt is with |
| `category` | `DebtCategory?` | Category classification |
| `payments` | `[Payment]` | Payment history (cascade delete) |

Computed: `paidAmount`, `remainingAmount`, `progressFraction`, `isOverdue`, `derivedStatus`.

### Payment
| Field | Type | Description |
|-------|------|-------------|
| `id` | `UUID` | Unique identifier |
| `amount` | `Decimal` | Payment amount |
| `date` | `Date` | When the payment was made |
| `notes` | `String?` | Optional notes |
| `debt` | `Debt?` | Parent debt (inverse relationship) |

### Person
| Field | Type | Description |
|-------|------|-------------|
| `id` | `UUID` | Unique identifier |
| `name` | `String` | Full name |
| `phone` | `String?` | Phone number |
| `email` | `String?` | Email address |
| `photoData` | `Data?` | Profile photo (external storage) |
| `debts` | `[Debt]` | All debts with this person |

### DebtCategory
9 built-in categories: Personal, Business, Family, Rent, Food, Travel, Medical, Education, Other. Each has a default SF Symbol icon and accent color.

## Design System

| Token | Value |
|-------|-------|
| Background | `#0A0A0F` (near-black) |
| Surface | `#1A1A2E` (navy) |
| Primary Accent | `#7C5CFC` (purple) |
| Green (income) | `#10B981` |
| Red (outgoing) | `#EF4444` |
| Gold | `#F59E0B` |
| Card Corner Radius | 20pt |
| Typography | `.rounded` system-wide, monospaced for currency |
| Animations | Spring-based (cards 0.5s, progress 0.8s, buttons 0.25s) |
| Dark Mode | Enforced globally |

## Localization

The app uses a custom `AppStrings` singleton instead of Apple's `.xcstrings` / String Catalog system. This enables instant in-app language switching without restart, which `.xcstrings` cannot do without hacky Bundle overrides.

**How it works:**
- `AppStrings.shared` is an `@Observable` singleton.
- All ~200 UI strings live in a static `[String: [String: String]]` dictionary keyed by `key -> language -> translation`.
- Every file uses `private let S = AppStrings.shared` and calls `S.tr("key")` or `S.tr("key", arg)`.
- Changing `AppStrings.shared.language` instantly updates all SwiftUI views via Observation.

**Key naming convention:** `"screen.element"` &mdash; e.g., `"dashboard.title"`, `"debts.empty.title"`, `"settings.section.general"`.

## Services

| Service | Description |
|---------|-------------|
| `AppStrings` | Runtime i18n with 6 languages and ~200 translation keys |
| `NotificationService` | Protocol-based local notification scheduling and cancellation |
| `CurrencyService` | Live exchange rates from open.er-api.com with 1hr cache |
| `SampleDataService` | Seeds 6 people, 12 debts, and payments for demo/testing |
| `ProfilePhotoStorage` | Saves profile photo to Documents (500x500, JPEG 80%) |

## CI/CD

GitHub Actions workflow at `.github/workflows/build.yml`:
- **Trigger:** Push or PR to `main`.
- **Runner:** `macos-15` with Xcode 16.
- **Job:** Builds the project for iOS Simulator with code signing disabled.

```bash
# Manual build (same as CI)
xcodebuild -project "debt tracker.xcodeproj" \
  -scheme "debt tracker" \
  -destination "generic/platform=iOS Simulator" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## About

Private project by Kevin Gamez.

**Repository:** [github.com/kevingamez/budget-app](https://github.com/kevingamez/budget-app)
