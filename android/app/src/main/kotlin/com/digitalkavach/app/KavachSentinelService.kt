package com.digitalkavach.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * Native background service that reads WhatsApp/SMS/Telegram notifications,
 * runs local rule checks, and posts warnings — all without any network calls.
 */
class KavachSentinelService : NotificationListenerService() {

    companion object {
        private const val TAG = "KavachSentinel"
        private const val FGS_CHANNEL_ID = "kavach_fgs"
        private const val FGS_NOTIFICATION_ID = 42
    }

    override fun onCreate() {
        super.onCreate()
        startForegroundServiceNow()
    }

    private fun startForegroundServiceNow() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(FGS_CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    FGS_CHANNEL_ID,
                    "Kavach Sentinel Active",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Persistent notification while Sentinel is watching"
                    setShowBadge(false)
                }
                nm.createNotificationChannel(channel)
            }
        }

        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pending = openAppIntent?.let {
            PendingIntent.getActivity(
                this, 0, it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val notif: Notification = NotificationCompat.Builder(this, FGS_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_view)
            .setContentTitle("🛡️ Kavach Sentinel")
            .setContentText("Watching for scam messages")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pending)
            .setOngoing(true)
            .build()

        try {
            startForeground(FGS_NOTIFICATION_ID, notif)
        } catch (e: Exception) {
            Log.w(TAG, "startForeground failed: $e")
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "onListenerConnected()")
        SentinelPrefs.markConnected(this)
        WarnNotifier.ensureChannel(this)
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d(TAG, "onListenerDisconnected()")
        try {
            requestRebind(ComponentName(this, KavachSentinelService::class.java))
        } catch (_: Exception) {}
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return
        if (!SentinelPrefs.isEnabled(this)) return
        if (sbn.isOngoing) return

        val pkg = sbn.packageName ?: return
        val allowlist = SentinelPrefs.getPackageAllowlist(this)
        if (!allowlist.contains(pkg)) return

        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""

        // Extraction chain: EXTRA_MESSAGES > EXTRA_BIG_TEXT > EXTRA_TEXT
        val messages = mutableListOf<Pair<String, Long>>()

        val msgsBundle = extras.getParcelableArray(Notification.EXTRA_MESSAGES)
        if (msgsBundle != null) {
            for (item in msgsBundle) {
                try {
                    val bundle = item as? Bundle ?: continue
                    val txt = bundle.getCharSequence("text")?.toString() ?: continue
                    val ts = bundle.getLong("time", sbn.postTime)
                    messages.add(Pair(txt, ts))
                } catch (_: Exception) {}
            }
        }

        if (messages.isEmpty()) {
            val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
                ?: extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
            if (!bigText.isNullOrBlank()) {
                messages.add(Pair(bigText, sbn.postTime))
            }
        }

        if (messages.isEmpty()) return

        for ((line, ts) in messages) {
            Log.d(TAG, "Notification line extracted from $pkg ($title): $line")
            processLine(pkg, title, line, ts)
        }
    }

    private fun processLine(pkg: String, title: String, line: String, ts: Long) {
        val trimmed = line.trim()
        if (trimmed.length < 5) return

        val dedupKey = DedupStore.computeKey(pkg, title, trimmed, ts)
        if (DedupStore.seen(this, dedupKey)) {
            Log.d(TAG, "Dedup: message already scanned recently, skipping")
            return
        }

        val redThreshold = SentinelPrefs.getRedThreshold(this)
        val amberThreshold = SentinelPrefs.getAmberThreshold(this)

        val result = FastRuleEngine.evaluate(trimmed)
        Log.i(TAG, "FastRuleEngine scan: score=${result.score}, family=${result.topFamily}, hits=${result.hits.size}")
        if (result.score < amberThreshold) return  // Drop entirely

        val topRule = result.hits.maxByOrNull { it.weight }
        val entryId = SentinelQueue.enqueue(
            this,
            pkg = pkg,
            titleMeta = title,
            line = trimmed,
            score = result.score,
            family = result.topFamily,
            ruleId = topRule?.ruleId ?: "unknown"
        )
        Log.i(TAG, "Enqueued Sentinel threat entry: $entryId")

        if (result.score >= redThreshold) {
            Log.i(TAG, "Triggering heads-up warning notification for $entryId")
            WarnNotifier.postWarning(this, entryId, title, result.topFamily, result.score)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }
}