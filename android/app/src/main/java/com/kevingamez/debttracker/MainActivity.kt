package com.kevingamez.debttracker

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.fragment.app.FragmentActivity
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.kevingamez.debttracker.security.BiometricGate
import com.kevingamez.debttracker.services.SupabaseAuthService
import com.kevingamez.debttracker.ui.auth.AuthScreen
import com.kevingamez.debttracker.ui.main.MainScaffold
import com.kevingamez.debttracker.ui.main.RootViewModel
import com.kevingamez.debttracker.ui.theme.DebtColors
import com.kevingamez.debttracker.ui.theme.DebtTrackerTheme
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

// FragmentActivity (not ComponentActivity) so we can host BiometricPrompt,
// which requires the fragment-manager plumbing. AndroidEntryPoint + Compose
// setContent both work on FragmentActivity.
@AndroidEntryPoint
class MainActivity : FragmentActivity() {

    @Inject lateinit var authService: SupabaseAuthService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            DebtTrackerTheme {
                Box(
                    Modifier.fillMaxSize().background(DebtColors.Background)
                ) {
                    val vm: RootViewModel = hiltViewModel()
                    val user by vm.currentUser.collectAsStateWithLifecycle()
                    val uitest = intent?.getBooleanExtra("uitest", false) == true
                        || System.getProperty("app.uitest") == "true"
                    if (!uitest && user == null) {
                        AuthScreen(onAuthenticated = { vm.refresh() })
                    } else if (uitest) {
                        // UI tests bypass the biometric gate so they can drive
                        // the app without a device authenticator enrolled.
                        MainScaffold()
                    } else {
                        BiometricGate { MainScaffold() }
                    }
                }
            }
        }
    }
}
