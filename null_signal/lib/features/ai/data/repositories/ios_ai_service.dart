import 'package:flutter/services.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';

class IosAIService implements AIService {
  static const _channel = MethodChannel('com.nullsignal/aicore');

  @override
  Future<bool> isSupported() async {
    try {
      final bool supported = await _channel.invokeMethod('isSupported');
      return supported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initializeModel');
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
  Future<String> chat(String message, {List<ChatMessage>? history}) async {
    try {
      String fullPrompt = "";
      if (history != null && history.isNotEmpty) {
        fullPrompt = "Previous conversation history for context:\n";
        for (var m in history) {
          fullPrompt += "${m.isAI ? 'AI' : 'User'}: ${m.content}\n";
        }
        fullPrompt += "\nCurrent Query: ";
      }
      fullPrompt += message;

      final String result = await _channel.invokeMethod('generateResponse', {
        'prompt': fullPrompt,
      });
      return result;
    } on PlatformException catch (e) {
      return 'Error in chat: ${e.message}';
    }
  }


  @override
  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
  }
}
