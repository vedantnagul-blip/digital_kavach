package com.digitalkavach.app

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

/**
 * Shared configuration + state for Sentinel Mode.
 * Read/written by both Kotlin (service) and Flutter (via SentinelBridge).
 */
object SentinelPrefs {
    private const val PREFS_NAME = "kavach_sentinel_prefs"

    // Config keys
    private const val KEY_ENABLED = "enabled"
    private const val KEY_PACKAGES = "package_allowlist"
    private const val KEY_QUIET_START = "quiet_hour_start"
    private const val KEY_QUIET_END = "quiet_hour_end"
    private const val KEY_RED_THRESHOLD = "red_threshold"
    private const val KEY_AMBER_THRESHOLD = "amber_threshold"

    // Health telemetry
    private const val KEY_LAST_CONNECTED = "last_connected_ts"
    private const val KEY_GAP_LOG = "gap_log_json"

    // Mute state (title-hash → expiry timestamp)
    private const val KEY_MUTED = "muted_titles_json"
    private const val KEY_LAST_WARNED = "last_warned_titles_json"

    private val DEFAULT_PACKAGES = setOf(
        "com.whatsapp",
        "com.whatsapp.w4b",
        "com.google.android.apps.messaging",
        "org.telegram.messenger"
    )

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun isEnabled(context: Context): Boolean =
        prefs(context).getBoolean(KEY_ENABLED, true)

    fun setEnabled(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(KEY_ENABLED, enabled).apply()
    }

    fun getPackageAllowlist(context: Context): Set<String> {
        val stored = prefs(context).getStringSet(KEY_PACKAGES, null)
        return stored ?: DEFAULT_PACKAGES
    }

    fun setPackageAllowlist(context: Context, packages: Set<String>) {
        prefs(context).edit().putStringSet(KEY_PACKAGES, packages).apply()
    }

    fun getQuietHours(context: Context): Pair<Int, Int> {
        val p = prefs(context)
        return Pair(p.getInt(KEY_QUIET_START, 22), p.getInt(KEY_QUIET_END, 8))
    }

    fun setQuietHours(context: Context, start: Int, end: Int) {
        prefs(context).edit().putInt(KEY_QUIET_START, start).putInt(KEY_QUIET_END, end).apply()
    }

    fun getRedThreshold(context: Context): Int =
        prefs(context).getInt(KEY_RED_THRESHOLD, 60)

    fun getAmberThreshold(context: Context): Int =
        prefs(context).getInt(KEY_AMBER_THRESHOLD, 25)

    // === Health Telemetry ===
    fun markConnected(context: Context) {
        val now = System.currentTimeMillis()
        val last = prefs(context).getLong(KEY_LAST_CONNECTED, 0L)
        val gap = if (last > 0) now - last else 0L
        prefs(context).edit().putLong(KEY_LAST_CONNECTED, now).apply()
        if (gap > 10 * 60 * 1000L) logGap(context, last, now, gap)
    }

    fun getLastConnectedTs(context: Context): Long =
        prefs(context).getLong(KEY_LAST_CONNECTED, 0L)

    private fun logGap(context: Context, from: Long, to: Long, gapMs: Long) {
        val arr = try {
            JSONArray(prefs(context).getString(KEY_GAP_LOG, "[]") ?: "[]")
        } catch (_: Exception) { JSONArray() }
        val entry = JSONObject().apply {
            put("from", from)
            put("to", to)
            put("gap_ms", gapMs)
        }
        arr.put(entry)
        // Keep only last 100 gaps
        while (arr.length() > 100) arr.remove(0)
        prefs(context).edit().putString(KEY_GAP_LOG, arr.toString()).apply()
    }

    fun getGapLog(context: Context): String =
        prefs(context).getString(KEY_GAP_LOG, "[]") ?: "[]"

    // === Muting ===
    fun isMuted(context: Context, titleHash: String): Boolean {
        val json = prefs(context).getString(KEY_MUTED, "{}") ?: "{}"
        val obj = try { JSONObject(json) } catch (_: Exception) { JSONObject() }
        val expiry = obj.optLong(titleHash, 0L)
        return expiry > System.currentTimeMillis()
    }

    fun muteTitle(context: Context, titleHash: String, durationMs: Long) {
        val json = prefs(context).getString(KEY_MUTED, "{}") ?: "{}"
        val obj = try { JSONObject(json) } catch (_: Exception) { JSONObject() }
        obj.put(titleHash, System.currentTimeMillis() + durationMs)
        prefs(context).edit().putString(KEY_MUTED, obj.toString()).apply()
    }

    // === Spam Guard: 10-min per-title cooldown ===
    fun canWarnForTitle(context: Context, titleHash: String): Boolean {
        val json = prefs(context).getString(KEY_LAST_WARNED, "{}") ?: "{}"
        val obj = try { JSONObject(json) } catch (_: Exception) { JSONObject() }
        val lastTs = obj.optLong(titleHash, 0L)
        return (System.currentTimeMillis() - lastTs) > (10 * 60 * 1000L)
    }

    fun markWarnedForTitle(context: Context, titleHash: String) {
        val json = prefs(context).getString(KEY_LAST_WARNED, "{}") ?: "{}"
        val obj = try { JSONObject(json) } catch (_: Exception) { JSONObject() }
        obj.put(titleHash, System.currentTimeMillis())
        // Clean up entries older than 1 hour
        val cutoff = System.currentTimeMillis() - (60 * 60 * 1000L)
        val keys = obj.keys().asSequence().toList()
        for (k in keys) if (obj.optLong(k, 0L) < cutoff) obj.remove(k)
        prefs(context).edit().putString(KEY_LAST_WARNED, obj.toString()).apply()
    }
}