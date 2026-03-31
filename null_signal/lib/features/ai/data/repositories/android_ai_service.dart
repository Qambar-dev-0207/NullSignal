import 'package:flutter/services.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';

class AndroidAIService implements AIService {
  static const _channel = MethodChannel('com.nullsignal/aicore');

  @override
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initializeModel');
    } on PlatformException catch (e) {
      throw 'Failed to initialize Gemini Nano: ${e.message}';
    }
  }

  @override
  Future<String> getTriageResponse(String symptoms) async {
    try {
      final String result = await _channel.invokeMethod('generateResponse', {
        'prompt': 'Triage this survivor: $symptoms. Assign a START triage color (Green/Yellow/Red) and explain why.',
      });
      return result;
    } on PlatformException catch (e) {
      return 'Error generating triage: ${e.message}';
    }
  }

  @override
  Future<String> getFirstAidGuidance(String condition) async {
    try {
      final String result = await _channel.invokeMethod('generateResponse', {
        'prompt': 'Provide immediate, step-by-step offline first-aid guidance for: $condition. Use clear, numbered steps.',
      });
      return result;
    } on PlatformException catch (e) {
      return 'Error generating guidance: ${e.message}';
    }
  }

  @override
  Future<String> chat(String message) async {
    try {
      final String result = await _channel.invokeMethod('generateResponse', {
        'prompt': message,
      });
      return result;
    } on PlatformException catch (e) {
      return 'Error in chat: ${e.message}';
    }
  }

  @override
  Future<void> dispose() async {
    // Android AICore handles its own resource management
  }
}
