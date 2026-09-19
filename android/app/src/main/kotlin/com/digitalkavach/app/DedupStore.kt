package com.digitalkavach.app

import android.content.Context
import java.security.MessageDigest

/**
 * LRU-backed hash set to skip duplicate notifications.
 * WhatsApp re-posts the same notification 3-5 times per message
 * (typing indicators, delivery, updates). Dedup skips those.
 */
object DedupStore {
    private const val PREFS_NAME = "kavach_dedup"
    private const val KEY_HASHES = "hashes"
    private const val MAX_ENTRIES = 200
    private const val EXPIRY_MS = 24 * 60 * 60 * 1000L // 24 hours

    fun computeKey(pkg: String, title: String, text: String, timestampMs: Long): String {
        // Bucket time to 60 seconds to absorb WhatsApp re-post jitter
        val bucket = timestampMs / 60000L
        val raw = "$pkg|$title|$text|$bucket"
        return sha256(raw)
    }

    fun seen(context: Context, key: String): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(KEY_HASHES, "") ?: ""
        val now = System.currentTimeMillis()
        val entries = parseEntries(raw).filter { (_, ts) -> now - ts < EXPIRY_MS }

        val alreadySeen = entries.any { it.first == key }
        if (!alreadySeen) {
            val updated = (entries + Pair(key, now)).takeLast(MAX_ENTRIES)
            prefs.edit().putString(KEY_HASHES, serialize(updated)).apply()
        }
        return alreadySeen
    }

    private fun parseEntries(raw: String): List<Pair<String, Long>> {
        if (raw.isEmpty()) return emptyList()
        return raw.split("\n").mapNotNull { line ->
            val parts = line.split(":")
            if (parts.size == 2) {
                try {
                    Pair(parts[0], parts[1].toLong())
                } catch (_: Exception) { null }
            } else null
        }
    }

    private fun serialize(entries: List<Pair<String, Long>>): String =
        entries.joinToString("\n") { "${it.first}:${it.second}" }

    private fun sha256(input: String): String {
        val md = MessageDigest.getInstance("SHA-256")
        val digest = md.digest(input.toByteArray(Charsets.UTF_8))
        return digest.joinToString("") { "%02x".format(it) }
    }

    fun clearForDev(context: Context) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit().clear().apply()
    }
}