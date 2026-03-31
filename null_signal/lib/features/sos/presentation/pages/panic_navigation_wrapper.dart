import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/feedback_service.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/features/ai/presentation/pages/panic_ai_help_screen.dart';
import 'package:null_signal/features/dashboard/presentation/pages/normal_dashboard_screen.dart';
import 'package:null_signal/features/mesh/presentation/pages/panic_nearby_screen.dart';
import 'package:null_signal/features/sos/presentation/pages/sos_broadcast_screen.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';

class PanicNavigationWrapper extends StatefulWidget {
  const PanicNavigationWrapper({super.key});

  @override
  State<PanicNavigationWrapper> createState() => _PanicNavigationWrapperState();
}

class _PanicNavigationWrapperState extends State<PanicNavigationWrapper> {
  int _currentIndex = 1; // Default to Emergency (SOS) Screen
  late PageController _pageController;
  StreamSubscription<MeshPacket>? _incomingPacketSubscription;
  StreamSubscription<bool>? _checkInSubscription;
  StreamSubscription<void>? _autoSosSubscription;

  final List<Widget> _screens = [
    const NormalDashboardScreen(),
    const SOSBroadcastScreen(),
    const PanicNearbyScreen(),
    const PanicAIHelpScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("SAFETY CHECK-IN"),
        content: const Text("Are you safe? NullSignal detected prolonged inactivity."),
        actions: [
          ElevatedButton(
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
    FeedbackService.triggerSosHaptics();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.red[900],
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red[900]),
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
    _pageController.dispose();
    _incomingPacketSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.surfaceContainerHighest, width: 1)),
          boxShadow: [
            BoxShadow(
              color: colors.onSurface.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.monitor_heart_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.monitor_heart, size: 24),
              ),
              label: 'STATUS',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.emergency_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.emergency, size: 24),
              ),
              label: 'SOS',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.hub_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.hub, size: 24),
              ),
              label: 'MESH',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.psychology_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.psychology, size: 24),
              ),
              label: 'AI HELP',
            ),
          ],
        ),
      ),
    );
  }
}
