import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';

class NormalDashboardScreen extends StatelessWidget {
  const NormalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return NullSignalScaffold(
      title: 'NullSignal',
      actions: [
        Icon(Icons.signal_cellular_alt, size: 20, color: colors.primaryBlue),
        const SizedBox(width: 16),
        Icon(Icons.battery_charging_full, size: 20, color: colors.primaryBlue),
        const SizedBox(width: 24),
      ],
      body: BlocBuilder<MeshCubit, MeshState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section: SYSTEM STATUS
                _animateIn(child: _buildHeroHeader(colors, textTheme), delay: 0),
                const SizedBox(height: 48),

                // Bento Grid - Primary Mesh Card
                _animateIn(child: _buildMeshHealthCard(context, state, colors, textTheme), delay: 1),
                const SizedBox(height: 24),

                // Side Tech Stack
                _animateIn(
                  delay: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTrafficStream(colors, textTheme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildGeoAnchor(colors, textTheme),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Quick Actions
                _animateIn(
                  delay: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUICK ACTIONS',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(colors, textTheme),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _animateIn({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (delay * 100)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHeroHeader(NullSignalColors colors, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'LOCAL NODE STATUS',
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'SYSTEM STATUS',
          style: textTheme.displayLarge?.copyWith(
            fontSize: 42,
            color: colors.onSurface,
          ),
        ),
        Text(
          'FULLY OPERATIONAL',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: colors.primary.withOpacity(0.8),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMeshHealthCard(
    BuildContext context, 
    MeshState state, 
    NullSignalColors colors, 
    TextTheme textTheme
  ) {
    return NullSignalCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NETWORK INTEGRITY',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.5),
                      fontSize: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MESH HEALTH', 
                    style: textTheme.headlineMedium?.copyWith(fontSize: 22),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.hub, color: colors.primary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('PEERS', '${state.connectedNodeCount}', colors, textTheme),
              _buildMetric('SIGNAL', '-67dBm', colors, textTheme),
              _buildMetric('UPLINK', 'ONLINE', colors, textTheme, valueColor: colors.primary),
            ],
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.84,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STABILITY INDEX', style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withOpacity(0.4))),
                  Text('84%', style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.primary, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, NullSignalColors colors, TextTheme textTheme, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 8,
            color: colors.onSurface.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: valueColor ?? colors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTrafficStream(NullSignalColors colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRAFFIC STREAM', style: textTheme.labelSmall?.copyWith(fontSize: 9, color: colors.onSurface.withOpacity(0.6))),
          const SizedBox(height: 16),
          _buildLogLine('0x4F2...EE1', 'ROUTED', colors),
          _buildLogLine('0x8A1...BC4', 'ENCRYPTED', colors),
          _buildLogLine('0x2D9...FF0', 'VERIFIED', colors),
        ],
      ),
    );
  }

  Widget _buildLogLine(String id, String status, NullSignalColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(id, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: colors.onSurface.withOpacity(0.5))),
          Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: colors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildGeoAnchor(NullSignalColors colors, TextTheme textTheme) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MESH GEO-ANCHOR', style: textTheme.labelSmall?.copyWith(fontSize: 8)),
            const Spacer(),
            Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: colors.crimsonCarrot, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('40.7128° N', style: textTheme.labelSmall?.copyWith(fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(NullSignalColors colors, TextTheme textTheme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton(Icons.search, 'Scanned Devices', colors, textTheme),
        _buildActionButton(Icons.terminal, 'System Logs', colors, textTheme),
        _buildActionButton(Icons.key, 'Encryption Keys', colors, textTheme),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, NullSignalColors colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colors.primaryBlue),
          const SizedBox(width: 12),
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(fontSize: 10, color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}
