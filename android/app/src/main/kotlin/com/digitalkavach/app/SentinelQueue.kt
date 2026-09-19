package com.digitalkavach.app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

/**
 * FIFO queue of flagged notification entries.
 * Drained by Flutter's QueueDrainer on app start/resume.
 */
object SentinelQueue {
    private const val PREFS_NAME = "kavach_sentinel_queue"
    private const val KEY_QUEUE = "entries"
    private const val MAX_ENTRIES = 100

    data class Entry(
        val id: String,
        val ts: Long,
        val pkg: String,
        val titleMeta: String,
        val line: String,
        val score: Int,
        val family: String,
        val ruleId: String
    ) {
        fun toJson(): JSONObject = JSONObject().apply {
            put("id", id)
            put("ts", ts)
            put("pkg", pkg)
            put("titleMeta", titleMeta)
            put("line", line)
            put("score", score)
            put("family", family)
            put("ruleId", ruleId)
        }

        companion object {
            fun fromJson(obj: JSONObject): Entry = Entry(
                id = obj.getString("id"),
                ts = obj.getLong("ts"),
                pkg = obj.getString("pkg"),
                titleMeta = obj.getString("titleMeta"),
                line = obj.getString("line"),
                score = obj.getInt("score"),
                family = obj.getString("family"),
                ruleId = obj.getString("ruleId")
            )
        }
    }

    fun enqueue(
        context: Context,
        pkg: String,
        titleMeta: String,
        line: String,
        score: Int,
        family: String,
        ruleId: String
    ): String {
        val entry = Entry(
            id = UUID.randomUUID().toString(),
            ts = System.currentTimeMillis(),
            pkg = pkg,
            titleMeta = titleMeta,
            line = line,
            score = score,
            family = family,
            ruleId = ruleId
        )
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val current = try {
            JSONArray(prefs.getString(KEY_QUEUE, "[]") ?: "[]")
        } catch (_: Exception) { JSONArray() }

        current.put(entry.toJson())
        // FIFO overflow: drop oldest
        while (current.length() > MAX_ENTRIES) current.remove(0)
        prefs.edit().putString(KEY_QUEUE, current.toString()).apply()
        return entry.id
    }

    fun getAll(context: Context): List<Entry> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(KEY_QUEUE, "[]") ?: "[]"
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).map { Entry.fromJson(arr.getJSONObject(it)) }
        } catch (_: Exception) { emptyList() }
    }

    fun getAllAsJsonString(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString(KEY_QUEUE, "[]") ?: "[]"
    }

    fun deleteById(context: Context, entryId: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val current = try {
            JSONArray(prefs.getString(KEY_QUEUE, "[]") ?: "[]")
        } catch (_: Exception) { JSONArray() }

        val filtered = JSONArray()
        for (i in 0 until current.length()) {
            val obj = current.getJSONObject(i)
            if (obj.getString("id") != entryId) filtered.put(obj)
        }
        prefs.edit().putString(KEY_QUEUE, filtered.toString()).apply()
    }

    fun clearAll(context: Context) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit().clear().apply()
    }

    fun size(context: Context): Int = getAll(context).size
}