package com.digitalkavach.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import java.util.Calendar

/**
 * Posts high-importance heads-up warnings for RED-flagged notifications.
 */
object WarnNotifier {
    private const val CHANNEL_ID = "kavach_alerts"
    private const val CHANNEL_NAME = "Kavach Scam Alerts"

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val existing = nm.getNotificationChannel(CHANNEL_ID)
            if (existing == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Scam warnings from notification analysis"
                    enableVibration(true)
                    setShowBadge(true)
                }
                nm.createNotificationChannel(channel)
            }
        }
    }

    fun postWarning(
        context: Context,
        entryId: String,
        titleMeta: String,
        family: String,
        score: Int
    ) {
        ensureChannel(context)

        // Quiet hours check
        val (quietStart, quietEnd) = SentinelPrefs.getQuietHours(context)
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        val isQuiet = isInQuietHours(hour, quietStart, quietEnd)
        val silentBuild = isQuiet && score < 85

        // Spam guard: max 1 warning per title per 10 min
        val titleHash = sha256Hex(titleMeta)
        if (!SentinelPrefs.canWarnForTitle(context, titleHash)) return
        if (SentinelPrefs.isMuted(context, titleHash)) return

        val (title, body) = localizedWarning(family)

        // Deep link intent → opens verdict screen
        val deepLinkIntent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse("kavach://verdict?entryId=$entryId")
        ).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        val whyPending = PendingIntent.getActivity(
            context, entryId.hashCode(), deepLinkIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Dismiss action
        val dismissIntent = Intent(context, WarnActionReceiver::class.java).apply {
            action = "com.digitalkavach.app.DISMISS"
            putExtra("entryId", entryId)
        }
        val dismissPending = PendingIntent.getBroadcast(
            context, ("dismiss_$entryId").hashCode(), dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Mute 24h action
        val muteIntent = Intent(context, WarnActionReceiver::class.java).apply {
            action = "com.digitalkavach.app.MUTE_24H"
            putExtra("titleHash", titleHash)
            putExtra("entryId", entryId)
        }
        val mutePending = PendingIntent.getBroadcast(
            context, ("mute_$entryId").hashCode(), muteIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification: Notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_warning)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(if (silentBuild) NotificationCompat.PRIORITY_LOW else NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(whyPending)
            .addAction(0, "Why?", whyPending)
            .addAction(0, "Dismiss", dismissPending)
            .addAction(0, "Mute 24h", mutePending)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .build()

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(entryId.hashCode(), notification)
        SentinelPrefs.markWarnedForTitle(context, titleHash)
    }

    private fun isInQuietHours(hour: Int, start: Int, end: Int): Boolean {
        return if (start < end) hour in start until end
        else hour >= start || hour < end
    }

    private fun localizedWarning(family: String): Pair<String, String> {
        return when (family) {
            "electricity_bill" -> Pair(
                "🚨 SCAM: Electricity Disconnection Scam",
                "Official electricity boards never threaten disconnection via personal WhatsApp/SMS. Do NOT call or pay."
            )
            "digital_arrest" -> Pair(
                "⚠️ SCAM: Digital Arrest",
                "Suspected fake police/CBI script. Do NOT reply or share OTP."
            )
            "fake_kyc" -> Pair(
                "⚠️ SCAM: Fake KYC",
                "Suspected fake bank/KYC message. Do NOT click links."
            )
            "upi_collect_trap" -> Pair(
                "⚠️ SCAM: UPI Trap",
                "UPI PIN is ONLY for sending money. Do NOT enter PIN to receive."
            )
            "lottery" -> Pair(
                "⚠️ SCAM: Fake Lottery",
                "'You won' + fee = always a scam. Do NOT pay."
            )
            "phishing_link" -> Pair(
                "⚠️ SCAM: Phishing Link",
                "Suspicious link detected. Do NOT click."
            )
            else -> Pair(
                "⚠️ Possible Scam Detected",
                "Digital Kavach flagged this message. Open app for details."
            )
        }
    }

    private fun sha256Hex(s: String): String {
        val md = java.security.MessageDigest.getInstance("SHA-256")
        return md.digest(s.toByteArray(Charsets.UTF_8)).joinToString("") { "%02x".format(it) }
    }
}