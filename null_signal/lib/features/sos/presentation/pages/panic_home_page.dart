import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/feedback_service.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/domain/repositories/mesh_insight_service.dart';
import 'package:null_signal/features/ai/presentation/bloc/ai_cubit.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';
import 'package:null_signal/features/sos/presentation/bloc/ui_orchestrator_cubit.dart';
import 'package:null_signal/features/sos/presentation/pages/sos_screen.dart';
import 'package:null_signal/features/ai/presentation/pages/panic_ai_help_screen.dart';
import 'package:null_signal/features/mesh/presentation/pages/panic_nearby_screen.dart';

class PanicHomePage extends StatelessWidget {
  const PanicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final meshService = context.read<MeshService>();
            return MeshCubit(
              meshService,
              context.read<SecurityService>(),
              meshService.deviceId,
            )..startScanning();
          },
        ),
        BlocProvider(
          create: (context) {
            final meshService = context.read<MeshService>();
            return SosCubit(
              meshService,
              context.read<SecurityService>(),
              meshService.deviceId,
            );
          },
        ),
        BlocProvider(
          create: (context) => AiCubit(
            context.read<AIService>(),
            context.read<MeshInsightService>(),
            context.read<Isar>(),
          )..initialize(),
        ),
      ],
      child: const PanicHomeView(),
    );
  }
}

class PanicHomeView extends StatefulWidget {
  const PanicHomeView({super.key});

  @override
  State<PanicHomeView> createState() => _PanicHomeViewState();
}

class _PanicHomeViewState extends State<PanicHomeView> {
  int _currentIndex = 1; // Start on SOS screen
  StreamSubscription<MeshPacket>? _incomingPacketSubscription;

  final List<Widget> _screens = [
    const PanicAIHelpScreen(),
    const SosScreen(),
    const PanicNearbyScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final safetyMonitor = context.read<SafetyMonitor>();
    safetyMonitor.start();
    safetyMonitor.onCheckInRequired.listen((required) {
      if (required && mounted) {
        _showSafetyCheckIn(context);
      }
    });
    safetyMonitor.onAutoSosTriggered.listen((_) {
      if (mounted) {
        context.read<SosCubit>().broadcastSos(lat: 34.0522, lon: -118.2437);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AUTO-SOS TRIGGERED: USER INACTIVE'), backgroundColor: Colors.red),
        );
      }
    });

    // Listen for incoming SOS mesh packets
    final meshService = context.read<MeshService>();
    _incomingPacketSubscription = meshService.incomingPackets.listen((packet) {
      if (packet.priority == PacketPriority.critical && mounted) {
        _showReceivedSos(context, packet);
      }
    });
  }

  @override
  void dispose() {
    _incomingPacketSubscription?.cancel();
    super.dispose();
  }

  void _showReceivedSos(BuildContext context, MeshPacket packet) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    FeedbackService.triggerSosHaptics();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text('SOS RECEIVED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A nearby user requires immediate assistance!', 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Sender ID: ${packet.senderId}', style: const TextStyle(color: Colors.white70)),
            Text(
              'Location: ${packet.latitude.toStringAsFixed(4)}, ${packet.longitude.toStringAsFixed(4)}', 
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              'Message: ${packet.payload}', 
              style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('DISMISS', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, 
              foregroundColor: colors.primary,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navigating to ${packet.latitude.toStringAsFixed(4)}, ${packet.longitude.toStringAsFixed(4)}...')),
              );
            },
            child: const Text('NAVIGATE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: colors.surfaceContainerLowest,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurface.withValues(alpha: 0.3),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services, size: 28),
            label: 'AI HELP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos, size: 40),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub, size: 28),
            label: 'NEARBY',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<SafetyMonitor>().stop();
          context.read<UIOrchestratorCubit>().switchToNormal();
        },
        backgroundColor: colors.onSurface,
        child: Icon(Icons.exit_to_app, color: colors.background),
      ),
    );
  }

  void _showSafetyCheckIn(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.primary,
        title: const Text('SAFETY CHECK-IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you safe? NullSignal detected prolonged inactivity.', 
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, 
              foregroundColor: colors.primary,
            ),
            onPressed: () {
              context.read<SafetyMonitor>().userConfirmedSafe();
              Navigator.pop(dialogContext);
            },
            child: const Text('I AM SAFE', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
