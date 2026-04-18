import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:null_signal/features/ai/presentation/bloc/ai_cubit.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/domain/repositories/mesh_insight_service.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';

class MockAIService extends Mock implements AIService {}
class MockMeshInsightService extends Mock implements MeshInsightService {}

void main() {
  late AiCubit aiCubit;
  late MockAIService mockAiService;
  late MockMeshInsightService mockMeshInsightService;
  late Isar isar;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_test');
    isar = await Isar.open(
      [ChatMessageSchema],
      directory: tempDir.path,
    );
    mockAiService = MockAIService();
    mockMeshInsightService = MockMeshInsightService();
    
    when(() => mockMeshInsightService.sectorSummariesStream).thenAnswer((_) => const Stream.empty());
    when(() => mockMeshInsightService.getStoredSummaries()).thenAnswer((_) async => []);
    
    aiCubit = AiCubit(mockAiService, mockMeshInsightService, isar);
  });

  tearDown(() async {
    await aiCubit.close();
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AiCubit Initialization', () {
    test('initial state is AiInitial', () {
      expect(aiCubit.state, isA<AiInitial>());
    });

    test('initialize emits AiResponse on success', () async {
      when(() => mockAiService.initialize()).thenAnswer((_) async => {});
      
      final expectation = expectLater(
        aiCubit.stream,
        emitsInOrder([
          isA<AiResponse>(),
        ]),
      );

      await aiCubit.initialize();

      await expectation;
      final state = aiCubit.state as AiResponse;
      expect(state.title, 'SYSTEM READY');
      verify(() => mockAiService.initialize()).called(1);
    });

    test('initialize emits AiError on service failure', () async {
      when(() => mockAiService.initialize()).thenThrow(Exception('Init Error'));
      
      final expectation = expectLater(
        aiCubit.stream,
        emitsInOrder([
          isA<AiError>(),
        ]),
      );

      await aiCubit.initialize();

      await expectation;
      final state = aiCubit.state as AiError;
      expect(state.message, contains('Init Error'));
    });
  });

  group('AiCubit Message Handling', () {
    test('sendMessage emits AiLoading then AiResponse', () async {
      when(() => mockAiService.chat(any(), history: any(named: 'history'))).thenAnswer((_) async => 'Mock Response');

      final expectation = expectLater(
        aiCubit.stream,
        emitsInOrder([
          isA<AiLoading>(),
          isA<AiResponse>(),
        ]),
      );

      await aiCubit.sendMessage('Hello');

      await expectation;
      final state = aiCubit.state as AiResponse;
      expect(state.content, 'Mock Response');
      
      // Verify persistence
      final messages = await isar.chatMessages.where().findAll();
      expect(messages.length, 2);
      expect(messages[0].content, 'Hello');
      expect(messages[1].content, 'Mock Response');
    });

    test('sendMessage emits AiError on chat failure', () async {
      when(() => mockAiService.chat(any(), history: any(named: 'history'))).thenThrow(Exception('Chat Error'));

      final expectation = expectLater(
        aiCubit.stream,
        emitsInOrder([
          isA<AiLoading>(),
          isA<AiError>(),
        ]),
      );

      await aiCubit.sendMessage('Hello');

      await expectation;
      final state = aiCubit.state as AiError;
      expect(state.message, contains('Chat Error'));
    });
  });
}
