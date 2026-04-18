import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/core/utils/animations.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';
import 'package:null_signal/features/sos/presentation/widgets/biological_pulse_trigger.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SosCubit, SosState>(
      listener: (context, state) {
        if (state is SosBroadcastSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('EMERGENCY BROADCAST ACTIVE'),
              backgroundColor: colors.primaryContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else if (state is SosError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('BROADCAST FAILED: ${state.message}'),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: NullSignalScaffold(
        title: 'Emergency',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  'PRIORITY 1',
                  style: textTheme.labelSmall?.copyWith(color: colors.error, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 600;
            
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 20 : 40),
                    
                    // Main Instruction
                    FadeInAnimation(
                      child: Column(
                        children: [
                          Text(
                            'Request Immediate Assistance',
                            style: textTheme.headlineLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your precise location and distress signal will be broadcast to all nearby nodes in the mesh network.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 40 : 60),

                    // Trigger Button
                    FadeInAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: BlocBuilder<SosCubit, SosState>(
                        builder: (context, state) {
                          final isLoading = state is SosBroadcasting;
                          return BiologicalPulseTrigger(
                            isLoading: isLoading,
                            label: isLoading ? 'BROADCASTING...' : 'HOLD TO TRIGGER\nSOS SIGNAL',
                            onTrigger: () {
                              context.read<SosCubit>().broadcastSos(isDms: false);
                            },
                          );
                        },
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 40 : 60),

                    // Status Cards
                    FadeInAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: _buildInfoGrid(colors, textTheme, isSmallScreen),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoGrid(NullSignalColors colors, TextTheme textTheme, bool isSmall) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'MESH STATUS',
                'ACTIVE',
                Icons.radar,
                colors.primary,
                colors,
                textTheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatusCard(
                'ENCRYPTION',
                'AES-256',
                Icons.lock_outline,
                colors.primary,
                colors,
                textTheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatusCard(
          'PROTOCOL',
          'NULLSIGNAL-P2P v4.0 (SECURE)',
          Icons.security,
          colors.primary,
          colors,
          textTheme,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String label, 
    String value, 
    IconData icon, 
    Color iconColor,
    NullSignalColors colors, 
    TextTheme textTheme,
    {bool isWide = false}
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor.withValues(alpha: 0.7)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: colors.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
