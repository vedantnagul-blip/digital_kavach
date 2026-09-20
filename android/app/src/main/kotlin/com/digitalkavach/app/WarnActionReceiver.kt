package com.digitalkavach.app

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Handles Dismiss and Mute-24h actions from warning notifications.
 */
class WarnActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "com.digitalkavach.app.DISMISS" -> {
                val entryId = intent.getStringExtra("entryId") ?: return
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.cancel(entryId.hashCode())
            }
            "com.digitalkavach.app.MUTE_24H" -> {
                val titleHash = intent.getStringExtra("titleHash") ?: return
                SentinelPrefs.muteTitle(context, titleHash, 24 * 60 * 60 * 1000L)
                val entryId = intent.getStringExtra("entryId")
                if (entryId != null) {
                    val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    nm.cancel(entryId.hashCode())
                }
            }
        }
    }
}