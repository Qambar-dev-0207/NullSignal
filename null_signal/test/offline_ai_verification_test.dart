import 'package:flutter_test/flutter_test.dart';
import 'package:null_signal/features/ai/data/repositories/gemini_ai_service.dart';

void main() {
  group('GeminiAIService Offline Verification', () {
    late GeminiAIService aiService;

    setUp(() {
      // Initialize with empty key to trigger offline mode
      aiService = GeminiAIService(apiKey: '');
    });

    test('chat should return pseudo-AI response in offline mode', () async {
      final response = await aiService.chat('hello');
      expect(response, contains('Identity confirmed'));
      expect(response, contains('LOCAL_HEURISTIC_MODE'));
    });

    test('chat should handle resource queries offline', () async {
      final response = await aiService.chat('need water');
      expect(response, contains('RESOURCE_BROKER'));
      expect(response, contains('supplies'));
    });

    test('getTriageResponse should return rule-based triage', () async {
      final response = await aiService.getTriageResponse('heavy bleeding and no breath');
      expect(response, contains('STATUS: BLACK'));
      expect(response, contains('Deceased'));
    });

    test('getTriageResponse should return RED for immediate threats', () async {
      final response = await aiService.getTriageResponse('unconscious but breathing');
      expect(response, contains('STATUS: RED'));
    });

    test('getFirstAidGuidance should return pre-loaded protocols', () async {
      final response = await aiService.getFirstAidGuidance('snake bite');
      expect(response, contains('SNAKE BITE EMERGENCY PROTOCOL'));
      expect(response, contains('DO NOT use a tourniquet'));
    });
  });
}
