package de.bdgraue.sphygma

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity statt FlutterActivity: das health-Plugin
// registriert seinen Berechtigungs-Launcher ueber
// ComponentActivity.registerForActivityResult (HealthPlugin.kt); mit einer
// blossen FlutterActivity meldet es "Permission launcher not found" und
// der Health-Connect-Dialog erscheint nie.
class MainActivity : FlutterFragmentActivity()
