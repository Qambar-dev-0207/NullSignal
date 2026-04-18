package com.nullsignal.null_signal

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.delay

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nullsignal/aicore"
    private var generativeModel: com.google.mlkit.genai.prompt.GenerativeModel? = null
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeModel" -> initializeGeminiNano(result)
                "isSupported" -> result.success(android.os.Build.VERSION.SDK_INT >= 34)
                "generateResponse" -> {
                    val prompt = call.argument<String>("prompt") ?: ""
                    generateAiResponse(prompt, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeGeminiNano(result: MethodChannel.Result) {
        GlobalScope.launch(Dispatchers.IO) {
            try {
                val model = com.google.mlkit.genai.prompt.Generation.getClient()
                var status = model.checkStatus()
                
                Log.d("GeminiNano", "Initial Status Check: $status")

                // S24/S25 specific: Sometimes UNAVAILABLE just means AICore needs a kick.
                // We'll proceed to check for download anyway if on a supported device.
                val isS24 = android.os.Build.MODEL.contains("S938") || android.os.Build.MODEL.contains("S928")
                
                withContext(Dispatchers.Main) {
                    when {
                        status == com.google.mlkit.genai.common.FeatureStatus.AVAILABLE -> {
                            Log.d("GeminiNano", "Model available. Finalizing...")
                            generativeModel = model
                            launch(Dispatchers.IO) { model.warmup() }
                            methodChannel?.invokeMethod("onProgress", 100)
                            result.success(true)
                        }
                        status == com.google.mlkit.genai.common.FeatureStatus.DOWNLOADABLE || 
                        status == com.google.mlkit.genai.common.FeatureStatus.DOWNLOADING || 
                        (status == com.google.mlkit.genai.common.FeatureStatus.UNAVAILABLE && isS24) -> {
                            
                            Log.d("GeminiNano", "Triggering/Attaching to Download flow (Status: $status)...")
                            
                            launch {
                                var totalBytesToDownload = 0L
                                model.download()
                                    .onStart { 
                                        Log.d("GeminiNano", "Download flow started")
                                        withContext(Dispatchers.Main) {
                                            methodChannel?.invokeMethod("onProgress", 1) 
                                        }
                                    }
                                    .catch { e ->
                                        Log.e("GeminiNano", "Download flow failed", e)
                                        withContext(Dispatchers.Main) {
                                            methodChannel?.invokeMethod("onProgress", -1) 
                                            // Fallback result if download fails
                                            if (!result.toString().contains("ReplyAlreadySent")) {
                                                result.error("DOWNLOAD_FAILED", e.message, null)
                                            }
                                        }
                                    }
                                    .collect { progressStatus ->
                                        withContext(Dispatchers.Main) {
                                            var normalizedProgress = 5
                                            if (progressStatus is com.google.mlkit.genai.common.DownloadStatus.DownloadProgress) {
                                                val downloaded = progressStatus.totalBytesDownloaded
                                                normalizedProgress = if (totalBytesToDownload > 0) {
                                                    ((downloaded.toFloat() / totalBytesToDownload) * 100).toInt()
                                                } else {
                                                    5
                                                }
                                            } else if (progressStatus is com.google.mlkit.genai.common.DownloadStatus.DownloadStarted) {
                                                totalBytesToDownload = progressStatus.bytesToDownload
                                                normalizedProgress = 2
                                            } else if (progressStatus is com.google.mlkit.genai.common.DownloadStatus.DownloadCompleted) {
                                                normalizedProgress = 100
                                            }
                                            
                                            Log.d("GeminiNano", "Raw Status: $progressStatus, Normalized: $normalizedProgress")
                                            methodChannel?.invokeMethod("onProgress", normalizedProgress)
                                        }
                                    }
                                
                                Log.d("GeminiNano", "Download completed. Initializing model...")
                                generativeModel = model
                                withContext(Dispatchers.IO) { model.warmup() }
                                withContext(Dispatchers.Main) {
                                    methodChannel?.invokeMethod("onProgress", 100)
                                }
                            }
                            // Don't return success yet, the flow is asynchronous
                            if (!result.toString().contains("ReplyAlreadySent")) {
                                result.success(false) 
                            }
                        }
                        else -> {
                            Log.e("GeminiNano", "Unsupported state: $status")
                            result.error("UNAVAILABLE", "Gemini Nano not supported on this device. Status: $status", status.toString())
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("GeminiNano", "Fatal Init Error", e)
                withContext(Dispatchers.Main) {
                    result.error("INIT_ERROR", "Internal failure: ${e.message}", null)
                }
            }
        }
    }

    private fun generateAiResponse(prompt: String, result: MethodChannel.Result) {
        val model = generativeModel
        if (model == null) {
            result.error("NOT_INITIALIZED", "Model not initialized. Call initializeModel first.", null)
            return
        }

        mainScope.launch {
            try {
                val request = com.google.mlkit.genai.prompt.GenerateContentRequest.Builder(
                    com.google.mlkit.genai.prompt.TextPart(prompt)
                ).build()

                val response: com.google.mlkit.genai.prompt.GenerateContentResponse = withContext(Dispatchers.IO) {
                    model.generateContent(request)
                }

                val generatedText = response.candidates.firstOrNull()?.text
                
                result.success(generatedText ?: "No response generated")
            } catch (e: Exception) {
                Log.e("GeminiNano", "Generation error", e)
                result.error("GEN_ERROR", e.message, null)
            }
        }
    }
}
