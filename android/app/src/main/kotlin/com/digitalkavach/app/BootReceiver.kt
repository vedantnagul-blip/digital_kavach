package com.digitalkavach.app

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.util.Log

/**
 * Re-asserts the Sentinel foreground service after phone reboot.
 * Only starts if sentinel is enabled AND notification listener permission is still granted.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        try {
            if (!SentinelPrefs.isEnabled(context)) return
            if (!isNotificationListenerEnabled(context)) return

            // Trigger rebind — Android handles NotificationListenerService lifecycle
            NotificationListenerService.requestRebind(
                ComponentName(context, KavachSentinelService::class.java)
            )
            Log.d("KavachBoot", "Sentinel rebind requested after boot")
        } catch (e: Exception) {
            Log.w("KavachBoot", "Boot reassertion failed: $e")
        }
    }

    private fun isNotificationListenerEnabled(context: Context): Boolean {
        val flat = Settings.Secure.getString(
            context.contentResolver, "enabled_notification_listeners"
        ) ?: return false
        return flat.contains(context.packageName)
    }
}