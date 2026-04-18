import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';

class AndroidAIService implements AIService {
  static const _channel = MethodChannel('com.nullsignal/aicore');
  final _progressController = StreamController<int>.broadcast();
  int _lastProgress = 0;

  Stream<int> get downloadProgress async* {
    yield _lastProgress;
    yield* _progressController.stream;
  }
  
  // Expose current progress for immediate checks
  int get currentProgress => _lastProgress;

  AndroidAIService() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onProgress') {
        final dynamic arg = call.arguments;
        final int progress = arg is num ? arg.toInt() : 0;
        
        _lastProgress = progress;
        _progressController.add(progress);
        
        if (progress == -1) {
          developer.log('AICore Download Error detected via MethodChannel');
        }
      }
    });
  }

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
    // Android AICore handles its own resource management
  }
}
