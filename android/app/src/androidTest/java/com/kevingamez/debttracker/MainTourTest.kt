package com.kevingamez.debttracker

import android.content.Intent
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createEmptyComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.core.app.ActivityScenario
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/// Mirrors the iOS XCUITest tour. Launches MainActivity with `uitest=true`
/// so AuthScreen + BiometricGate are bypassed and RootViewModel seeds the
/// sample fixtures.
///
/// Asserts on seeded-data content (debt titles, person names, payment notes)
/// rather than localized UI labels — and uses stable testTags on the bottom
/// nav — so the same tour works under any device locale (en/es/fr/pt/ja/ko).
@RunWith(AndroidJUnit4::class)
class MainTourTest {

    @get:Rule
    val composeRule = createEmptyComposeRule()

    private lateinit var scenario: ActivityScenario<MainActivity>

    @Before
    fun launchInUiTestMode() {
        System.setProperty("app.uitest", "true")
        val ctx = InstrumentationRegistry.getInstrumentation().targetContext
        val intent = Intent(ctx, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            .putExtra("uitest", true)
        scenario = ActivityScenario.launch(intent)
    }

    @After
    fun tearDown() {
        scenario.close()
    }

    private fun waitForText(text: String, timeoutMs: Long = 10_000) {
        composeRule.waitUntil(timeoutMillis = timeoutMs) {
            composeRule.onAllNodes(hasText(text, substring = true, ignoreCase = true))
                .fetchSemanticsNodes().isNotEmpty()
        }
    }

    private fun openTab(route: String) {
        composeRule.onNodeWithTag("tab-$route").performClick()
    }

    @Test
    fun dashboard_shows_seeded_payment_amount() {
        // "375" is from the unique seeded "First half" payment on Rent share.
        // Locale-independent (numbers).
        waitForText("375")
        composeRule.onNodeWithText("375", substring = true).assertIsDisplayed()
    }

    @Test
    fun debts_tab_lists_seeded_titles() {
        openTab("debts")
        waitForText("Birthday gift")
        // Use two seeded titles that both fit above the scroll fold so we
        // don't have to perform a scroll gesture.
        composeRule.onNodeWithText("Birthday gift", substring = true).assertIsDisplayed()
        composeRule.onNodeWithText("Gym membership", substring = true).assertIsDisplayed()
    }

    @Test
    fun activity_tab_lists_seeded_payment_notes() {
        openTab("activity")
        waitForText("Paid in full")
        composeRule.onNodeWithText("Paid in full", substring = true).assertIsDisplayed()
    }

    @Test
    fun debts_tab_shows_seeded_person_names() {
        openTab("debts")
        // "Maria Garcia" appears on the Debts list; seeded data is English
        // regardless of UI locale.
        waitForText("Maria Garcia")
        composeRule.onNodeWithText("Maria Garcia", substring = true).assertIsDisplayed()
    }
}
