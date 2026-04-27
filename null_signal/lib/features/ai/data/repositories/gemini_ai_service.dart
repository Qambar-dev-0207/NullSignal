import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';
import 'package:null_signal/features/ai/data/repositories/android_ai_service.dart';

class GeminiAIService implements AIService {
  final String apiKey;
  final AIService? nativeService;
  late final GenerativeModel _model;
  ChatSession? _chat;

  bool get isProvisioned {
    if (nativeService is AndroidAIService) {
      return (nativeService as AndroidAIService).currentProgress == 100;
    }
    // For iOS, assume provisioned once initialized (AppDelegate handles download internally)
    return true;
  }

  @override
  Stream<int> get downloadProgress {
    if (nativeService is AndroidAIService) {
      return (nativeService as AndroidAIService).downloadProgress;
    }
    // iOS doesn't expose progress yet via MethodChannel in this implementation, return 100 for simplicity
    return Stream.value(100);
  }

  GeminiAIService({required this.apiKey, this.nativeService}) {
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
  Future<bool> isSupported() async => true; 

  @override
  Future<void> initialize() async {
    if (nativeService != null) {
      try {
        await nativeService!.initialize();
      } catch (e) {
        developer.log('Native AI init failed: $e');
        rethrow; // Rethrow to let the UI/Orchestrator handle the failure
      }
    }
    
    if (apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY') {
      try {
        _chat = _model.startChat();
      } catch (e) {
        developer.log('GeminiAIService: Failed to initialize chat: $e');
      }
    }
  }

  @override
  Future<String> getTriageResponse(String symptoms) async {
    // 1. Try Native AI first
    if (nativeService != null) {
      try {
        final response = await nativeService!.getTriageResponse(symptoms);
        if (!response.contains('Error')) return response;
      } catch (_) {}
    }

    // 2. Try Cloud AI if apiKey exists
    if (apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY') {
      try {
        final content = [Content.text('Triage this survivor: $symptoms. Assign a START triage color (Green/Yellow/Red) and explain why.')];
        final response = await _model.generateContent(content);
        return response.text ?? _calculateOfflineTriage(symptoms);
      } catch (e) {
        // Fallback to heuristics
      }
    }

    // 3. Absolute Fallback: Local Heuristics
    return _calculateOfflineTriage(symptoms);
  }

  @override
  Future<String> getFirstAidGuidance(String condition) async {
    // FAQ Logic (Always works first, highly reliable)
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('snake') || conditionLower.contains('bite')) {
      return _snakeBiteGuidance;
    } else if (conditionLower.contains('wound') || conditionLower.contains('cut') || conditionLower.contains('bleeding')) {
      return _woundCareGuidance;
    } else if (conditionLower.contains('burn')) {
      return _burnMgmtGuidance;
    }

    // Try Native
    if (nativeService != null) {
      try {
        final response = await nativeService!.getFirstAidGuidance(condition);
        if (!response.contains('Error')) return response;
      } catch (_) {}
    }

    // Try Cloud
    if (apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY') {
      try {
        final content = [Content.text('Provide immediate, step-by-step offline first-aid guidance for: $condition. Use clear, numbered steps.')];
        final response = await _model.generateContent(content);
        return response.text ?? "OFFLINE: Protocol for '$condition' not found.";
      } catch (_) {}
    }

    return "OFFLINE MODE: Guidance for '$condition' is currently unavailable locally.";
  }

  @override
  Future<String> chat(String message, {List<ChatMessage>? history}) async {
    // Try Native
    if (nativeService != null) {
      try {
        final response = await nativeService!.chat(message, history: history);
        if (!response.contains('Error')) return response;
      } catch (_) {}
    }

    // Try Cloud
    if (apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY') {
      try {
        if (_chat == null) {
          final historyContent = history?.map((m) => Content(
            m.isAI ? 'model' : 'user',
            [TextPart(m.content)],
          )).toList() ?? [];
          _chat = _model.startChat(history: historyContent);
        }
        
        final response = await _chat!.sendMessage(Content.text(message));
        return response.text ?? _generatePseudoAiResponse(message);
      } catch (e) {
        // Fallback
      }
    }

    return _generatePseudoAiResponse(message);
  }

  String _calculateOfflineTriage(String symptoms) {
    final s = symptoms.toLowerCase();
    String color = "GREEN";
    String reasoning = "Walking wounded or minor injuries.";

    if (s.contains('dead') || s.contains('no pulse') || s.contains('no breath')) {
      color = "BLACK";
      reasoning = "Deceased or non-salvageable given current resources.";
    } else if (s.contains('breath') || s.contains('unconscious') || s.contains('severe bleeding') || s.contains('pulse')) {
      color = "RED";
      reasoning = "Immediate life-threat detected (Respiratory/Circulatory failure).";
    } else if (s.contains('pain') || s.contains('break') || s.contains('fracture') || s.contains('cannot walk')) {
      color = "YELLOW";
      reasoning = "Serious but non-life-threatening. Delayed response acceptable.";
    }

    return "[OFFLINE_AI_CORE] STATUS: $color\nANALYSIS: $reasoning\n\nNote: This is an on-device rule-based assessment.";
  }

  String _generatePseudoAiResponse(String message) {
    final m = message.toLowerCase();
    
    if (m.contains('hello') || m.contains('hi')) {
      return "SYSTEM: Identity confirmed. I am the NullSignal On-Device Tactical Assistant. I am currently running in [LOCAL_HEURISTIC_MODE] because a cloud uplink is unavailable. How can I assist with your emergency coordination?";
    }
    
    if (m.contains('water') || m.contains('food') || m.contains('supplies')) {
      return "RESOURCE_BROKER: Searching local mesh for supplies... No active resource packets found in range. Recommendation: Broadcast a 'NEED' packet via the SOS menu.";
    }

    if (m.contains('where') || m.contains('location') || m.contains('map')) {
      return "INTELLIGENCE: GPS signal is degraded. Refer to the Intelligence tab for local hazard overlays and known relay positions.";
    }

    if (m.contains('who') || m.contains('nodes') || m.contains('people')) {
      return "MESH_NETWORK: I detect multiple encrypted nodes in your vicinity. Check the 'NEARBY' tab to see their 3D topology and signal strength.";
    }

    if (m.contains('help') || m.contains('emergency') || m.contains('sos')) {
      return "TACTICAL_ADVICE: If you are in immediate danger, HOLD the SOS button for 3 seconds. This will initiate a high-priority mesh broadcast and attempt satellite escalation.";
    }

    return "OFFLINE_CORE: I understand your query regarding '$message', but my complex reasoning engine requires a secure cloud bridge for a full analysis. In the meantime, I can provide pre-loaded protocols for MEDICAL, MESH, or SOS procedures.";
  }

  static const String _snakeBiteGuidance = '''
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

  static const String _woundCareGuidance = '''
WOUND CARE PROTOCOL:
1. Apply direct pressure to the wound with a clean cloth or bandage.
2. Maintain pressure until bleeding stops.
3. If bleeding is severe and won't stop, apply a tourniquet above the injury site if trained.
4. Clean the area around the wound with water.
5. Apply a sterile bandage or clean dressing.
6. Watch for signs of shock (pale skin, rapid pulse).
''';

  static const String _burnMgmtGuidance = '''
BURN MANAGEMENT PROTOCOL:
1. Remove from the heat source immediately.
2. Cool the burn with cool (not cold) running water for 10-20 minutes.
3. Remove restrictive clothing or jewelry near the burn.
4. Cover loosely with a sterile bandage or plastic wrap.
5. Do NOT apply ice, butter, or ointments.
6. For severe burns, monitor breathing and circulation.
''';

  @override
  Future<void> dispose() async {
    // No specific dispose for google_generative_ai
  }
}
