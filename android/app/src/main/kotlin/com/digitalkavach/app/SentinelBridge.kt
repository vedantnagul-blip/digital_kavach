package com.digitalkavach.app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.service.notification.NotificationListenerService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Kotlin ↔ Flutter bridge for Sentinel Mode.
 * Channel: kavach/sentinel
 */
class SentinelBridge(private val context: Context, flutterEngine: FlutterEngine) {

    private val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kavach/sentinel")

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getStatus" -> result.success(getStatus())
                "getQueuedEntries" -> result.success(SentinelQueue.getAllAsJsonString(context))
                "deleteQueueEntry" -> {
                    val id = call.argument<String>("entryId")
                    if (id != null) SentinelQueue.deleteById(context, id)
                    result.success(true)
                }
                "setEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    SentinelPrefs.setEnabled(context, enabled)
                    result.success(true)
                }
                "openListenerSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                    result.success(true)
                }
                "requestBatteryExemption" -> {
                    result.success(requestBatteryExemption())
                }
                "isBatteryExempted" -> result.success(isBatteryExempted())
                "requestRebind" -> {
                    try {
                        NotificationListenerService.requestRebind(
                            ComponentName(context, KavachSentinelService::class.java)
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "updateQuietHours" -> {
                    val start = call.argument<Int>("start") ?: 22
                    val end = call.argument<Int>("end") ?: 8
                    SentinelPrefs.setQuietHours(context, start, end)
                    result.success(true)
                }
                "updatePackageAllowlist" -> {
                    val list = call.argument<List<String>>("packages") ?: emptyList()
                    SentinelPrefs.setPackageAllowlist(context, list.toSet())
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getStatus(): Map<String, Any?> {
        return mapOf(
            "enabled" to SentinelPrefs.isEnabled(context),
            "listenerGranted" to isNotificationListenerEnabled(),
            "batteryExempted" to isBatteryExempted(),
            "lastConnectedTs" to SentinelPrefs.getLastConnectedTs(context),
            "gapLog" to SentinelPrefs.getGapLog(context),
            "queueSize" to SentinelQueue.size(context),
            "packageAllowlist" to SentinelPrefs.getPackageAllowlist(context).toList()
        )
    }

    private fun isNotificationListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(
            context.contentResolver, "enabled_notification_listeners"
        ) ?: return false
        return flat.contains(context.packageName)
    }

    private fun isBatteryExempted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            pm.isIgnoringBatteryOptimizations(context.packageName)
        } else true
    }

    private fun requestBatteryExemption(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:${context.packageName}")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            true
        } catch (e: Exception) { false }
    }
}