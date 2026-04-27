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
      throw 'Failed to initialize iOS Offline AI (Gemma): ${e.message}';
    }
  }

  @override
  Stream<int> get downloadProgress => Stream.value(100);

  @override
  Future<String> getTriageResponse(String symptoms) async {
    return chat('Triage this survivor: $symptoms. Assign a START triage color (Green/Yellow/Red) and explain why.');
  }

  @override
  Future<String> getFirstAidGuidance(String condition) async {
    return chat('Provide immediate, step-by-step offline first-aid guidance for: $condition. Use clear, numbered steps.');
  }

  @override
  Future<String> chat(String message, {List<ChatMessage>? history}) async {
    // Build context-aware prompt for Gemma
    final systemPrompt = """You are NullSignal, an offline emergency AI assistant.
You help survivors during disasters. Give concise, actionable advice.
Never say you cannot help. Always provide best available guidance.
""";

    String fullPrompt = "<start_of_turn>user\n$systemPrompt\n";

    if (history != null && history.isNotEmpty) {
      // Last 6 messages for context to stay within token limits
      final contextHistory = history.length > 6 ? history.sublist(history.length - 6) : history;
      for (var m in contextHistory) {
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

  @override
  Future<void> dispose() async {
    // MediaPipe resources on iOS are managed by the AppDelegate instance
  }
}
