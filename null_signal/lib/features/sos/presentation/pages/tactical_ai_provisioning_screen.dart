import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/utils/animations.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/data/repositories/gemini_ai_service.dart';
import 'package:null_signal/features/ai/presentation/bloc/ai_cubit.dart';

class TacticalAiProvisioningScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TacticalAiProvisioningScreen({super.key, required this.onComplete});

  @override
  State<TacticalAiProvisioningScreen> createState() => _TacticalAiProvisioningScreenState();
}

class _TacticalAiProvisioningScreenState extends State<TacticalAiProvisioningScreen> {
  bool _isStuck = false;
  Timer? _stuckTimer;

  @override
  void initState() {
    super.initState();
    // If progress doesn't move from 0 in 30 seconds, it's likely a hardware/AICore issue
    _stuckTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) setState(() => _isStuck = true);
    });
  }

  @override
  void dispose() {
    _stuckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiService = context.read<AIService>() as GeminiAIService;
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: StreamBuilder<int>(
        stream: aiService.downloadProgress,
        builder: (context, snapshot) {
          final progress = snapshot.data ?? 0;
          final isError = progress == -1;
          
          if (progress > 0 && !isError) {
            _stuckTimer?.cancel(); // It's moving!
          }

          if (progress >= 100) {
            Future.microtask(() => widget.onComplete());
          }

          final statusTitle = isError ? 'PROVISIONING_FAILED' : (_isStuck ? 'HARDWARE_RESTRICTION' : 'PROVISIONING_OFFLINE_AI');
          final statusColor = isError ? Colors.red : (_isStuck ? Colors.orange : colors.primary);
          final statusIcon = isError ? Icons.error_outline : (_isStuck ? Icons.warning_amber : Icons.memory);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                PulseContainer(
                  color: statusColor,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 2),
                    ),
                    child: Icon(
                      statusIcon, 
                      size: 64, 
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                GlitchText(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isError 
                    ? 'The system encountered an error while fetching the AICore. Ensure you have a stable Wi-Fi connection.'
                    : (_isStuck 
                        ? 'Your device hardware does not support the Gemini Nano system core. Switching to the lightweight Tactical Heuristic Engine.'
                        : 'Downloading Gemini Nano system core for zero-signal intelligence. This happens once.'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 64),
                
                if (!isError && !_isStuck) ...[
                  // Progress Bar
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (progress < 0 ? 0 : progress) / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(color: colors.primary.withValues(alpha: 0.5), blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STAGING_CORE...',
                        style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.primary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$progress%',
                        style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
                
                const Spacer(),
                Column(
                  children: [
                    if (_isStuck) ...[
                      Text(
                        'TIP: Try toggling Airplane Mode or ensure "On-device AI" is enabled in Developer Options.',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(fontSize: 9, color: Colors.orange.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isError || _isStuck) ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              side: BorderSide(color: isError ? Colors.red : Colors.orange),
                            ),
                            // Use AiCubit.initialize() so the cubit resets its subscription
                            // and properly transitions state when the retry succeeds.
                            onPressed: () {
                              setState(() => _isStuck = false);
                              _stuckTimer?.cancel();
                              _stuckTimer = Timer(const Duration(seconds: 30), () {
                                if (mounted) setState(() => _isStuck = true);
                              });
                              context.read<AiCubit>().initialize();
                            },
                            child: Text(isError ? 'RETRY' : 'RE-SYNC'),
                          ),
                          const SizedBox(width: 16),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          onPressed: widget.onComplete,
                          child: Text(
                            _isStuck || isError ? 'INITIALIZE TACTICAL CORE' : 'SKIP TO HEURISTIC MODE',
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
