package com.digitalkavach.app

import android.content.Context

/**
 * Bridge
 *
 * TODO(phase-06): Thin helper to emit flagged items to Flutter EventChannel.
 * Model:
 * data class Flagged(
 *   val pkg: String,
 *   val title: String?,
 *   val text: String?,
 *   val tier1Family: String?,
 *   val tier1Score: Int,
 *   val ts: Long
 * )
 * Send via MethodChannel/EventChannel named "com.digitalkavach.sentinel/events"
 */
object Bridge {
    fun emit(context: Context, payload: Map<String, Any?>) {
        // TODO(phase-06): wire to FlutterEngine/background isolate
    }
}