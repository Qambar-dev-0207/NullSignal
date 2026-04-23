import UIKit
import Flutter
import MediaPipeTasksGenAI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var llmInference: LlmInference?
    private var channel: FlutterMethodChannel?
    private let modelFilename = "gemma-4-e2b-it.litertlm"

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
                                              message: "Download failed. Check HF Token and License.", details: nil))
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
        // Gemma 4 E2B IT (Effective 2B) - Universal LiteRT-LM Format
        let url = URL(string: "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm")!
        
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                completion(false)
                return
            }
            do {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
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
        // Store observation to prevent dealloc - using a simple dictionary for simplicity in this example
        // In production use a more robust way to keep observations alive
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
