package com.kevingamez.debttracker.security

import android.content.Context
import android.content.ContextWrapper
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_WEAK
import androidx.biometric.BiometricManager.Authenticators.DEVICE_CREDENTIAL
import androidx.biometric.BiometricPrompt
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner

/// Wraps finance content in a BiometricPrompt gate.
///
/// On every fresh foreground entry the user must authenticate (biometric or
/// device PIN/pattern fallback). Background → foreground transitions re-lock,
/// so leaving the app in the recents view doesn't expose debt data to anyone
/// who later picks up the device.
///
/// If the device has no biometric *and* no screen lock at all we let the user
/// in — refusing to launch would soft-brick the app on devices the user owns,
/// and we still have at-rest SQLCipher encryption protecting the data.
@Composable
fun BiometricGate(content: @Composable () -> Unit) {
    val activity = LocalContext.current.findFragmentActivity()
        ?: error("BiometricGate requires a FragmentActivity host")
    val biometricManager = remember { BiometricManager.from(activity) }
    val authenticators = BIOMETRIC_STRONG or BIOMETRIC_WEAK or DEVICE_CREDENTIAL
    val canAuth = remember(biometricManager) {
        biometricManager.canAuthenticate(authenticators) ==
            BiometricManager.BIOMETRIC_SUCCESS
    }

    var unlocked by remember { mutableStateOf(!canAuth) }
    var lastError by remember { mutableStateOf<String?>(null) }

    // Re-lock when the app leaves the foreground so a coffee-shop snatch
    // doesn't expose decrypted screens.
    val lifecycleOwner = LocalLifecycleOwner.current
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_STOP && canAuth) {
                unlocked = false
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    val prompt = remember(activity) {
        BiometricPrompt(
            activity,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    unlocked = true
                    lastError = null
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    if (errorCode == BiometricPrompt.ERROR_USER_CANCELED ||
                        errorCode == BiometricPrompt.ERROR_NEGATIVE_BUTTON ||
                        errorCode == BiometricPrompt.ERROR_CANCELED
                    ) {
                        lastError = errString.toString()
                    } else {
                        lastError = errString.toString()
                    }
                }
            }
        )
    }

    val info = remember {
        BiometricPrompt.PromptInfo.Builder()
            .setTitle("Unlock Debt Tracker")
            .setSubtitle("Authenticate to view your debts")
            .setAllowedAuthenticators(authenticators)
            .build()
    }

    LaunchedEffect(unlocked) {
        if (!unlocked && canAuth) prompt.authenticate(info)
    }

    if (unlocked) {
        content()
    } else {
        LockScreen(error = lastError, onRetry = { prompt.authenticate(info) })
    }
}

private tailrec fun Context.findFragmentActivity(): FragmentActivity? = when (this) {
    is FragmentActivity -> this
    is ContextWrapper -> baseContext.findFragmentActivity()
    else -> null
}

@Composable
private fun LockScreen(error: String?, onRetry: () -> Unit) {
    Box(
        modifier = Modifier.fillMaxSize().background(Color(0xFF0A0A0F)),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.padding(32.dp),
        ) {
            Text("Locked", color = Color.White)
            if (error != null) {
                Text(error, color = Color(0xFFFCA5A5))
            }
            Button(onClick = onRetry) { Text("Unlock") }
        }
    }
}
