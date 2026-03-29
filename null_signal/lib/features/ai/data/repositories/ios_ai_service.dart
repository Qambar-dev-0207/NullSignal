import 'package:flutter/services.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';

class IosAIService implements AIService {
  static const _channel = MethodChannel('com.nullsignal/mediapipe');

  @override
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initializeGemma');
    } on PlatformException catch (e) {
      throw 'Failed to initialize iOS AI: ${e.message}';
    }
  }

  @override
  Future<String> getTriageResponse(String symptoms) async {
    try {
      final String result = await _channel.invokeMethod('generateResponse', {
        'prompt': 'System: Offline Triage Assistant. Symptoms: $symptoms. Scoring: START.',
      });
      return result;
    } on PlatformException catch (e) {
      return 'iOS AI Error: ${e.message}';
    }
  }

  @override
  Future<String> getFirstAidGuidance(String condition) async {
    try {
      final String result = await _channel.invokeMethod('generateResponse', {
        'prompt': 'First Aid Guidance: $condition. Steps:',
      });
      return result;
    } on PlatformException catch (e) {
      return 'iOS AI Error: ${e.message}';
    }
  }

  @override
  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
  }
}
