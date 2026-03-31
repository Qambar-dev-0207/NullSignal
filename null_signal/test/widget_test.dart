import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/mesh/data/repositories/simulated_mesh_service.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:null_signal/main.dart';

class MockAIService extends Mock implements AIService {}
class MockIsar extends Mock implements Isar {}
class MockIsarCollection extends Mock implements IsarCollection<ChatMessage> {}
class MockQuery extends Mock implements Query<ChatMessage> {}
class MockQueryBuilder extends Mock implements QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> {}

void main() {
  late MockAIService aiService;
  late MockIsar isar;
  late MockIsarCollection chatMessageCollection;

  setUp(() {
    aiService = MockAIService();
    isar = MockIsar();
    chatMessageCollection = MockIsarCollection();

    when(() => aiService.initialize()).thenAnswer((_) async {});
    when(() => aiService.chat(any())).thenAnswer((_) async => "Mock AI Response");
    
    // Setup Isar mock for chat history
    // Note: This is simplified. Isar's query API is complex to mock fully.
    // For a smoke test, we just need it to not crash.
    when(() => isar.chatMessages).thenReturn(chatMessageCollection);
    
    // We need to mock the extension getter or just ensure it returns an empty list
    // In AiCubit: await _isar.chatMessages.where().sortByTimestamp().findAll();
    // This is hard to mock without proper fakes. 
    // I'll try to just return an empty list if possible.
  });

  testWidgets('NullSignal smoke test', (WidgetTester tester) async {
    final gatewayMonitor = GatewayMonitor();
    final securityService = SecurityService();
    final meshService = SimulatedMeshService(gatewayMonitor, securityService);
    final safetyMonitor = SafetyMonitor();

    // Build our app and trigger a frame.
    // We expect AiCubit to call initialize() which will call isar.chatMessages
    // Since we didn't fully mock the query chain, it might fail here.
    // However, for a smoke test, if it reaches SOS screen, it's good.
    
    await tester.pumpWidget(NullSignalApp(
      meshService: meshService,
      aiService: aiService,
      securityService: securityService,
      safetyMonitor: safetyMonitor,
      isar: isar,
    ));

    // Verify system status text exists
    expect(find.text('SOS'), findsWidgets);

    // Switch to STATUS tab (index 0)
    await tester.tap(find.byIcon(Icons.monitor_heart_outlined));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    
    expect(find.text('SYSTEM STATUS'), findsOneWidget);
    expect(find.text('FULLY OPERATIONAL'), findsOneWidget);

    // Switch to MESH tab (index 2)
    await tester.tap(find.byIcon(Icons.hub_outlined));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('LIVE MESH CLOUD'), findsOneWidget);

    // Stop mesh service to cancel timers
    await meshService.stop();
  });
}
