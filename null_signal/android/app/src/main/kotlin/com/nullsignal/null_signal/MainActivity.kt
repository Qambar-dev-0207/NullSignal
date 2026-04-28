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
    // .task file (MediaPipe Tasks GenAI format). The .litertlm variant in the same
    // repo is for the separate LiteRT-LM SDK and CANNOT be loaded by
    // LlmInference.createFromOptions — load fails, file gets deleted, infinite
    // re-download. Use .task.
    private val MODEL_URL = "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it-web.task?download=true"
    private val MODEL_FILENAME = "gemma-4-E2B-it-web.task"
    private val MODEL_ASSET_PATH = "models/gemma-4-E2B-it-web.task"
    private val EXPECTED_MODEL_SIZE = 2003697664L
    // Stale file from previous (broken) .litertlm URL — delete on init to free 2.6 GB.
    private val LEGACY_MODEL_FILENAME = "gemma-4-E2B-it.litertlm"

    private var llmInference: LlmInference? = null
    private var methodChannel: MethodChannel? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    // Guards against duplicate initializeModel calls (e.g. from Flutter hot-restart or
    // multiple callers in Dart). Without this, two coroutines write to the same file
    // concurrently, corrupting it.
    @Volatile private var isInitializing = false
    @Volatile private var isInitialized = false

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
                    isInitialized = false
                    isInitializing = false
                    llmInference?.close()
                    llmInference = null
                    result.success(true)
                }
                "generateResponse" -> generateResponse(call.argument<String>("prompt") ?: "", result)
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeMediaPipe(result: MethodChannel.Result) {
        // If already loaded, just signal ready — no re-download needed.
        if (isInitialized && llmInference != null) {
            Log.d("MediaPipe", "Model already loaded. Signalling ready.")
            methodChannel?.invokeMethod("onProgress", 100)
            result.success(true)
            return
        }

        // Block a second concurrent call. Without this guard, both callers download
        // to the same file simultaneously, producing a corrupted binary.
        if (isInitializing) {
            Log.w("MediaPipe", "initializeMediaPipe called while already initializing — ignoring.")
            result.error("ALREADY_INITIALIZING", "Model initialization is already in progress.", null)
            return
        }
        isInitializing = true

        scope.launch {
            // Reclaim disk: stale .litertlm from older builds is unloadable junk.
            val legacyFile = File(filesDir, LEGACY_MODEL_FILENAME)
            if (legacyFile.exists()) {
                Log.i("MediaPipe", "Deleting legacy ${legacyFile.length()} bytes .litertlm file (incompatible format).")
                legacyFile.delete()
            }

            val modelFile = File(filesDir, MODEL_FILENAME)

            // Preferred path: copy the bundled APK asset to filesDir on first
            // launch. MediaPipe LlmInference requires a filesystem path, but
            // shipping the model in assets/ removes the network dependency and
            // the HuggingFace license/auth gate entirely.
            if (!modelFile.exists() || modelFile.length() < EXPECTED_MODEL_SIZE - 1024) {
                val copiedFromAsset = withContext(Dispatchers.IO) {
                    copyModelFromAssetIfPresent(modelFile)
                }
                if (copiedFromAsset) {
                    Log.i("MediaPipe", "Model staged from bundled APK asset (${modelFile.length()} bytes).")
                }
            }

            if (!modelFile.exists() || modelFile.length() < EXPECTED_MODEL_SIZE - 1024) {
                Log.d("MediaPipe", "Model missing or incomplete: ${modelFile.length()} / $EXPECTED_MODEL_SIZE bytes. Starting download...")
                window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

                val freeMB = filesDir.usableSpace / 1_000_000
                if (filesDir.usableSpace < 3_000_000_000L) {
                    Log.e("MediaPipe", "Insufficient storage: ${freeMB}MB free, need 3000MB")
                    isInitializing = false
                    result.error("STORAGE_LOW", "Need 3 GB free space. Only ${freeMB} MB available.", null)
                    return@launch
                }

                var success = false
                var attempt = 0
                while (!success && attempt < 5) {
                    success = withContext(Dispatchers.IO) { downloadModel(MODEL_URL, modelFile) }
                    if (!success) {
                        attempt++
                        Log.w("MediaPipe", "Download attempt $attempt/5 failed. Retrying in 5 s…")
                        delay(5_000)
                    }
                }

                if (!success || modelFile.length() < EXPECTED_MODEL_SIZE - 1024) {
                    Log.e("MediaPipe", "Download failed after 5 attempts. File size: ${modelFile.length()} / $EXPECTED_MODEL_SIZE")
                    methodChannel?.invokeMethod("onProgress", -1)
                    isInitializing = false
                    result.error(
                        "DOWNLOAD_FAILED",
                        "Download failed after 5 attempts (got ${modelFile.length()} / $EXPECTED_MODEL_SIZE bytes). " +
                        "Check your internet connection and ensure you have accepted the Gemma 4 license at " +
                        "huggingface.co/litert-community/gemma-4-E2B-it-litert-lm",
                        null
                    )
                    return@launch
                }
            } else {
                Log.d("MediaPipe", "Model file found (${modelFile.length()} bytes). Skipping download.")
            }

            try {
                Log.d("MediaPipe", "Loading LLM engine…")
                methodChannel?.invokeMethod("onProgress", 99)

                val options = LlmInferenceOptions.builder()
                    .setModelPath(modelFile.absolutePath)
                    .setMaxTokens(1024)
                    .setPreferredBackend(LlmInference.Backend.GPU)
                    .build()

                llmInference = try {
                    withContext(Dispatchers.IO) { LlmInference.createFromOptions(context, options) }
                } catch (e: Exception) {
                    Log.w("MediaPipe", "GPU backend failed (${e.message}), falling back to CPU…")
                    val cpuOptions = LlmInferenceOptions.builder()
                        .setModelPath(modelFile.absolutePath)
                        .setMaxTokens(1024)
                        .setPreferredBackend(LlmInference.Backend.CPU)
                        .build()
                    withContext(Dispatchers.IO) { LlmInference.createFromOptions(context, cpuOptions) }
                }

                Log.i("MediaPipe", "Gemma 4 model loaded successfully.")
                isInitialized = true
                isInitializing = false
                methodChannel?.invokeMethod("onProgress", 100)
                window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                result.success(true)
            } catch (e: Exception) {
                // Delete the file unconditionally on load failure — it may be corrupted.
                // A healthy file that fails transiently (e.g. OOM) is worth re-downloading
                // rather than leaving a broken file that will fail on every subsequent launch.
                Log.e("MediaPipe", "Model load failed: ${e.message}. Deleting file for clean re-download.")
                modelFile.delete()
                methodChannel?.invokeMethod("onProgress", -1)
                isInitializing = false
                isInitialized = false
                result.error("LOAD_FAILED", "Model failed to load: ${e.message}. Corrupt file deleted — tap RETRY to re-download.", null)
            }
        }
    }

    // Returns true if the bundled asset was found and successfully copied into
    // [outputFile]. Returns false if the asset is absent (dev build that
    // intentionally skipped the 2 GB asset) so the caller can fall back to the
    // network download path.
    private fun copyModelFromAssetIfPresent(outputFile: File): Boolean {
        return try {
            val assetList = assets.list("models")?.toList() ?: emptyList()
            if (!assetList.contains("gemma-4-E2B-it-web.task")) {
                Log.i("MediaPipe", "No bundled model asset found. Falling back to download.")
                return false
            }

            val tmp = File(outputFile.parentFile, "${outputFile.name}.staging")
            if (tmp.exists()) tmp.delete()

            assets.open(MODEL_ASSET_PATH).use { input ->
                java.io.FileOutputStream(tmp).use { output ->
                    val buffer = ByteArray(1 * 1024 * 1024)
                    var copied = 0L
                    var lastProg = -1
                    while (true) {
                        val n = input.read(buffer)
                        if (n < 0) break
                        output.write(buffer, 0, n)
                        copied += n
                        val prog = ((copied * 100L) / EXPECTED_MODEL_SIZE).toInt().coerceIn(0, 98)
                        if (prog != lastProg) {
                            lastProg = prog
                            methodChannel?.invokeMethod("onProgress", prog)
                        }
                    }
                }
            }

            if (outputFile.exists()) outputFile.delete()
            if (!tmp.renameTo(outputFile)) {
                Log.e("MediaPipe", "Failed to rename staged model into place.")
                tmp.delete()
                return false
            }
            true
        } catch (e: Exception) {
            Log.e("MediaPipe", "Asset copy failed: ${e.javaClass.simpleName}: ${e.message}")
            false
        }
    }

    private suspend fun downloadModel(urlStr: String, outputFile: File): Boolean {
        var currentUrl = urlStr
        var redirectCount = 0
        val hfToken = BuildConfig.HF_TOKEN

        return try {
            withContext(Dispatchers.IO) {
                while (redirectCount < 10) {
                    val conn = (URL(currentUrl).openConnection() as HttpURLConnection).apply {
                        instanceFollowRedirects = false
                        connectTimeout = 60_000
                        readTimeout = 60_000
                        setRequestProperty("User-Agent", "NullSignal/1.1 (Android)")
                    }

                    // Only send the HF token to HuggingFace itself — CDN redirect URLs are
                    // pre-signed and do not need (and may reject) the Authorization header.
                    val isHfDomain = currentUrl.startsWith("https://huggingface.co") ||
                                     currentUrl.startsWith("https://hf.co")
                    if (hfToken.isNotEmpty() && isHfDomain && redirectCount == 0) {
                        conn.setRequestProperty("Authorization", "Bearer $hfToken")
                    }

                    val startByte = if (outputFile.exists()) outputFile.length() else 0L
                    if (startByte > 0) {
                        conn.setRequestProperty("Range", "bytes=$startByte-")
                        Log.d("MediaPipe", "Resuming from byte $startByte")
                    }

                    val responseCode = conn.responseCode
                    Log.d("MediaPipe", "HTTP $responseCode ← $currentUrl")

                    if (responseCode in 301..308) {
                        currentUrl = conn.getHeaderField("Location") ?: break
                        redirectCount++
                        conn.disconnect()
                        continue
                    }

                    if (responseCode == 401 || responseCode == 403) {
                        Log.e("MediaPipe",
                            "HTTP $responseCode: Access denied. " +
                            "Ensure your HF token is valid and you have accepted the Gemma 4 license at " +
                            "huggingface.co/litert-community/gemma-4-E2B-it-litert-lm")
                        conn.disconnect()
                        return@withContext false
                    }

                    if (responseCode != 200 && responseCode != 206) {
                        Log.e("MediaPipe", "Unexpected HTTP $responseCode from $currentUrl")
                        conn.disconnect()
                        return@withContext false
                    }

                    // Detect HTML error pages (e.g. HF returns a page when license not accepted)
                    val contentType = conn.contentType ?: ""
                    if (contentType.contains("text/html") || contentType.contains("application/json")) {
                        Log.e("MediaPipe",
                            "Server returned '$contentType' — expected binary. " +
                            "HF token may be invalid or the Gemma 4 license has not been accepted.")
                        conn.disconnect()
                        return@withContext false
                    }

                    val isResuming = responseCode == 206
                    // Use contentLengthLong — contentLength (Int) overflows to negative for files > 2 GB.
                    val contentLength = conn.contentLengthLong
                    val total = when {
                        isResuming && contentLength > 0 -> startByte + contentLength
                        contentLength > 0               -> contentLength
                        else                            -> EXPECTED_MODEL_SIZE
                    }

                    Log.d("MediaPipe", "Downloading: resuming=$isResuming, contentLength=$contentLength, total=$total")

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

                                val prog = ((downloaded * 100L) / total).toInt().coerceIn(0, 98)
                                if (prog != lastProg) {
                                    lastProg = prog
                                    withContext(Dispatchers.Main) {
                                        methodChannel?.invokeMethod("onProgress", prog)
                                    }
                                }
                            }
                        }
                    }

                    Log.d("MediaPipe", "Download complete. File size: ${outputFile.length()} bytes")
                    return@withContext true
                }
                Log.e("MediaPipe", "Exceeded redirect limit or no valid download URL")
                false
            }
        } catch (e: Exception) {
            Log.e("MediaPipe", "Download error: ${e.javaClass.simpleName}: ${e.message}")
            false
        }
    }

    private fun generateResponse(prompt: String, result: MethodChannel.Result) {
        val model = llmInference
            ?: return result.error("NOT_READY", "Model not loaded yet. Wait for initialization to complete.", null)
        scope.launch {
            try {
                val resp = withContext(Dispatchers.IO) { model.generateResponse(prompt) }
                result.success(resp)
            } catch (e: Exception) {
                result.error("GEN_ERROR", e.message, null)
            }
        }
    }

    override fun onDestroy() {
        scope.cancel()
        llmInference?.close()
        super.onDestroy()
    }
}
