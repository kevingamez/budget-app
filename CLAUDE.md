# CLAUDE.md - Debt Tracker

## Project Overview
- **Type:** iOS app (SwiftUI + SwiftData)
- **Target:** iOS 17+ (deployment target 26.2)
- **Xcode project:** `debt tracker.xcodeproj` — uses `PBXFileSystemSynchronizedRootGroup` (new files on disk are auto-discovered, no pbxproj edits needed)
- **Bundle ID:** `kevingamez.debt-tracker`
- **Main source:** `debt tracker/` directory
- **Swift concurrency:** `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (Swift 6 strict concurrency)
- **Zero third-party dependencies** — all Apple first-party frameworks

## Architecture & Conventions

### Pattern: MVVM + SwiftData @Query
- **Views** own `@Query` for reactive data (source of truth from SwiftData)
- **ViewModels** use `@Observable` (Observation framework), hold UI state (filters, sort, form fields) and mutation logic
- **Models** are `@Model` (SwiftData) entities with computed properties
- ViewModels receive `ModelContext` as method parameters — never stored as properties
- Views never call `ModelContext.insert/delete` directly — always through ViewModel methods

### SwiftData Requirements (CloudKit Compatibility)
- All relationships must be optional
- Arrays default to `[]`
- No `@Attribute(.unique)` — CloudKit doesn't support unique constraints
- UUIDs set in `init()`, not via @Attribute
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
│   ├── Dashboard/   — Dashboard tab views
│   ├── Debts/       — Debt CRUD views
│   ├── Activity/    — Payment history feed
│   ├── Settings/    — Settings & notifications
│   └── Components/  — Reusable UI components
├── Theme/           — ColorTokens, Typography, Animations, AppTheme
├── Services/        — NotificationService, SampleDataService
└── Extensions/      — Color+, Decimal+, Date+, View+
```

### Naming Conventions
- Model: `Debt`, `Payment`, `Person`, `DebtCategory`
- ViewModel: `{Feature}ViewModel` (e.g., `DebtsListViewModel`)
- View: `{Feature}View` (e.g., `DebtsListView`, `DebtRowView`)
- Theme enums: `ColorTokens`, `AppTypography`, `AppAnimations`, `AppTheme`

### Security Practices
- No hardcoded secrets or API keys
- Input validation through `Decimal` parsing for all amounts
- No sensitive financial details in notification content
- CloudKit handles auth + encryption (Apple managed)
- Local notifications processed entirely on-device

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
