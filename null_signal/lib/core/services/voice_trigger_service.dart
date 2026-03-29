import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class VoiceTriggerService {
  static const _channel = MethodChannel('com.nullsignal/voice_sos');

  /// Starts listening for the system-level "NullSignal SOS" wake word.
  /// This typically connects to Siri Shortcuts or Android Voice Interaction.
  static Future<void> initializeVoiceTrigger({required Function onTrigger}) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onVoiceSosTriggered') {
        onTrigger();
      }
    });
    
    try {
      await _channel.invokeMethod('registerVoiceShortcut');
    } on PlatformException catch (e) {
      // Log or handle error - common on devices without voice assistant support
      developer.log('Voice trigger registration failed: ${e.message}', name: 'VoiceTriggerService');
    }
  }
}
