package de.bdgraue.sphygma.reminders

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import de.bdgraue.sphygma.MainActivity
import de.bdgraue.sphygma.R
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.time.Clock
import java.util.concurrent.Executors

object ReminderRuntime {
    val executor = Executors.newSingleThreadExecutor()
    fun scheduler(context: Context): ReminderScheduler {
        val ports = AndroidReminderPorts(context.applicationContext)
        return ReminderScheduler(ReminderStore(context.applicationContext), ports, ports, Clock.systemUTC()) {
            java.time.ZoneId.systemDefault()
        }
    }
}

class AndroidReminderPorts(private val context: Context) : AlarmPort, NotificationPort {
    private val alarms = context.getSystemService(AlarmManager::class.java)
    private val notifications = context.getSystemService(NotificationManager::class.java)
    init {
        notifications.createNotificationChannel(NotificationChannel(CHANNEL, "Messplan", NotificationManager.IMPORTANCE_DEFAULT))
    }
    override fun exactAllowed() = Build.VERSION.SDK_INT < 31 || alarms.canScheduleExactAlarms()
    override fun permissions() = Permissions(notifications.areNotificationsEnabled(), exactAllowed(),
        notifications.getNotificationChannel(CHANNEL)?.importance == NotificationManager.IMPORTANCE_NONE)
    private fun pending(identity: String, occurrence: Occurrence? = null, generation: Long = -1): PendingIntent {
        val intent = Intent(context, ReminderReceiver::class.java).setAction(ACTION_FIRE)
            .setData(Uri.parse("sphygma-reminder://alarm/$identity"))
        if (occurrence != null) intent.putExtra("generation", generation).putExtra("key", occurrence.key)
        return PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }
    override fun scheduleExact(occurrence: Occurrence, generation: Long) {
        // Permission is rechecked at the OS boundary; the scheduler handles only verified revocation.
        if (!exactAllowed()) return scheduleInexact(occurrence, generation)
        alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, occurrence.dueAt!!.toEpochMilli(), pending(occurrence.identity, occurrence, generation))
    }
    override fun scheduleInexact(occurrence: Occurrence, generation: Long) {
        alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, occurrence.dueAt!!.toEpochMilli(), pending(occurrence.identity, occurrence, generation))
    }
    override fun cancel(identity: String) { alarms.cancel(pending(identity)) }
    override fun post(occurrence: Occurrence) {
        val permission = permissions()
        check(permission.notificationsAllowed && !permission.channelBlocked) { "Benachrichtigungen sind blockiert" }
        val tap = Intent(context, MainActivity::class.java).setAction(ACTION_OPEN_PLAN)
            .setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val content = PendingIntent.getActivity(context, 0, tap, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val notification = Notification.Builder(context, CHANNEL).setSmallIcon(R.drawable.ic_reminder)
            .setContentTitle("Zeit für deine Messung")
            .setContentText("Messplan · Speicherplatz ${occurrence.userSlot}")
            .setContentIntent(content).setAutoCancel(true).setOnlyAlertOnce(true).build()
        notifications.notify(occurrence.key, 0, notification)
    }
    companion object {
        const val CHANNEL = "measurement_plan"
        const val ACTION_FIRE = "de.bdgraue.sphygma.REMINDER"
        const val ACTION_OPEN_PLAN = "de.bdgraue.sphygma.OPEN_PLAN"
    }
}

class ReminderPlugin(private val activity: MainActivity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "de.bdgraue.sphygma/reminders")
    private var accessResult: MethodChannel.Result? = null
    private var waitingForSettings = false
    private var openPlanRequested = activity.intent?.action == AndroidReminderPorts.ACTION_OPEN_PLAN
    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "replace" -> execute(result) { ReminderRuntime.scheduler(activity).replace(ReminderSnapshot.parse(call.arguments as Map<*, *>)) }
                "inspect" -> execute(result) { ReminderRuntime.scheduler(activity).inspect() }
                "requestAccess" -> requestAccess(result, settingsOnly = false)
                "openAccessSettings" -> requestAccess(result, settingsOnly = true)
                else -> result.notImplemented()
            }
        }
    }
    fun openPlan() { openPlanRequested = true }
    private fun execute(result: MethodChannel.Result, block: () -> Map<String, Any?>) {
        ReminderRuntime.executor.execute {
            try {
                val receipt = block()
                activity.runOnUiThread {
                    result.success(receipt + ("openPlanRequested" to openPlanRequested))
                    openPlanRequested = false
                }
            } catch (error: Exception) {
                activity.runOnUiThread { result.error("reminder_failed", error.message ?: error.javaClass.simpleName, null) }
            }
        }
    }
    private fun requestAccess(result: MethodChannel.Result, settingsOnly: Boolean) {
        if (accessResult != null) { result.error("request_pending", "Berechtigungsanfrage läuft bereits", null); return }
        accessResult = result
        try {
            val permission = AndroidReminderPorts(activity).permissions()
            if (settingsOnly && (!permission.notificationsAllowed || permission.channelBlocked)) {
                waitingForSettings = true
                activity.startActivity(Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName))
            } else if (Build.VERSION.SDK_INT >= 33 && activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_CODE)
            } else {
                if (!permission.notificationsAllowed || permission.channelBlocked) {
                    waitingForSettings = true
                    activity.startActivity(Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                        .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName))
                } else continueAccess()
            }
        } catch (error: Exception) { failAccess(error) }
    }
    fun permissionResult(requestCode: Int) {
        if (requestCode == REQUEST_CODE && accessResult != null) {
            try { continueAccess() } catch (error: Exception) { failAccess(error) }
        }
    }
    private fun continueAccess() {
        val permission = AndroidReminderPorts(activity).permissions()
        if (!permission.notificationsAllowed || permission.channelBlocked) {
            // A denied runtime prompt is a completed user decision, never prompt in a loop.
            completeAccess()
        } else if (Build.VERSION.SDK_INT >= 31 && !permission.exactAllowed) {
            waitingForSettings = true
            activity.startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:${activity.packageName}")))
        } else completeAccess()
    }
    fun resumed() { if (waitingForSettings) { waitingForSettings = false; completeAccess() } }
    private fun completeAccess() {
        val result = accessResult ?: return
        accessResult = null
        execute(result) { ReminderRuntime.scheduler(activity).inspect() }
    }
    private fun failAccess(error: Exception) {
        accessResult?.error("reminder_access_failed", error.message, null)
        accessResult = null; waitingForSettings = false
    }
    fun dispose() { channel.setMethodCallHandler(null) }
    companion object { const val REQUEST_CODE = 8741 }
}
