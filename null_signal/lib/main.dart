import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/ai/data/repositories/gemini_ai_service.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/presentation/bloc/ai_cubit.dart';
import 'package:null_signal/features/mesh/data/repositories/nearby_mesh_service_impl.dart';
import 'package:null_signal/features/mesh/data/repositories/simulated_mesh_service.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';
import 'package:null_signal/features/sos/presentation/pages/panic_navigation_wrapper.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [MeshPacketSchema, ChatMessageSchema],
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
  } catch (e) {
    isPhysicalDevice = false;
  }

  final gatewayMonitor = GatewayMonitor();
  final securityService = SecurityService();
  final safetyMonitor = SafetyMonitor()..start();

  // Use NearbyMeshServiceImpl for real devices, Simulated for emulators
  final MeshService meshService = isPhysicalDevice 
      ? NearbyMeshServiceImpl(gatewayMonitor, securityService) 
      : SimulatedMeshService(gatewayMonitor, securityService);
      
  // Initialize AI Service with a placeholder or environment variable API key
  // Replace 'YOUR_GEMINI_API_KEY' with a real key if needed.
  final aiService = GeminiAIService(apiKey: 'YOUR_GEMINI_API_KEY');
  
  runApp(NullSignalApp(
    meshService: meshService, 
    aiService: aiService,
    securityService: securityService,
    safetyMonitor: safetyMonitor,
    isar: isar,
  ));
}

class NullSignalApp extends StatelessWidget {
  final MeshService meshService;
  final AIService aiService;
  final SecurityService securityService;
  final SafetyMonitor safetyMonitor;
  final Isar isar;

  const NullSignalApp({
    super.key, 
    required this.meshService,
    required this.aiService,
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
        RepositoryProvider<SecurityService>.value(value: securityService),
        RepositoryProvider<SafetyMonitor>.value(value: safetyMonitor),
        RepositoryProvider<Isar>.value(value: isar),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<MeshCubit>(
            create: (context) => MeshCubit(meshService, securityService, meshService.deviceId)..startScanning(),
          ),
          BlocProvider<AiCubit>(
            create: (context) => AiCubit(aiService, isar)..initialize(),
          ),
          BlocProvider<SosCubit>(
            create: (context) => SosCubit(meshService, securityService, meshService.deviceId),
          ),
        ],
        child: MaterialApp(
          title: 'NullSignal',
          debugShowCheckedModeBanner: false,
          
          // Applying the high-precision "NullSignal Core" design system
          theme: AppTheme.normalTheme,
          darkTheme: AppTheme.normalTheme, // Default to Dark
          themeMode: ThemeMode.dark,

          // Starting with the Panic Mode orchestration wrapper
          home: const PanicNavigationWrapper(),
        ),
      ),
    );
  }
}
