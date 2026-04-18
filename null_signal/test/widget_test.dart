import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/mesh/data/repositories/simulated_mesh_service.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:null_signal/main.dart';
import 'package:null_signal/features/ai/domain/repositories/mesh_insight_service.dart';
import 'package:null_signal/core/services/satellite_gateway_service.dart';
import 'package:null_signal/features/ai/data/repositories/resource_broker_service.dart';
import 'package:null_signal/features/intelligence/domain/repositories/intelligence_service.dart';

class MockAIService extends Mock implements AIService {}
class MockIsar extends Mock implements Isar {}
class MockIsarCollection extends Mock implements IsarCollection<ChatMessage> {}
class MockMeshInsightService extends Mock implements MeshInsightService {}
class MockSatelliteGatewayService extends Mock implements SatelliteGatewayService {}
class MockIntelligenceService extends Mock implements IntelligenceService {}

void main() {
  late MockAIService aiService;
  late MockIsar isar;
  late MockIsarCollection chatMessageCollection;
  late MockMeshInsightService meshInsightService;
  late MockSatelliteGatewayService satelliteService;
  late MockIntelligenceService intelligenceService;

  setUp(() {
    aiService = MockAIService();
    isar = MockIsar();
    chatMessageCollection = MockIsarCollection();
    meshInsightService = MockMeshInsightService();
    satelliteService = MockSatelliteGatewayService();
    intelligenceService = MockIntelligenceService();

    when(() => aiService.initialize()).thenAnswer((_) async {});
    when(() => aiService.chat(any())).thenAnswer((_) async => "Mock AI Response");
    
    when(() => isar.chatMessages).thenReturn(chatMessageCollection);
    
    when(() => meshInsightService.start()).thenReturn(null);
    when(() => meshInsightService.sectorSummariesStream).thenAnswer((_) => const Stream.empty());
    when(() => meshInsightService.getStoredSummaries()).thenAnswer((_) async => []);

    when(() => intelligenceService.hazardPolygonsStream).thenAnswer((_) => const Stream.empty());
    when(() => intelligenceService.neighborCountStream).thenAnswer((_) => const Stream.empty());
    when(() => intelligenceService.crowdAlertsStream).thenAnswer((_) => const Stream.empty());
    when(() => intelligenceService.localGForceStream).thenAnswer((_) => const Stream.empty());
    when(() => intelligenceService.damageHeatmapStream).thenAnswer((_) => const Stream.empty());
    when(() => intelligenceService.start()).thenReturn(null);
  });

  testWidgets('NullSignal smoke test', (WidgetTester tester) async {
    final gatewayMonitor = GatewayMonitor();
    final securityService = SecurityService(isar);
    final meshService = SimulatedMeshService(gatewayMonitor, securityService, isar);
    final safetyMonitor = SafetyMonitor();
    final resourceBroker = ResourceBrokerService(meshService, aiService, isar);

    await tester.pumpWidget(NullSignalApp(
      meshService: meshService,
      aiService: aiService,
      meshInsightService: meshInsightService,
      satelliteService: satelliteService,
      resourceBroker: resourceBroker,
      intelligenceService: intelligenceService,
      securityService: securityService,
      safetyMonitor: safetyMonitor,
      isar: isar,
    ));

    // Verify system status text exists
    expect(find.text('SOS'), findsWidgets);

    // Stop mesh service to cancel timers
    await meshService.stop();
  });
}
