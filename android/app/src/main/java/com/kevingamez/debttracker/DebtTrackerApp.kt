package com.kevingamez.debttracker

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

/// Application entry point — Hilt's @HiltAndroidApp wires up DI for every
/// ViewModel and the Room database.
@HiltAndroidApp
class DebtTrackerApp : Application()
