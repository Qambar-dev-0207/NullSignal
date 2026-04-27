package com.nullsignal.null_signal

import android.util.Log
import androidx.annotation.NonNull
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.LlmInference.LlmInferenceOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File
import java.net.URL
import java.net.HttpURLConnection

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nullsignal/aicore"
    private val MODEL_URL = "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm?download=true"
    private val MODEL_FILENAME = "gemma-4-E2B-it.litertlm"
    private val EXPECTED_MODEL_SIZE = 2583085056L

    private var llmInference: LlmInference? = null
    private var methodChannel: MethodChannel? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupported" -> result.success(true) 
                "initializeModel" -> initializeMediaPipe(result)
                "deleteModel" -> {
                    val modelFile = File(filesDir, MODEL_FILENAME)
                    if (modelFile.exists()) modelFile.delete()
                    result.success(true)
                }
                "generateResponse" -> generateResponse(call.argument<String>("prompt") ?: "", result)
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeMediaPipe(result: MethodChannel.Result) {
        scope.launch {
            val modelFile = File(filesDir, MODEL_FILENAME)
            
            if (!modelFile.exists() || modelFile.length() < EXPECTED_MODEL_SIZE - 1024) {
                Log.d("MediaPipe", "Model missing or incomplete: ${modelFile.length()} bytes. Starting download...")
                window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                
                if (filesDir.usableSpace < 3000000000L) {
                    result.error("STORAGE_LOW", "3GB free space required", null)
                    return@launch
                }
                
                var success = false
                var attempts = 0
                while (!success && attempts < 5) {
                    success = withContext(Dispatchers.IO) { downloadModel(MODEL_URL, modelFile) }
                    if (!success) { 
                        attempts++
                        Log.w("MediaPipe", "Download attempt $attempts failed. Retrying...")
                        delay(5000) 
                    }
                }
                
                if (!success || modelFile.length() < EXPECTED_MODEL_SIZE - 1024) {
                    Log.e("MediaPipe", "Download failed or incomplete. Final size: ${modelFile.length()}")
                    methodChannel?.invokeMethod("onProgress", -1)
                    result.error("DOWNLOAD_FAILED", "Check connection.", null)
                    return@launch
                }
            }
            
            try {
                Log.d("MediaPipe", "Loading engine... (File size: ${modelFile.length()})")
                methodChannel?.invokeMethod("onProgress", 99) // Signal loading state
                
                // Try GPU first
                val options = LlmInferenceOptions.builder()
                    .setModelPath(modelFile.absolutePath)
                    .setMaxTokens(1024)
                    .setPreferredBackend(LlmInference.Backend.GPU)
                    .build()
                
                llmInference = try {
                    withContext(Dispatchers.IO) { LlmInference.createFromOptions(context, options) }
                } catch (e: Exception) {
                    Log.w("MediaPipe", "GPU init failed, falling back to CPU: ${e.message}")
                    val cpuOptions = LlmInferenceOptions.builder()
                        .setModelPath(modelFile.absolutePath)
                        .setMaxTokens(1024)
                        .setPreferredBackend(LlmInference.Backend.CPU)
                        .build()
                    withContext(Dispatchers.IO) { LlmInference.createFromOptions(context, cpuOptions) }
                }

                Log.i("MediaPipe", "Model initialized.")
                methodChannel?.invokeMethod("onProgress", 100)
                window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                result.success(true)
            } catch (e: Exception) {
                Log.e("MediaPipe", "Failed to load model: ${e.message}")
                // Only delete if size is way off
                if (modelFile.length() < EXPECTED_MODEL_SIZE / 2) {
                    modelFile.delete()
                }
                methodChannel?.invokeMethod("onProgress", -1)
                result.error("LOAD_FAILED", e.message, null)
            }
        }
    }

    private suspend fun downloadModel(urlStr: String, outputFile: File): Boolean {
        var currentUrl = urlStr
        var redirectedCount = 0
        val hfToken = BuildConfig.HF_TOKEN
        
        return try {
            withContext(Dispatchers.IO) {
                while (redirectedCount < 10) {
                    val url = URL(currentUrl)
                    val conn = url.openConnection() as HttpURLConnection
                    conn.instanceFollowRedirects = false
                    conn.connectTimeout = 60000
                    conn.readTimeout = 60000
                    conn.setRequestProperty("User-Agent", "NullSignal/1.1 (Android)")
                    
                    val isMainHfDomain = currentUrl.startsWith("https://huggingface.co") || 
                                       currentUrl.startsWith("https://hf.co")
                    if (hfToken.isNotEmpty() && isMainHfDomain && redirectedCount == 0) {
                        conn.setRequestProperty("Authorization", "Bearer $hfToken")
                    }
                    
                    val startByte = if (outputFile.exists()) outputFile.length() else 0L
                    if (startByte > 0) {
                        conn.setRequestProperty("Range", "bytes=$startByte-")
                    }

                    val responseCode = conn.responseCode
                    if (responseCode in 301..308) {
                        currentUrl = conn.getHeaderField("Location") ?: break
                        redirectedCount++
                        continue
                    }

                    if (responseCode != 200 && responseCode != 206) {
                        Log.e("MediaPipe", "HTTP $responseCode for $currentUrl")
                        return@withContext false
                    }

                    val isResuming = responseCode == 206
                    val contentLength = conn.contentLength.toLong()
                    val total = if (isResuming) startByte + contentLength else if (contentLength > 0) contentLength else EXPECTED_MODEL_SIZE

                    conn.inputStream.use { input ->
                        java.io.FileOutputStream(outputFile, isResuming).use { output ->
                            val buffer = ByteArray(128 * 1024)
                            var downloaded = if (isResuming) startByte else 0L
                            var lastProg = -1
                            
                            while (true) {
                                val bytes = input.read(buffer)
                                if (bytes < 0) break
                                output.write(buffer, 0, bytes)
                                downloaded += bytes
                                
                                val prog = (downloaded * 100 / total).toInt()
                                if (prog != lastProg) {
                                    lastProg = prog
                                    withContext(Dispatchers.Main) { 
                                        methodChannel?.invokeMethod("onProgress", prog) 
                                    }
                                }
                            }
                        }
                    }
                    return@withContext true
                }
                false
            }
        } catch (e: Exception) { 
            Log.e("MediaPipe", "Download Error: ${e.message}")
            false 
        }
    }

    private fun generateResponse(prompt: String, result: MethodChannel.Result) {
        val model = llmInference ?: return result.error("NOT_READY", "Wait for download", null)
        scope.launch {
            try {
                val resp = withContext(Dispatchers.IO) { model.generateResponse(prompt) }
                result.success(resp)
            } catch (e: Exception) { result.error("GEN_ERROR", e.message, null) }
        }
    }

    override fun onDestroy() { scope.cancel(); llmInference?.close(); super.onDestroy() }
}
