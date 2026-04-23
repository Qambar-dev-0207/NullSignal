Problem: Gemini Nano only works on Pixel 8+/S24+. Other devices get nothing.
Solution: Replace with Gemma via MediaPipe — runs on ANY Android/iOS device with 4GB+ RAM.

STEP 1 — Add Dependencies
pubspec.yaml:
yamldependencies:
google_generative_ai: ^0.4.3  # keep for cloud fallback
# Remove: no direct flutter mediapipe package yet
# Use MethodChannel to native MediaPipe
android/app/build.gradle.kts:
kotlindependencies {
// Replace mlkit genai with MediaPipe
implementation("com.google.mediapipe:tasks-genai:0.10.14")
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
ios/Podfile:
rubypod 'MediaPipeTasksGenAI', '~> 0.10.14'
pod 'MediaPipeTasksGenAICore', '~> 0.10.14'

STEP 2 — Download Gemma Model
Add to android/app/src/main/assets/ (download script):
bash# Run once to download Gemma 2B INT4 (~1.3GB)
wget -O android/app/src/main/assets/gemma-2b-it-gpu-int4.bin \
"https://huggingface.co/google/gemma-2b-it-gpu-int4/resolve/main/gemma-2b-it-gpu-int4.bin"
Or use smaller model for low-RAM devices:
bash# Gemma 2B INT8 CPU (~1.5GB) — works on ALL devices including low-end
wget -O android/app/src/main/assets/gemma-2b-it-cpu-int8.bin \
"https://huggingface.co/google/gemma-2b-it-cpu-int8/resolve/main/gemma-2b-it-cpu-int8.bin"
Better approach — download at first launch (don't bundle in APK):

STEP 3 — Rewrite MainActivity.kt
kotlinpackage com.nullsignal.null_signal

import android.content.Context
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

class MainActivity : FlutterActivity() {
private val CHANNEL = "com.nullsignal/aicore"
private val MODEL_URL = "https://huggingface.co/google/gemma-2b-it-gpu-int4/resolve/main/gemma-2b-it-gpu-int4.bin"
private val MODEL_FILENAME = "gemma-2b-it-gpu-int4.bin"

    private var llmInference: LlmInference? = null
    private var methodChannel: MethodChannel? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupported" -> result.success(true) // ALL devices supported now
                "initializeModel" -> initializeMediaPipe(result)
                "generateResponse" -> {
                    val prompt = call.argument<String>("prompt") ?: ""
                    generateResponse(prompt, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getModelFile(): File {
        return File(filesDir, MODEL_FILENAME)
    }

    private fun initializeMediaPipe(result: MethodChannel.Result) {
        scope.launch {
            val modelFile = getModelFile()
            
            // Download if not exists
            if (!modelFile.exists()) {
                Log.d("MediaPipe", "Model not found, downloading...")
                methodChannel?.invokeMethod("onProgress", 1)
                
                val success = withContext(Dispatchers.IO) {
                    downloadModel(modelFile)
                }
                
                if (!success) {
                    result.error("DOWNLOAD_FAILED", "Failed to download Gemma model", null)
                    return@launch
                }
            }
            
            // Load model
            try {
                Log.d("MediaPipe", "Loading model from ${modelFile.path}")
                methodChannel?.invokeMethod("onProgress", 90)
                
                val options = LlmInferenceOptions.builder()
                    .setModelPath(modelFile.absolutePath)
                    .setMaxTokens(1024)
                    .setTopK(40)
                    .setTemperature(0.8f)
                    .setRandomSeed(101)
                    .build()
                
                llmInference = withContext(Dispatchers.IO) {
                    LlmInference.createFromOptions(context, options)
                }
                
                methodChannel?.invokeMethod("onProgress", 100)
                Log.d("MediaPipe", "Model loaded successfully")
                result.success(true)
                
            } catch (e: Exception) {
                Log.e("MediaPipe", "Failed to load model", e)
                // Delete corrupted model file
                modelFile.delete()
                result.error("LOAD_FAILED", "Model load failed: ${e.message}", null)
            }
        }
    }

    private suspend fun downloadModel(outputFile: File): Boolean {
        return try {
            withContext(Dispatchers.IO) {
                val url = URL(MODEL_URL)
                val connection = url.openConnection()
                connection.connect()
                val totalBytes = connection.contentLength.toLong()
                
                connection.getInputStream().use { input ->
                    outputFile.outputStream().use { output ->
                        val buffer = ByteArray(8192)
                        var downloadedBytes = 0L
                        var lastProgressUpdate = 0
                        
                        var bytes = input.read(buffer)
                        while (bytes >= 0) {
                            output.write(buffer, 0, bytes)
                            downloadedBytes += bytes
                            
                            val progress = if (totalBytes > 0) {
                                ((downloadedBytes.toFloat() / totalBytes) * 85).toInt() + 1
                            } else 5
                            
                            // Only update UI every 1% to avoid spam
                            if (progress != lastProgressUpdate) {
                                lastProgressUpdate = progress
                                withContext(Dispatchers.Main) {
                                    methodChannel?.invokeMethod("onProgress", progress)
                                }
                            }
                            
                            bytes = input.read(buffer)
                        }
                    }
                }
                true
            }
        } catch (e: Exception) {
            Log.e("MediaPipe", "Download failed", e)
            outputFile.delete()
            false
        }
    }

    private fun generateResponse(prompt: String, result: MethodChannel.Result) {
        val model = llmInference
        if (model == null) {
            result.error("NOT_INITIALIZED", "Model not loaded", null)
            return
        }
        
        scope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    model.generateResponse(prompt)
                }
                result.success(response)
            } catch (e: Exception) {
                Log.e("MediaPipe", "Generation failed", e)
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

STEP 4 — Rewrite iOS AppDelegate (MediaPipe)
ios/Runner/AppDelegate.swift:
swiftimport UIKit
import Flutter
import MediaPipeTasksGenAI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
private var llmInference: LlmInference?
private var channel: FlutterMethodChannel?
private let modelFilename = "gemma-2b-it-cpu-int8.bin"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        channel = FlutterMethodChannel(
            name: "com.nullsignal/aicore",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "isSupported":
                result(true)
            case "initializeModel":
                self?.initializeModel(result: result)
            case "generateResponse":
                let prompt = (call.arguments as? [String: Any])?["prompt"] as? String ?? ""
                self?.generateResponse(prompt: prompt, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func getModelPath() -> String {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(modelFilename).path
    }
    
    private func initializeModel(result: @escaping FlutterResult) {
        let modelPath = getModelPath()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Download if needed
            if !FileManager.default.fileExists(atPath: modelPath) {
                self.channel?.invokeMethod("onProgress", arguments: 1)
                self.downloadModel(to: modelPath) { success in
                    if success {
                        self.loadModel(path: modelPath, result: result)
                    } else {
                        DispatchQueue.main.async {
                            result(FlutterError(code: "DOWNLOAD_FAILED", 
                                              message: "Download failed", details: nil))
                        }
                    }
                }
            } else {
                self.loadModel(path: modelPath, result: result)
            }
        }
    }
    
    private func loadModel(path: String, result: @escaping FlutterResult) {
        do {
            let options = LlmInferenceOptions()
            options.modelPath = path
            options.maxTokens = 1024
            options.topk = 40
            options.temperature = 0.8
            
            llmInference = try LlmInference(options: options)
            
            DispatchQueue.main.async { [weak self] in
                self?.channel?.invokeMethod("onProgress", arguments: 100)
                result(true)
            }
        } catch {
            DispatchQueue.main.async {
                result(FlutterError(code: "LOAD_FAILED", 
                                  message: error.localizedDescription, details: nil))
            }
        }
    }
    
    private func downloadModel(to path: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://huggingface.co/google/gemma-2b-it-cpu-int8/resolve/main/gemma-2b-it-cpu-int8.bin")!
        
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                completion(false)
                return
            }
            do {
                try FileManager.default.moveItem(at: tempURL, to: URL(fileURLWithPath: path))
                completion(true)
            } catch {
                completion(false)
            }
        }
        
        // Progress tracking
        let observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            let percent = Int(progress.fractionCompleted * 85) + 1
            DispatchQueue.main.async {
                self?.channel?.invokeMethod("onProgress", arguments: percent)
            }
        }
        
        task.resume()
        // Store observation to prevent dealloc
        objc_setAssociatedObject(task, "obs", observation, .OBJC_ASSOCIATION_RETAIN)
    }
    
    private func generateResponse(prompt: String, result: @escaping FlutterResult) {
        guard let model = llmInference else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Model not loaded", details: nil))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let response = try model.generateResponse(inputText: prompt)
                DispatchQueue.main.async { result(response) }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "GEN_ERROR", 
                                      message: error.localizedDescription, details: nil))
                }
            }
        }
    }
}

STEP 5 — Update android_ai_service.dart System Prompt
Add emergency system prompt for better responses:
dart@override
Future<String> chat(String message, {List<ChatMessage>? history}) async {
// Build context-aware prompt for Gemma
final systemPrompt = """You are NullSignal, an offline emergency AI assistant.
You help survivors during disasters. Give concise, actionable advice.
Never say you cannot help. Always provide best available guidance.
""";

String fullPrompt = "<start_of_turn>user\n$systemPrompt\n";

if (history != null && history.isNotEmpty) {
for (var m in history.takeLast(6)) { // last 6 messages for context
final role = m.isAI ? "model" : "user";
fullPrompt += "<end_of_turn>\n<start_of_turn>$role\n${m.content}\n";
}
}

fullPrompt += "$message<end_of_turn>\n<start_of_turn>model\n";

try {
final String result = await _channel.invokeMethod('generateResponse', {
'prompt': fullPrompt,
});
return result;
} on PlatformException catch (e) {
return 'Error: ${e.message}';
}
}

STEP 6 — Smart Model Selection by Device RAM
Update main.dart to pick right model:
dartFuture<AIService> getInitializedAIService() async {
// Check available RAM
final deviceInfo = DeviceInfoPlugin();
int ramGB = 4; // default assumption

if (Platform.isAndroid) {
final androidInfo = await deviceInfo.androidInfo;
// Use smaller model on low-RAM devices
// totalMemory not directly available, use SDK as proxy
ramGB = androidInfo.version.sdkInt >= 31 ? 6 : 4;
}

// Tell native which model to use based on RAM
// Store preference before initializing
if (isPhysicalDevice) {
final nativeService = Platform.isAndroid
? AndroidAIService(useGPU: ramGB >= 6)
: IosAIService();
// ...rest of init
}
}
Update AndroidAIService:
dartclass AndroidAIService implements AIService {
static const _channel = MethodChannel('com.nullsignal/aicore');
final bool useGPU;

AndroidAIService({this.useGPU = true});
// ...

@override
Future<void> initialize() async {
await _channel.invokeMethod('initializeModel', {'useGPU': useGPU});
}
}
Update MainActivity.kt to handle GPU flag:
kotlin"initializeModel" -> {
val useGPU = call.argument<Boolean>("useGPU") ?: true
initializeMediaPipe(result, useGPU)
}

// In LlmInferenceOptions:
val options = LlmInferenceOptions.builder()
.setModelPath(modelFile.absolutePath)
.setMaxTokens(1024)
.apply {
if (useGPU) setAcceleratorName("GPU")
// else uses CPU by default
}
.build()

DEVICE REQUIREMENTS
ModelRAM neededDevicesgemma-2b-it-gpu-int4.bin4GB+Pixel 6+, S21+, most 2022+ flagshipsgemma-2b-it-cpu-int8.bin4GB+ANY device, slower but universalgemma-3-1b-it-int4.bin2GB+Low-end devices (Gemma 3 1B)
Use cpu-int8 as default — works everywhere, just ~2-3x slower than GPU.

HUGGINGFACE TOKEN (Gemma is gated)
Gemma models require accepting license. Need HF token:
kotlin// In downloadModel(), add auth header:
val connection = url.openConnection() as HttpURLConnection
connection.setRequestProperty("Authorization", "Bearer YOUR_HF_TOKEN")
Get token: huggingface.co → Settings → Access Tokens → New token (read).
Store securely in local.properties:
hf.token=hf_xxxxxxxxxxxx
Read in build.gradle.kts:
kotlinval hfToken = properties.getProperty("hf.token", "")
buildConfigField("String", "HF_TOKEN", "\"$hfToken\"")
Use in Kotlin: BuildConfig.HF_TOKEN