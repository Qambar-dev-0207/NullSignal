import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/feedback_service.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/presentation/pages/panic_ai_help_screen.dart';
import 'package:null_signal/features/dashboard/presentation/pages/normal_dashboard_screen.dart';
import 'package:null_signal/features/mesh/presentation/pages/panic_nearby_screen.dart';
import 'package:null_signal/features/sos/presentation/pages/sos_broadcast_screen.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';
import 'package:null_signal/features/sos/presentation/pages/tactical_ai_provisioning_screen.dart';
import 'package:null_signal/features/ai/data/repositories/gemini_ai_service.dart';

class PanicNavigationWrapper extends StatefulWidget {
  const PanicNavigationWrapper({super.key});

  @override
  State<PanicNavigationWrapper> createState() => _PanicNavigationWrapperState();
}

class _PanicNavigationWrapperState extends State<PanicNavigationWrapper> {
  int _currentIndex = 1; // Default to Emergency (SOS) Screen
  bool _isProvisioned = false;
  StreamSubscription<MeshPacket>? _incomingPacketSubscription;
  StreamSubscription<bool>? _checkInSubscription;
  StreamSubscription<void>? _autoSosSubscription;

  // Screens built on demand — only one in the widget tree at a time.
  Widget _buildScreen(int index) {
    switch (index) {
      case 0: return const NormalDashboardScreen();
      case 2: return const PanicNearbyScreen();
      case 3: return const PanicAIHelpScreen();
      default: return const SOSBroadcastScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Check if AI is already provisioned (native is ready)
    final aiService = context.read<AIService>();
    if (aiService is GeminiAIService) {
      _isProvisioned = aiService.isProvisioned;
    } else {
      _isProvisioned = true;
    }
    
    // Listen for incoming mesh packets
    final meshService = context.read<MeshService>();
    _incomingPacketSubscription = meshService.incomingPackets.listen((packet) {
      if (!mounted) return;
      
      final colors = Theme.of(context).extension<NullSignalColors>()!;
      
      if (packet.priority == PacketPriority.critical) {
        _showReceivedSos(context, packet);
      } else if (packet.receiverId == meshService.deviceId || packet.receiverId == null) {
        // Show regular messages intended for us or broadcast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('MSG FROM ${packet.senderId.substring(0, 6)}: ${packet.payload}'),
            backgroundColor: colors.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    final safetyMonitor = context.read<SafetyMonitor>();
    _checkInSubscription = safetyMonitor.onCheckInRequired.listen((required) {
      if (required && mounted) {
        _showSafetyCheckInDialog(context);
      }
    });

    _autoSosSubscription = safetyMonitor.onAutoSosTriggered.listen((_) {
      if (mounted) {
        context.read<SosCubit>().broadcastSos(
          lat: 0.0, // Placeholder
          lon: 0.0, // Placeholder
        );
      }
    });
  }

  void _showSafetyCheckInDialog(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
        ),
        title: Text("SAFETY CHECK-IN", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
        content: Text("Are you safe? NullSignal detected prolonged inactivity.", style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7))),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<SafetyMonitor>().userConfirmedSafe();
              Navigator.pop(dialogContext);
            },
            child: const Text("I AM SAFE"),
          ),
        ],
      ),
    );
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
          side: const BorderSide(color: Colors.white, width: 2)
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
            const Text('A nearby user requires immediate assistance!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Sender ID: ${packet.senderId}', style: const TextStyle(color: Colors.white70)),
            Text('Location: ${packet.latitude.toStringAsFixed(4)}, ${packet.longitude.toStringAsFixed(4)}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Text('Message: ${packet.payload}', style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('DISMISS', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: colors.primary),
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
  void dispose() {
    _incomingPacketSubscription?.cancel();
    _checkInSubscription?.cancel();
    _autoSosSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    FeedbackService.triggerSosHaptics();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isProvisioned) {
      return TacticalAiProvisioningScreen(
        onComplete: () => setState(() => _isProvisioned = true),
      );
    }

    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOutQuart,
        switchOutCurve: Curves.easeInQuart,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _buildScreen(_currentIndex),
        ),
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: colors.background.withValues(alpha: 0.9),
          border: Border(top: BorderSide(color: colors.surfaceContainerHighest.withValues(alpha: 0.3), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.monitor_heart, 'STATUS', colors),
            _buildNavItem(1, Icons.emergency, 'SOS', colors),
            _buildNavItem(2, Icons.hub, 'MESH', colors),
            _buildNavItem(3, Icons.psychology, 'AI HELP', colors),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, NullSignalColors colors) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? Border.all(color: colors.primaryContainer.withValues(alpha: 0.2)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colors.primaryContainer : colors.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: isSelected ? colors.primaryContainer : colors.onSurface.withValues(alpha: 0.3),
                letterSpacing: 1.5,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.rectangle),
              ),
          ],
        ),
      ),
    );
  }
}
