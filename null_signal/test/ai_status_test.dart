import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';
import 'package:null_signal/features/ai/data/repositories/gemini_ai_service.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';

// --- Fake native AI service ---

class FakeNativeAIService implements AIService {
  final bool provisioned;
  final String? fixedResponse;
  final bool shouldThrow;
  int _progress;

  final _progressController = StreamController<int>.broadcast();

  FakeNativeAIService({
    this.provisioned = false,
    this.fixedResponse,
    this.shouldThrow = false,
    int initialProgress = 0,
  }) : _progress = initialProgress;

  @override
  Stream<int> get downloadProgress async* {
    yield _progress;
    yield* _progressController.stream;
  }

  int get currentProgress => _progress;

  void setProgress(int p) {
    _progress = p;
    _progressController.add(p);
  }

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<void> initialize() async {
    if (shouldThrow) throw 'LOAD_FAILED: Model failed.';
    setProgress(100);
  }

  @override
  Future<String> chat(String message, {List<ChatMessage>? history}) async {
    if (!provisioned) throw Exception('NOT_READY');
    if (shouldThrow) throw Exception('GEN_ERROR');
    return fixedResponse ?? 'Native response to: $message';
  }

  @override
  Future<String> getTriageResponse(String symptoms) async {
    if (!provisioned) throw Exception('NOT_READY');
    if (shouldThrow) throw Exception('GEN_ERROR');
    return fixedResponse ?? '[NATIVE_TRIAGE] RED for: $symptoms';
  }

  @override
  Future<String> getFirstAidGuidance(String condition) async {
    if (!provisioned) throw Exception('NOT_READY');
    if (shouldThrow) throw Exception('GEN_ERROR');
    return fixedResponse ?? '[NATIVE_GUIDE] Steps for: $condition';
  }

  @override
  Future<void> dispose() async => _progressController.close();
}

/// Subclass that overrides isProvisioned for test control.
class TestableGeminiAIService extends GeminiAIService {
  final bool _provisioned;

  TestableGeminiAIService({
    required String apiKey,
    required AIService? nativeService,
    required bool provisioned,
  })  : _provisioned = provisioned,
        super(apiKey: apiKey, nativeService: nativeService);

  @override
  bool get isProvisioned => _provisioned;
}

// --- Tests ---

void main() {
  group('AI status — offline heuristic mode (model not loaded)', () {
    late TestableGeminiAIService aiService;

    setUp(() {
      aiService = TestableGeminiAIService(
        apiKey: '',
        nativeService: FakeNativeAIService(provisioned: false),
        provisioned: false,
      );
    });

    test('chat falls to heuristic when model not provisioned', () async {
      final response = await aiService.chat('hello');
      expect(response, contains('LOCAL_HEURISTIC_MODE'));
    });

    test('getTriageResponse falls to rule-based triage when not provisioned', () async {
      final response = await aiService.getTriageResponse('no breath, no pulse');
      expect(response, contains('[OFFLINE_AI_CORE]'));
      expect(response, contains('BLACK'));
    });

    test('getFirstAidGuidance returns pre-loaded protocol when not provisioned', () async {
      final response = await aiService.getFirstAidGuidance('snake bite');
      expect(response, contains('SNAKE BITE EMERGENCY PROTOCOL'));
    });

    test('chat identifies SOS queries correctly in heuristic mode', () async {
      final response = await aiService.chat('emergency SOS help');
      expect(response, contains('TACTICAL_ADVICE'));
    });

    test('chat identifies resource queries in heuristic mode', () async {
      final response = await aiService.chat('need water and food');
      expect(response, contains('RESOURCE_BROKER'));
    });
  });

  group('AI status — native model loaded (isProvisioned = true)', () {
    late TestableGeminiAIService aiService;

    setUp(() {
      aiService = TestableGeminiAIService(
        apiKey: '',
        nativeService: FakeNativeAIService(
          provisioned: true,
          fixedResponse: 'GEMMA_RESPONSE: Stay calm and apply pressure.',
        ),
        provisioned: true,
      );
    });

    test('chat uses native model when provisioned', () async {
      final response = await aiService.chat('what do I do?');
      expect(response, equals('GEMMA_RESPONSE: Stay calm and apply pressure.'));
    });

    test('getTriageResponse uses native model when provisioned', () async {
      final response = await aiService.getTriageResponse('heavy bleeding');
      expect(response, equals('GEMMA_RESPONSE: Stay calm and apply pressure.'));
    });

    test('getFirstAidGuidance uses native model when provisioned — non-FAQ condition', () async {
      // Use 'hypothermia' — does not match any FAQ keyword (snake/bite/wound/cut/bleeding/burn)
      final response = await aiService.getFirstAidGuidance('hypothermia');
      expect(response, equals('GEMMA_RESPONSE: Stay calm and apply pressure.'));
    });

    test('Native response returned directly — no fragile Error-string filtering', () async {
      final aiWithErrorWord = TestableGeminiAIService(
        apiKey: '',
        nativeService: FakeNativeAIService(
          provisioned: true,
          fixedResponse: 'Error: Do not apply ice. That is an Error people make.',
        ),
        provisioned: true,
      );
      // Old code discarded responses containing "Error" — new code does not.
      final response = await aiWithErrorWord.chat('burn treatment');
      expect(response, contains('Error: Do not apply ice'));
    });
  });

  group('AI status — native throws, fallback chain works', () {
    test('Falls to heuristic when provisioned native throws on chat', () async {
      final aiService = TestableGeminiAIService(
        apiKey: '',
        nativeService: FakeNativeAIService(provisioned: true, shouldThrow: true),
        provisioned: true,
      );
      // Native throws → no API key → heuristic
      final response = await aiService.chat('hello');
      expect(response, contains('LOCAL_HEURISTIC_MODE'));
    });

    test('getTriageResponse falls to heuristic when native throws', () async {
      final aiService = TestableGeminiAIService(
        apiKey: '',
        nativeService: FakeNativeAIService(provisioned: true, shouldThrow: true),
        provisioned: true,
      );
      final response = await aiService.getTriageResponse('minor scratch');
      expect(response, contains('[OFFLINE_AI_CORE]'));
    });
  });

  group('AI status — isProvisioned behavior', () {
    test('isProvisioned false when TestableGeminiAIService provisioned=false', () {
      final aiService = TestableGeminiAIService(
        apiKey: '',
        nativeService: FakeNativeAIService(provisioned: false),
        provisioned: false,
      );
      expect(aiService.isProvisioned, isFalse);
    });

    test('isProvisioned true when TestableGeminiAIService provisioned=true', () {
      final aiService = TestableGeminiAIService(
        apiKey: '',
        nativeService: FakeNativeAIService(provisioned: true),
        provisioned: true,
      );
      expect(aiService.isProvisioned, isTrue);
    });

    test('downloadProgress proxies to native for AndroidAIService — non-Android yields 100', () async {
      // GeminiAIService.downloadProgress returns Stream.value(100) when native
      // is not AndroidAIService (e.g. iOS or test fake). Verify the contract.
      final fakeNative = FakeNativeAIService(initialProgress: 72);
      final aiService = GeminiAIService(apiKey: '', nativeService: fakeNative);
      // Non-AndroidAIService: downloadProgress returns Stream.value(100)
      final first = await aiService.downloadProgress.first;
      expect(first, equals(100));
    });

    test('downloadProgress returns Stream.value(100) when nativeService is null', () async {
      final aiService = GeminiAIService(apiKey: '');
      final first = await aiService.downloadProgress.first;
      expect(first, equals(100));
    });
  });

  group('Offline AI heuristic triage rules', () {
    late GeminiAIService aiService;

    setUp(() {
      aiService = GeminiAIService(apiKey: '');
    });

    test('BLACK for deceased indicators', () async {
      final r = await aiService.getTriageResponse('dead, no pulse, no breath');
      expect(r, contains('BLACK'));
    });

    test('RED for unconscious with breathing', () async {
      // "unconscious but breathing" — does NOT trigger "no breath" → RED
      final r = await aiService.getTriageResponse('unconscious but breathing');
      expect(r, contains('RED'));
    });

    test('RED for severe bleeding', () async {
      final r = await aiService.getTriageResponse('severe bleeding from leg');
      expect(r, contains('RED'));
    });

    test('YELLOW for fracture/non-ambulatory', () async {
      final r = await aiService.getTriageResponse('broken leg, cannot walk');
      expect(r, contains('YELLOW'));
    });

    test('GREEN for minor injuries', () async {
      final r = await aiService.getTriageResponse('minor scratch on arm');
      expect(r, contains('GREEN'));
    });
  });

  group('FAQ first-aid protocols — always available offline', () {
    late GeminiAIService aiService;

    setUp(() {
      aiService = GeminiAIService(apiKey: '');
    });

    test('Snake bite protocol returned', () async {
      final r = await aiService.getFirstAidGuidance('snake bite');
      expect(r, contains('SNAKE BITE EMERGENCY PROTOCOL'));
      expect(r, contains('DO NOT use a tourniquet'));
    });

    test('Wound care protocol returned', () async {
      final r = await aiService.getFirstAidGuidance('deep wound');
      expect(r, contains('WOUND CARE PROTOCOL'));
    });

    test('Burn protocol returned', () async {
      final r = await aiService.getFirstAidGuidance('burn injury');
      expect(r, contains('BURN MANAGEMENT PROTOCOL'));
    });

    test('Unknown condition falls through to generic offline message', () async {
      final r = await aiService.getFirstAidGuidance('alien parasite');
      expect(r, contains('OFFLINE MODE'));
    });
  });
}
