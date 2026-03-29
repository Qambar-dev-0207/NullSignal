import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/features/ai/data/repositories/android_ai_service.dart';
import 'package:null_signal/features/ai/data/repositories/ios_ai_service.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/mesh/data/repositories/nearby_mesh_service_impl.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:null_signal/features/sos/presentation/bloc/ui_orchestrator_cubit.dart';
import 'package:null_signal/features/sos/presentation/pages/panic_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NullSignalApp());
}

class NullSignalApp extends StatelessWidget {
  const NullSignalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MeshService>(create: (_) => NearbyMeshServiceImpl()),
        RepositoryProvider<SecurityService>(create: (_) => SecurityService()),
        RepositoryProvider<AIService>(create: (_) {
          if (Platform.isAndroid) return AndroidAIService();
          return IosAIService();
        }),
        RepositoryProvider<SafetyMonitor>(create: (_) => SafetyMonitor()),
      ],
      child: BlocProvider(
        create: (_) => UIOrchestratorCubit(),
        child: BlocBuilder<UIOrchestratorCubit, AppUIState>(
          builder: (context, state) {
            final isPanic = state == AppUIState.panic;
            
            return MaterialApp(
              title: 'NullSignal',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.normalTheme,
              darkTheme: AppTheme.normalTheme,
              themeMode: isPanic ? ThemeMode.dark : ThemeMode.system,
              builder: (context, child) {
                return Theme(
                  data: isPanic ? AppTheme.panicTheme : AppTheme.normalTheme,
                  child: child!,
                );
              },
              home: isPanic ? const PanicHomePage() : const NormalHomePage(),
            );
          },
        ),
      ),
    );
  }
}

class NormalHomePage extends StatelessWidget {
  const NormalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NullSignal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.signal_cellular_off, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 24),
            const Text('System Status: Ready', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () => context.read<UIOrchestratorCubit>().switchToPanic(),
              child: const Text('ACTIVATE PANIC MODE', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
