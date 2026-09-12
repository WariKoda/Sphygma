package de.bdgraue.sphygma

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent
import de.bdgraue.sphygma.reminders.ReminderPlugin
import de.bdgraue.sphygma.reminders.AndroidReminderPorts

// FlutterFragmentActivity statt FlutterActivity: das health-Plugin
// registriert seinen Berechtigungs-Launcher ueber
// ComponentActivity.registerForActivityResult (HealthPlugin.kt); mit einer
// blossen FlutterActivity meldet es "Permission launcher not found" und
// der Health-Connect-Dialog erscheint nie.
class MainActivity : FlutterFragmentActivity() {
    private var reminders: ReminderPlugin? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        reminders = ReminderPlugin(this, flutterEngine.dartExecutor.binaryMessenger)
    }
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action == AndroidReminderPorts.ACTION_OPEN_PLAN) reminders?.openPlan()
    }
    override fun onResume() {
        super.onResume()
        reminders?.resumed()
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        reminders?.permissionResult(requestCode)
    }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        reminders?.dispose()
        reminders = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
