import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let aiChannel = FlutterMethodChannel(name: "com.nullsignal/aicore",
                                          binaryMessenger: controller.binaryMessenger)
    
    aiChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "initializeModel" {
        // In production, this would initialize MediaPipe LLM Inference or CoreML/Gemma
        // Google's MediaPipe LLM Inference API is the recommended way for iOS local AI
        print("Initializing iOS Offline AI (MediaPipe/Gemma)...")
        
        // Simulating async initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            result(true)
        }
      } else if call.method == "generateResponse" {
        guard let args = call.arguments as? [String: Any],
              let prompt = args["prompt"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing prompt", details: nil))
          return
        }
        
        // Simulating heavy local inference
        DispatchQueue.global(qos: .userInitiated).async {
            // Processing local weights...
            let response = self.simulateOfflineAI(prompt: prompt)
            
            DispatchQueue.main.async {
                result(response)
            }
        }
      } else if call.method == "dispose" {
        print("Disposing iOS Offline AI resources...")
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func simulateOfflineAI(prompt: String) -> String {
    let lowerPrompt = prompt.lowercased()
    if lowerPrompt.contains("triage") {
        return "**[iOS NANO-AI TRIAGE]**\n\n**Protocol:** START\n**Color:** YELLOW (Immediate Observation)\n**Rationale:** User reports difficulty breathing but is conscious. Pulse present.\n**Advice:** Monitor SpO2 if pulse-ox available. Elevate head."
    } else if lowerPrompt.contains("first-aid") {
        return "**[iOS NANO-AI FIRST AID]**\n\n1. Ensure scene safety.\n2. Call for backup via mesh.\n3. Apply tourniquet if bleeding is arterial and uncontrolled.\n4. Document time of application."
    } else {
        return "[iOS OFFLINE AI] Local inference complete. I am here to help with your emergency mesh queries without an internet connection."
    }
  }
}
