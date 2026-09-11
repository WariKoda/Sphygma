package de.bdgraue.sphygma.reminders

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        ReminderRuntime.executor.execute {
            try {
                val scheduler = ReminderRuntime.scheduler(context)
                if (intent.action == AndroidReminderPorts.ACTION_FIRE) {
                    require(intent.hasExtra("generation") && intent.hasExtra("key")) { "Unvollständiger Alarm" }
                    scheduler.deliver(intent.getLongExtra("generation", -1), requireNotNull(intent.getStringExtra("key")))
                } else scheduler.inspect(
                    timeChanged = intent.action == Intent.ACTION_TIME_CHANGED || intent.action == Intent.ACTION_TIMEZONE_CHANGED,
                    resetAlarms = intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == Intent.ACTION_MY_PACKAGE_REPLACED,
                )
            } catch (error: Exception) {
                // Never turn corrupt persistence into a fresh empty scheduler. App inspection surfaces it.
                Log.e("SphygmaReminders", "Erinnerungsabgleich fehlgeschlagen", error)
            } finally { pending.finish() }
        }
    }
}
