import XCTest

/// End-to-end UI tour of every primary surface. Driven from the `-uitest-mode`
/// launch arg in `UITestSupport`, which bypasses auth and pre-seeds sample data
/// so each test lands directly on `MainTabView`.
///
/// Every test attaches a screenshot at each interesting frame so the .xcresult
/// bundle doubles as a visual walkthrough.
/// The XCUITest target inherits the app's `SWIFT_DEFAULT_ACTOR_ISOLATION =
/// MainActor`, which would make the override signatures clash with
/// `XCTestCase`'s nonisolated versions under Swift 6. Pinning the class to
/// `nonisolated` keeps the overrides legal; UI assertions don't need to
/// touch any MainActor state.
nonisolated final class FullAppTour: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uitest-mode"]
        app.launch()
        // First launch needs a beat for SwiftData seeding + initial render.
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        sleep(2)
        snapshot("00-launch")
    }

    override func tearDownWithError() throws {
        snapshot("99-final")
    }

    // MARK: - Tabs

    func test01_DashboardTab() throws {
        // Default tab on launch.
        tapTabIfPresent("Dashboard")
        sleep(1)
        snapshot("01-dashboard")
        // Scroll vertically inside the tab to surface the bottom sections.
        app.swipeUp()
        sleep(1)
        snapshot("01-dashboard-scrolled")
        app.swipeDown()
    }

    func test02_DebtsTabAndAdd() throws {
        tapTabIfPresent("Debts")
        sleep(1)
        snapshot("02-debts-list")

        // Open Add Debt sheet — the toolbar plus button is the only "Add"
        // affordance. XCUITest sees system-image buttons as elements named
        // by their label/accessibility identifier.
        let addButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'add' OR label CONTAINS[c] 'new'"))
        if addButtons.count > 0 {
            addButtons.element(boundBy: 0).tap()
            sleep(1)
            snapshot("02-add-debt-sheet")
            // Dismiss whether by close button or pull-down. Most reliable: tap Cancel.
            let cancel = app.buttons["Cancel"]
            if cancel.waitForExistence(timeout: 2) {
                cancel.tap()
            } else {
                app.swipeDown(velocity: .fast)
            }
            sleep(1)
        }

        // Tap the first debt row to drill into the detail.
        let firstRow = app.scrollViews.firstMatch.otherElements.buttons.firstMatch
        if firstRow.exists {
            firstRow.tap()
            sleep(1)
            snapshot("02-debt-detail")
            // Back to list.
            let back = app.navigationBars.buttons.element(boundBy: 0)
            if back.exists { back.tap() }
            sleep(1)
        } else {
            // Fall back: tap any visible button that isn't the tab bar.
            let anyDebtRow = app.collectionViews.cells.firstMatch
            if anyDebtRow.waitForExistence(timeout: 2) {
                anyDebtRow.tap()
                sleep(1)
                snapshot("02-debt-detail-fallback")
                if app.navigationBars.buttons.element(boundBy: 0).exists {
                    app.navigationBars.buttons.element(boundBy: 0).tap()
                }
            }
        }
    }

    func test03_ActivityTab() throws {
        tapTabIfPresent("Activity")
        sleep(1)
        snapshot("03-activity-feed")
        app.swipeUp()
        sleep(1)
        snapshot("03-activity-scrolled")
    }

    func test04_SettingsTab() throws {
        tapTabIfPresent("Settings")
        sleep(1)
        snapshot("04-settings-top")
        app.swipeUp()
        sleep(1)
        snapshot("04-settings-mid")
        app.swipeUp()
        sleep(1)
        snapshot("04-settings-bottom")

        // Export Summary — exercises the new clipboard expiration path.
        let exportButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Export'")).firstMatch
        if exportButton.exists {
            exportButton.tap()
            sleep(1)
            snapshot("04-settings-export-alert")
            let ok = app.buttons["OK"]
            if ok.waitForExistence(timeout: 2) { ok.tap() }
        }
    }

    func test05_AddDebtFlow() throws {
        tapTabIfPresent("Debts")
        sleep(1)

        let addButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'add' OR label CONTAINS[c] 'new' OR label CONTAINS[c] '+'"))
        guard addButtons.count > 0 else {
            snapshot("05-no-add-button-found")
            return
        }
        addButtons.element(boundBy: 0).tap()
        sleep(1)
        snapshot("05-add-debt-empty")

        // Type in the title field — first textField on the form.
        let titleField = app.textFields.firstMatch
        if titleField.waitForExistence(timeout: 2) {
            titleField.tap()
            titleField.typeText("UITest Debt")
            snapshot("05-add-debt-title-entered")
        }

        // Dismiss without saving so we don't pollute SwiftData for the next test
        // (each test starts from a fresh seed via UITestSupport, but Cancel is
        // still the polite path).
        let cancel = app.buttons["Cancel"]
        if cancel.waitForExistence(timeout: 2) {
            cancel.tap()
        } else {
            app.swipeDown(velocity: .fast)
        }
        sleep(1)
    }

    // MARK: - Helpers

    /// Tap a tab by its visible label. Falls back to tab index if the label
    /// doesn't match (handles non-EN locales since we force EN in UITest mode).
    private func tapTabIfPresent(_ name: String) {
        let labelMatch = app.tabBars.buttons[name]
        if labelMatch.waitForExistence(timeout: 5) {
            labelMatch.tap()
            return
        }
        // Sidebar (macOS) — try the buttons by name.
        let sideMatch = app.buttons[name]
        if sideMatch.waitForExistence(timeout: 2) {
            sideMatch.tap()
        }
    }

    /// Attach a screenshot to the test result with a sortable name.
    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
