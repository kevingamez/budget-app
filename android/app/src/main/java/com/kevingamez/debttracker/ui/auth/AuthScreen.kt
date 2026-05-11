package com.kevingamez.debttracker.ui.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.kevingamez.debttracker.R
import com.kevingamez.debttracker.ui.theme.DebtColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AuthScreen(onAuthenticated: () -> Unit, vm: AuthViewModel = hiltViewModel()) {
    val state by vm.state.collectAsState()
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var isSignUp by remember { mutableStateOf(false) }

    LaunchedEffect(state.authenticated) { if (state.authenticated) onAuthenticated() }

    Column(
        Modifier
            .fillMaxSize()
            .background(DebtColors.Background)
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        // Brand mark — placeholder until we ship the real asset.
        Box(
            Modifier.size(80.dp).clip(CircleShape).background(DebtColors.PrimaryAccent),
            contentAlignment = Alignment.Center
        ) { Text("$", color = Color.White, fontSize = 36.sp, fontWeight = FontWeight.Black) }

        Spacer(Modifier.height(24.dp))
        Text(
            stringResource(if (isSignUp) R.string.auth_signup else R.string.auth_welcome),
            color = DebtColors.TextPrimary,
            fontSize = 28.sp, fontWeight = FontWeight.Bold
        )
        Spacer(Modifier.height(6.dp))
        Text(
            stringResource(R.string.auth_subtitle),
            color = DebtColors.TextSecondary,
            textAlign = TextAlign.Center
        )

        Spacer(Modifier.height(32.dp))
        OutlinedTextField(
            value = email, onValueChange = { email = it },
            placeholder = { Text(stringResource(R.string.auth_email)) },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
        )
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(
            value = password, onValueChange = { password = it },
            placeholder = { Text(stringResource(R.string.auth_password)) },
            singleLine = true,
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
        )

        state.errorMessage?.let {
            Spacer(Modifier.height(8.dp))
            Text(it, color = DebtColors.Red)
        }

        Spacer(Modifier.height(20.dp))
        Button(
            onClick = { if (isSignUp) vm.signUp(email, password) else vm.signIn(email, password) },
            enabled = !state.loading && email.isNotBlank() && password.length >= 6,
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape = RoundedCornerShape(14.dp),
        ) {
            if (state.loading) CircularProgressIndicator(Modifier.size(20.dp), strokeWidth = 2.dp)
            else Text(stringResource(if (isSignUp) R.string.auth_signup else R.string.auth_signin))
        }

        Spacer(Modifier.height(12.dp))
        TextButton(onClick = { isSignUp = !isSignUp }) {
            Text(
                if (isSignUp) stringResource(R.string.auth_signin) else stringResource(R.string.auth_no_account),
                color = DebtColors.PrimaryAccent
            )
        }

        if (!vm.isConfigured) {
            Spacer(Modifier.height(16.dp))
            Text(
                "Supabase not configured — set SUPABASE_URL + SUPABASE_ANON_KEY in local.properties.",
                color = DebtColors.TextTertiary,
                textAlign = TextAlign.Center,
                fontSize = 12.sp
            )
        }
    }
}
