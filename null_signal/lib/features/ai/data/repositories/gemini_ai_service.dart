import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';

class GeminiAIService implements AIService {
  final String apiKey;
  late final GenerativeModel _model;
  ChatSession? _chat;

  GeminiAIService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 1024,
      ),
    );
  }

  @override
  Future<void> initialize() async {
    _chat = _model.startChat();
  }

  @override
  Future<String> getTriageResponse(String symptoms) async {
    final content = [Content.text('Triage this survivor: $symptoms. Assign a START triage color (Green/Yellow/Red) and explain why.')];
    final response = await _model.generateContent(content);
    return response.text ?? 'No response from AI';
  }

  @override
  Future<String> getFirstAidGuidance(String condition) async {
    // FAQ Logic
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('snake') || conditionLower.contains('bite')) {
      return '''
SNAKE BITE EMERGENCY PROTOCOL:
1. Move away from the snake's striking distance.
2. Remain calm and still. Restrict movement.
3. Remove jewelry or tight clothing before swelling starts.
4. Position the limb so that the bite is at or below the level of the heart.
5. Clean the wound with soap and water. Cover it with a clean, dry dressing.
6. DO NOT use a tourniquet or apply ice.
7. DO NOT cut the wound or attempt to suck out the venom.
8. Seek medical help immediately via Mesh Broadcast.
''';
    } else if (conditionLower.contains('wound') || conditionLower.contains('cut') || conditionLower.contains('bleeding')) {
      return '''
WOUND CARE PROTOCOL:
1. Apply direct pressure to the wound with a clean cloth or bandage.
2. Maintain pressure until bleeding stops.
3. If bleeding is severe and won't stop, apply a tourniquet above the injury site if trained.
4. Clean the area around the wound with water.
5. Apply a sterile bandage or clean dressing.
6. Watch for signs of shock (pale skin, rapid pulse).
''';
    } else if (conditionLower.contains('burn')) {
      return '''
BURN MANAGEMENT PROTOCOL:
1. Remove from the heat source immediately.
2. Cool the burn with cool (not cold) running water for 10-20 minutes.
3. Remove restrictive clothing or jewelry near the burn.
4. Cover loosely with a sterile bandage or plastic wrap.
5. Do NOT apply ice, butter, or ointments.
6. For severe burns, monitor breathing and circulation.
''';
    }

    // Fallback to Gemini
    final content = [Content.text('Provide immediate, step-by-step offline first-aid guidance for: $condition. Use clear, numbered steps.')];
    final response = await _model.generateContent(content);
    return response.text ?? 'No response from AI';
  }

  @override
  Future<String> chat(String message) async {
    if (_chat == null) await initialize();
    final response = await _chat!.sendMessage(Content.text(message));
    return response.text ?? 'No response';
  }

  @override
  Future<void> dispose() async {
    // No specific dispose for google_generative_ai
  }
}
