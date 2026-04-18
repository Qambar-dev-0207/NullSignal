import 'package:null_signal/features/ai/data/models/chat_message.dart';

abstract class AIService {
  /// Whether the AI service is supported on the current device/platform
  Future<bool> isSupported();

  /// Initializes the on-device AI model
  Future<void> initialize();

  /// Gets a triage scoring response based on user symptoms
  Future<String> getTriageResponse(String symptoms);

  /// Gets offline first-aid guidance for a specific injury/condition
  Future<String> getFirstAidGuidance(String condition);

  /// Chat with the AI for general queries
  Future<String> chat(String message, {List<ChatMessage>? history});

  /// Closes the AI engine to free up resources
  Future<void> dispose();
}
