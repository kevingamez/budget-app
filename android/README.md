# Debt Tracker — Android

Kotlin + Jetpack Compose port of the iOS app. Shares the Supabase backend
(`../supabase/`) — auth, AI Insights Edge Function, eventually a cloud sync —
but has its own local store (Room) so the apps work offline independently.

## Stack

| Concern       | iOS                  | Android                                    |
|---------------|----------------------|--------------------------------------------|
| UI            | SwiftUI              | Jetpack Compose + Material 3               |
| Local DB      | SwiftData            | Room                                       |
| State         | `@Observable`        | `ViewModel` + Kotlin `StateFlow`           |
| DI            | Singletons + manual  | Hilt                                       |
| Backend SDK   | `supabase-swift`     | `supabase-kt`                              |
| Persistence   | `@AppStorage`        | DataStore Preferences                      |
| Biometrics    | `LAContext`          | `androidx.biometric`                       |
| Images        | `Image` + Photos     | Coil                                       |
| Min OS        | iOS 17 (target 26.2) | Android 8 (API 26)                         |

## Setup

```sh
cd android
cp local.properties.example local.properties   # creates the file below
```

Edit `local.properties` and add:

```properties
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

These are read into `BuildConfig.SUPABASE_URL` / `BuildConfig.SUPABASE_ANON_KEY`
at build time — same pattern as `Secrets.plist` on iOS. Both files are
gitignored.

## Build + run

```sh
./gradlew :app:assembleDebug
./gradlew :app:installDebug
```

Or open in Android Studio (Koala or newer) and hit Run. First sync downloads
~1 GB of dependencies; subsequent builds are incremental.

## What's wired up

- Auth screen: email + password (sign-in / sign-up toggle). Apple + Google
  sign-in stubs in the service exist but are not yet bound to UI buttons —
  Google needs the SDK config + Apple is web-flow only on Android.
- Dashboard: hero balance, owed-to-me / I-owe cards, insight tiles, recent
  payments, lifetime stats. Numbers match the iOS Dashboard 1:1 when seeded
  from the same sample data.
- Debts tab: list with search + direction filter, add-debt form, detail view
  with payment history + record-payment dialog, delete.
- Activity tab: timeline of payments.
- Settings tab: account section, sign-out (wipes local DB), clear-all-data,
  reload-sample-data. The Appearance / Notifications / Biometric sub-screens
  from iOS are deferred.

## Sample data

A first-run check (`RootViewModel.seedIfEmpty`) populates 6 people, 9
categories, 12 debts, and 5 payments — the same fixtures as iOS
`SampleDataService.seedSampleData`. Either platform produces the same
dashboard numbers from the seed.

## File layout

```
app/src/main/java/com/kevingamez/debttracker/
├── DebtTrackerApp.kt          Application (@HiltAndroidApp)
├── MainActivity.kt
├── data/
│   ├── db/                    Room entities, DAOs, AppDatabase, Converters
│   └── repository/            DebtRepository (single facade over DAOs)
├── domain/model/              Enums + DerivedDebt (mirrors iOS computed props)
├── di/                        Hilt module
├── services/                  SampleData, SupabaseAuth, CurrencyFormatter
└── ui/
    ├── theme/                 Color / Theme / Typography (matches iOS tokens)
    ├── auth/                  AuthScreen + AuthViewModel
    ├── main/                  Root composable + bottom-nav scaffold
    ├── dashboard/             DashboardScreen + DashboardViewModel
    ├── debts/                 List + Add + Detail screens + VMs
    ├── activity/              Payment feed
    └── settings/              Settings stub
```
