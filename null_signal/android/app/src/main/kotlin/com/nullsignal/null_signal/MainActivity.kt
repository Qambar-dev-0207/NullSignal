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
    private val MODEL_FILENAME = "gemma-4-e2b-it.litertlm"

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
                "generateResponse" -> generateResponse(call.argument<String>("prompt") ?: "", result)
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeMediaPipe(result: MethodChannel.Result) {
        scope.launch {
            val modelFile = File(filesDir, MODEL_FILENAME)
            if (!modelFile.exists() || modelFile.length() < 2500000000) {
                window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                if (filesDir.usableSpace / (1024 * 1024) < 3000) {
                    result.error("STORAGE_LOW", "3GB free space required", null)
                    return@launch
                }
                var success = false
                var attempts = 0
                while (!success && attempts < 3) {
                    success = withContext(Dispatchers.IO) { downloadModel(MODEL_URL, modelFile) }
                    if (!success) { attempts++; delay(3000) }
                }
                if (!success) {
                    result.error("DOWNLOAD_FAILED", "Check HF Token/Network", null)
                    return@launch
                }
            }
            try {
                val options = LlmInferenceOptions.builder()
                    .setModelPath(modelFile.absolutePath)
                    .setMaxTokens(1024)
                    .build()
                llmInference = withContext(Dispatchers.IO) { LlmInference.createFromOptions(context, options) }
                methodChannel?.invokeMethod("onProgress", 100)
                result.success(true)
            } catch (e: Exception) {
                result.error("LOAD_FAILED", e.message, null)
            }
        }
    }

    private suspend fun downloadModel(urlStr: String, outputFile: File): Boolean {
        var currentUrl = urlStr
        var redirected = false
        return try {
            withContext(Dispatchers.IO) {
                for (i in 1..5) {
                    val url = URL(currentUrl)
                    val conn = url.openConnection() as HttpURLConnection
                    conn.instanceFollowRedirects = false
                    val hfToken = BuildConfig.HF_TOKEN
                    if (hfToken.isNotEmpty() && !redirected) conn.setRequestProperty("Authorization", "Bearer $hfToken")
                    
                    val startByte = if (outputFile.exists() && !redirected) outputFile.length() else 0L
                    if (startByte > 0) conn.setRequestProperty("Range", "bytes=$startByte-")

                    conn.connectTimeout = 30000
                    if (conn.responseCode in 301..308) {
                        currentUrl = conn.getHeaderField("Location") ?: break
                        redirected = true
                        continue
                    }
                    if (conn.responseCode != 200 && conn.responseCode != 206) return@withContext false

                    val total = if (conn.responseCode == 206) {
                        conn.getHeaderField("Content-Range")?.substringAfterLast("/")?.toLong() ?: -1L
                    } else conn.contentLength.toLong()

                    conn.inputStream.use { input ->
                        java.io.FileOutputStream(outputFile, conn.responseCode == 206).use { output ->
                            val buffer = ByteArray(65536)
                            var downloaded = if (conn.responseCode == 206) startByte else 0L
                            var lastProg = -1
                            var bytes = input.read(buffer)
                            while (bytes >= 0) {
                                output.write(buffer, 0, bytes)
                                downloaded += bytes
                                val prog = if (total > 0) (downloaded * 100 / total).toInt() else 0
                                if (prog != lastProg && prog % 5 == 0) {
                                    lastProg = prog
                                    withContext(Dispatchers.Main) { methodChannel?.invokeMethod("onProgress", prog) }
                                }
                                bytes = input.read(buffer)
                            }
                        }
                    }
                    return@withContext true
                }
                false
            }
        } catch (e: Exception) { Log.e("MediaPipe", "Err: ${e.message}"); false }
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
