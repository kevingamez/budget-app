# AGENTS.md - Debt Tracker

## Project Overview
- **Type:** iOS/macOS app (SwiftUI + SwiftData) with a sibling Android port (`android/`) and a Supabase Edge Function (`supabase/functions/ai-insights/`).
- **Target:** iOS/macOS 17+ (deployment target 26.2). Android `minSdk = 26`, `targetSdk = 34`.
- **Xcode project:** `debt tracker.xcodeproj` — uses `PBXFileSystemSynchronizedRootGroup` (new files on disk are auto-discovered, no pbxproj edits needed)
- **Bundle ID:** `kevingamez.debt-tracker`
- **Main source:** `debt tracker/` directory (iOS/macOS), `android/app/src/main/java/com/kevingamez/debttracker/` (Android), `supabase/` (Edge Function + migrations).
- **Swift concurrency:** `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_VERSION = 6.0` (Swift 6 strict concurrency).
- **Third-party SDKs:** `supabase-swift` (auth + functions) on iOS; `supabase-kt`, Hilt, Room, SQLCipher, AndroidX Biometric on Android. No analytics, no ad SDKs.

## Architecture & Conventions

### File Size Limit (HARD)
- **No Swift file may exceed 300 lines.** Hard ceiling — no exceptions for "convenience".
- When approaching the limit, split by responsibility:
  - **Views** → extract sections into sibling subview files (e.g., `Views/Settings/Sections/`, `Views/Debts/DetailSections/`).
  - **Reusable subviews** → into their own file under `Views/Components/` if shared, or a feature-local folder if not.
  - **Static data dictionaries** (e.g., `AppStrings`) → split into `<Type>+<Topic>.swift` extension files holding `static let` slices; the main type merges them at first access.
  - **ViewModels** → if a single VM grows past 300, it's a smell that two responsibilities live there; split the model.
- Helpers (`SettingsRow`, `SettingsCard`, `BalanceChip`, etc.) belong in dedicated files when reused; mark them `private struct` if local to one parent file.
- Verify with: `find "debt tracker" -name "*.swift" -exec wc -l {} \; | sort -rn | head`

### Pattern: MVVM + SwiftData @Query
- **Views** own `@Query` for reactive data (source of truth from SwiftData)
- **ViewModels** use `@Observable` (Observation framework), hold UI state (filters, sort, form fields) and mutation logic
- **Models** are `@Model` (SwiftData) entities with computed properties
- ViewModels receive `ModelContext` as method parameters — never stored as properties
- Views never call `ModelContext.insert/delete` directly — always through ViewModel methods

### SwiftData Requirements
The store is **local-only** (Application Support `.sqlite` with `.complete` file protection). The schema is kept CloudKit-compatible so a future opt-in CloudKit container can be added without a migration, but no `CloudKitContainerOptions` is configured today and the app does not sync.
- All relationships must be optional (CloudKit-compatible)
- Arrays default to `[]`
- No `@Attribute(.unique)` (CloudKit-compatible)
- UUIDs set in `init()`, not via `@Attribute`
- Enum defaults must be fully qualified (e.g., `DebtDirection.owedToMe`, not `.owedToMe`) — SwiftData macro requirement
- `Decimal` for all monetary values (no floating-point)
- `@Attribute(.externalStorage)` on image/photo data
- Cascade delete: Debt → Payment

### File Structure
```
debt tracker/
├── Models/          — SwiftData @Model classes + Enums
├── ViewModels/      — @Observable ViewModels
├── Views/
│   ├── Dashboard/   — Dashboard tab views (Hero/Quick/Account/Insights/Transactions split per file)
│   ├── Debts/
│   │   └── DetailSections/ — DebtDetail subviews (Header, Person, Info, History, Actions)
│   ├── Activity/    — Payment history feed
│   ├── Settings/
│   │   ├── Sections/    — SettingsView subviews (Profile, Preferences, Security, Data, Account, About)
│   │   └── Appearance/  — AppearanceSettings subviews (ThemePicker, Currency, Converter, Direction)
│   └── Components/  — Reusable UI components (PersonAvatar, AmountTextField, GradientCard, …)
├── Theme/           — ColorTokens (reads from ThemeManager), AppThemePalette presets, Typography, Animations
├── Services/        — AppStrings (i18n) + AppStrings+<Topic>.swift extensions; NotificationService; SampleDataService
└── Extensions/      — Color+, Decimal+, Date+, View+
```

### Naming Conventions
- Model: `Debt`, `Payment`, `Person`, `DebtCategory`
- ViewModel: `{Feature}ViewModel` (e.g., `DebtsListViewModel`)
- View: `{Feature}View` (e.g., `DebtsListView`, `DebtRowView`)
- Theme enums: `ColorTokens`, `AppTypography`, `AppAnimations`, `AppTheme`

### Security Practices
- No hardcoded secrets or API keys (Anthropic key lives only as a Supabase Edge Function secret).
- Input validation through `Decimal` parsing for all amounts.
- No sensitive financial details in notification content.
- iOS: SwiftData store uses `.complete` file protection on the store + WAL/SHM + `.externalStorage` blob folder; biometric lock gates the UI.
- Android: Room DB is encrypted-at-rest via SQLCipher with a Keystore-wrapped passphrase in `EncryptedSharedPreferences`; `BiometricPrompt` gates the finance UI on every foreground entry.
- AI proxy (`supabase/functions/ai-insights/index.ts`) accepts only `{consent, snapshot}`, rejects unknown fields, caps body size, pins the model + token budget server-side, and rate-limits per user via the `ai_usage_increment` SECURITY DEFINER RPC (`supabase/migrations/`).
- Apple Sign In nonce is single-use: minted fresh in `onRequest` and cleared in every terminal path.

### Design System
- **Theme:** Dark modern — near-black background (#0A0A0F), navy surface (#1A1A2E)
- **Accents:** Purple primary (#7C5CFC), Green for income (#10B981), Red for outgoing (#EF4444), Gold (#F59E0B)
- **Typography:** `.rounded` design system-wide, monospaced for currency
- **Animations:** Spring-based — cards (0.5 response), progress (0.8), buttons (0.25), staggered list (0.05s delay/item)
- **Cards:** 20pt corner radius, 16pt padding, `.cardStyle()` modifier
- **Dark mode enforced** via `.preferredColorScheme(.dark)` at app root

## Key Decisions
- **Calendar.Component:** Use `.day` (not `.week`) — `.week` not available in current SDK
- **Category model name:** `DebtCategory` (not `Category`) to avoid Swift namespace conflicts
- **NotificationService:** Protocol-based (`NotificationServiceProtocol`) for testability, singleton `NotificationService.shared` for convenience
- **Tab navigation:** iOS 18+ `Tab` API with `TabView(selection:)`
- **Data flow:** `@Query` in views → ViewModel filters/transforms → display. Mutations go through ViewModel methods that take `ModelContext` parameter
- **`.searchable`** on DebtsListView for native search experience
- **Swipe actions** on debt rows for quick mark-as-paid and delete

### Localization System
- **`AppStrings`** — `@Observable` singleton with `[key: [lang: translation]]` dictionary
- **6 languages:** en, es, fr, pt, ja, ko — instant runtime switching via `AppStrings.shared.language`
- **Pattern:** `private let S = AppStrings.shared` at file top, then `S.tr("key")` or `S.tr("key", arg)`
- **Keys organized by screen:** `"dashboard.title"`, `"debts.empty.title"`, `"settings.section.general"`, etc.
- **No .xcstrings** — dictionary approach enables in-app language switching without restart

### CI/CD
- **GitHub Actions** — `.github/workflows/build.yml` builds on push/PR to `main`
- **Remote:** `git@github.com:kevingamez/budget-app.git`

### Git workflow rules
- **Always build before push.** Run `xcodebuild` for both iOS Simulator and macOS targets and confirm zero errors before `git push`. CI is best-effort and may not have every SDK installed; local verification is the source of truth.
  ```sh
  xcodebuild -project "debt tracker.xcodeproj" -scheme "debt tracker" \
    -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' -quiet build
  xcodebuild -project "debt tracker.xcodeproj" -scheme "debt tracker" \
    -destination 'platform=macOS' -quiet build
  ```
