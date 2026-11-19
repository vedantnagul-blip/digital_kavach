package com.digitalkavach.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import java.io.File

class MainActivity : FlutterActivity() {
    private var sentinelBridge: SentinelBridge? = null
    private var llmInference: LlmInference? = null
    private val LLM_CHANNEL = "com.digitalkavach.app/edge_llm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sentinelBridge = SentinelBridge(applicationContext, flutterEngine)

        // On-Device Edge AI Method Channel (Gemma via Google MediaPipe)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LLM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isEdgeAiSupported" -> {
                    val defaultPath = File(context.filesDir, "models/gemma-2b-it-cpu-int4.bin")
                    val fallbackPath = File("/data/local/tmp/gemma-2b-it-cpu-int4.bin")
                    result.success(defaultPath.exists() || fallbackPath.exists())
                }
                "initGemma" -> {
                    val requestedPath = call.argument<String>("modelPath")
                    val modelFile = if (!requestedPath.isNullOrEmpty()) {
                        File(requestedPath)
                    } else {
                        val internal = File(context.filesDir, "models/gemma-2b-it-cpu-int4.bin")
                        if (internal.exists()) internal else File("/data/local/tmp/gemma-2b-it-cpu-int4.bin")
                    }

                    if (!modelFile.exists()) {
                        result.error("FILE_NOT_FOUND", "Gemma model weight file not found at ${modelFile.absolutePath}", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val options = LlmInference.LlmInferenceOptions.builder()
                            .setModelPath(modelFile.absolutePath)
                            .setMaxTokens(256)
                            .setTemperature(0.2f)
                            .build()
                        llmInference = LlmInference.createFromOptions(context, options)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", e.message, null)
                    }
                }
                "infer" -> {
                    val prompt = call.argument<String>("prompt") ?: ""
                    if (llmInference == null) {
                        result.error("NOT_INITIALIZED", "Gemma model not initialized yet", null)
                        return@setMethodCallHandler
                    }
                    // Run inference on a background worker thread to prevent freezing the Flutter 60 FPS UI
                    Thread {
                        try {
                            val response = llmInference!!.generateResponse(prompt)
                            runOnUiThread { result.success(response) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("INFERENCE_ERROR", e.message, null) }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }
}