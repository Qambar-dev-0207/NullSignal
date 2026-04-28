import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/models/identity.dart';
import 'package:null_signal/core/models/peer.dart';
import 'package:null_signal/core/models/contact.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';
import 'package:null_signal/features/ai/domain/entities/sector_summary.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/core/services/satellite_gateway_service.dart';
import 'package:null_signal/features/ai/data/repositories/resource_broker_service.dart';
import 'package:null_signal/features/ai/data/repositories/gemini_ai_service.dart';
import 'package:null_signal/features/ai/data/repositories/android_ai_service.dart';
import 'package:null_signal/features/ai/data/repositories/ios_ai_service.dart';
import 'package:null_signal/features/ai/data/repositories/mesh_insight_service_impl.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/domain/repositories/mesh_insight_service.dart';
import 'package:null_signal/features/ai/presentation/bloc/ai_cubit.dart';
import 'package:null_signal/features/mesh/data/repositories/nearby_mesh_service_impl.dart';
import 'package:null_signal/features/mesh/data/repositories/simulated_mesh_service.dart';
import 'package:null_signal/features/intelligence/data/repositories/intelligence_service_impl.dart';
import 'package:null_signal/features/intelligence/domain/repositories/intelligence_service.dart';
import 'package:null_signal/features/intelligence/presentation/bloc/intelligence_cubit.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';
import 'package:null_signal/features/sos/presentation/pages/panic_navigation_wrapper.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('[SYSTEM] System Booting...', name: 'System');

  try {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [MeshPacketSchema, ChatMessageSchema, IdentitySchema, PeerSchema, ContactSchema, SeenPacketSchema, SectorSummarySchema],
      directory: dir.path,
    );

    final deviceInfo = DeviceInfoPlugin();
    bool isPhysicalDevice = true;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        isPhysicalDevice = androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        isPhysicalDevice = iosInfo.isPhysicalDevice;
      }
    } catch (_) {
      isPhysicalDevice = false;
    }

    final gatewayMonitor = GatewayMonitor()..start();
    final securityService = SecurityService(isar);
    final satelliteService = SatelliteGatewayServiceImpl();
    await securityService.getOrCreateIdentity();
    final safetyMonitor = SafetyMonitor()..start();

    final MeshService meshService = isPhysicalDevice 
        ? NearbyMeshServiceImpl(gatewayMonitor, securityService, isar, satelliteService: satelliteService) 
        : SimulatedMeshService(gatewayMonitor, securityService, isar);
    
    AIService? nativeService;
    if (isPhysicalDevice) {
      nativeService = Platform.isAndroid ? AndroidAIService(useGPU: true) : IosAIService();
    }
    
    const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    final aiService = GeminiAIService(apiKey: geminiApiKey, nativeService: nativeService, gatewayMonitor: gatewayMonitor);
    // NOTE: Do NOT call aiService.initialize() here. AiCubit handles initialization
    // and emits progress to the UI. A duplicate call here causes concurrent writes
    // to the model file, corrupting it.

    final meshInsightService = MeshInsightServiceImpl(meshService, aiService, isar);
    final resourceBroker = ResourceBrokerService(meshService, aiService, isar, securityService);
    final intelligenceService = IntelligenceServiceImpl(meshService, gatewayMonitor, aiService, securityService);
    
    // Start background background services
    meshInsightService.start();
    resourceBroker.start();
    intelligenceService.start();
    
    developer.log('[SYSTEM] UI Ready', name: 'System');
    runApp(NullSignalApp(
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
    
  } catch (e, stack) {
    developer.log('[SYSTEM] CRITICAL BOOT FAILURE: $e', name: 'System', error: e, stackTrace: stack);
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('SYSTEM FAILURE: $e', style: const TextStyle(color: Colors.red, fontFamily: 'monospace'))),
      ),
    ));
  }
}

class NullSignalApp extends StatelessWidget {
  final MeshService meshService;
  final AIService aiService;
  final MeshInsightService meshInsightService;
  final SatelliteGatewayService satelliteService;
  final ResourceBrokerService resourceBroker;
  final IntelligenceService intelligenceService;
  final SecurityService securityService;
  final SafetyMonitor safetyMonitor;
  final Isar isar;

  const NullSignalApp({
    super.key, 
    required this.meshService,
    required this.aiService,
    required this.meshInsightService,
    required this.satelliteService,
    required this.resourceBroker,
    required this.intelligenceService,
    required this.securityService,
    required this.safetyMonitor,
    required this.isar,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MeshService>.value(value: meshService),
        RepositoryProvider<AIService>.value(value: aiService),
        RepositoryProvider<MeshInsightService>.value(value: meshInsightService),
        RepositoryProvider<SatelliteGatewayService>.value(value: satelliteService),
        RepositoryProvider<ResourceBrokerService>.value(value: resourceBroker),
        RepositoryProvider<IntelligenceService>.value(value: intelligenceService),
        RepositoryProvider<SecurityService>.value(value: securityService),
        RepositoryProvider<SafetyMonitor>.value(value: safetyMonitor),
        RepositoryProvider<Isar>.value(value: isar),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<MeshCubit>(
            lazy: false,
            create: (context) => MeshCubit(meshService, securityService, meshService.deviceId)..startScanning(),
          ),
          BlocProvider<AiCubit>(
            lazy: false,
            create: (context) => AiCubit(aiService, meshInsightService, isar)..initialize(),
          ),
          BlocProvider<SosCubit>(
            create: (context) => SosCubit(meshService, securityService, meshService.deviceId),
          ),
          BlocProvider<IntelligenceCubit>(
            create: (context) => IntelligenceCubit(intelligenceService)..initialize(),
          ),
        ],
        child: MaterialApp(
          title: 'NullSignal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.normalTheme,
          darkTheme: AppTheme.normalTheme, 
          themeMode: ThemeMode.light,
          home: const PanicNavigationWrapper(),
        ),
      ),
    );
  }
}
