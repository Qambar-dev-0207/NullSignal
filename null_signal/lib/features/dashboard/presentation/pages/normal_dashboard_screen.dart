import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/core/utils/animations.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';
import 'package:null_signal/features/ai/presentation/pages/panic_ai_help_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';
import 'package:null_signal/features/intelligence/presentation/bloc/intelligence_cubit.dart';

class NormalDashboardScreen extends StatelessWidget {
  const NormalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return NullSignalScaffold(
      title: 'NullSignal',
      actions: [
        Icon(Icons.signal_cellular_alt, size: 20, color: colors.primary),
        const SizedBox(width: 16),
        Icon(Icons.battery_charging_full, size: 20, color: colors.primary),
        const SizedBox(width: 24),
      ],
      body: MultiBlocListener(
        listeners: [
          BlocListener<IntelligenceCubit, IntelligenceState>(
            listener: (context, state) {
              if (state.hazardPolygons.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('NEW HAZARD OVERLAY DETECTED'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
              if (state.latestCrowdAlert != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('CROWD ALERT: ${state.latestCrowdAlert}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<MeshCubit, MeshState>(
          builder: (context, meshState) {
            return ListView(
              padding: const EdgeInsets.only(top: 24, bottom: 48),
              children: [
                FadeInAnimation(
                  child: _buildHeroHeader(colors, textTheme),
                ),
                const SizedBox(height: 40),
                _buildBentoGrid(context, meshState, colors, textTheme),
                const SizedBox(height: 32),
                FadeInAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUICK ACTIONS',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(colors, textTheme),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroHeader(NullSignalColors colors, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PulseContainer(
              color: colors.primary,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'LOCAL NODE STATUS',
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlitchText(
          'SYSTEM STATUS',
          style: textTheme.displayLarge?.copyWith(
            fontSize: 42,
            color: colors.onSurface,
          ),
        ),
        Text(
          'FULLY OPERATIONAL',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 18,
            color: colors.primary.withValues(alpha: 0.8),
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(
    BuildContext context, 
    MeshState state, 
    NullSignalColors colors, 
    TextTheme textTheme
  ) {
    return BlocBuilder<IntelligenceCubit, IntelligenceState>(
      builder: (context, intelState) {
        return Column(
          children: [
            FadeInAnimation(
              delay: const Duration(milliseconds: 200),
              child: _buildMeshHealthCard(state, colors, textTheme),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FadeInAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: _buildBentoSmallCard(
                      'CROWD DENSITY',
                      '${intelState.neighborCount} PEERS',
                      Icons.people_outline,
                      colors,
                      textTheme,
                      valueColor: intelState.neighborCount > 10 ? colors.error : colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FadeInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: _buildBentoSmallCard(
                      'SEISMIC LOAD',
                      '${intelState.localGForce.toStringAsFixed(2)}G',
                      Icons.vibration,
                      colors,
                      textTheme,
                      valueColor: intelState.localGForce > 10.0 ? colors.warning : colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: FadeInAnimation(
                    delay: const Duration(milliseconds: 500),
                    child: _buildTrafficStream(colors, textTheme),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FadeInAnimation(
                    delay: const Duration(milliseconds: 550),
                    child: _buildGeoAnchor(context, intelState, colors, textTheme),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMeshHealthCard(MeshState state, NullSignalColors colors, TextTheme textTheme) {
    return NullSignalCard(
      padding: const EdgeInsets.all(24),
      animate: false,
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
                      color: colors.onSurface.withValues(alpha: 0.5),
                      fontSize: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MESH HEALTH', 
                    style: textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              PulseContainer(
                color: colors.primary,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.hub, color: colors.primary, size: 24),
                ),
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
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.84,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.primaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STABILITY INDEX', style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withValues(alpha: 0.4))),
                  Text('84%', style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.primary, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoSmallCard(String label, String value, IconData icon, NullSignalColors colors, TextTheme textTheme, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(label, style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withValues(alpha: 0.4))),
          const SizedBox(height: 4),
          Text(value, style: textTheme.labelSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w900, color: valueColor ?? colors.onSurface)),
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
            color: colors.onSurface.withValues(alpha: 0.4),
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
        color: colors.surfaceHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TRAFFIC STREAM', style: textTheme.labelSmall?.copyWith(fontSize: 9, color: colors.onSurface.withValues(alpha: 0.6))),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLogLine('0x4F2...EE1', 'ROUTED', colors),
          _buildLogLine('0x8A1...BC4', 'SECURE', colors),
          _buildLogLine('0x2D9...FF0', 'VERIFIED', colors),
          _buildLogLine('0x9E3...A12', 'ROUTED', colors),
        ],
      ),
    );
  }

  Widget _buildLogLine(String id, String status, NullSignalColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(id, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: colors.onSurface.withValues(alpha: 0.5))),
          Text(status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: colors.primary, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildGeoAnchor(BuildContext context, IntelligenceState state, NullSignalColors colors, TextTheme textTheme) {
    final geoJsonParser = GeoJsonParser(
      polygonCreationCallback: (points, holes, properties) {
        return Polygon(
          points: points,
          holePointsList: holes ?? [],
          color: Colors.orange.withValues(alpha: 0.3),
          borderStrokeWidth: 2.0,
          borderColor: Colors.orange,
        );
      },
    );

    for (final geoJson in state.hazardPolygons) {
      if (geoJson.isNotEmpty) {
        try {
          geoJsonParser.parseGeoJsonAsString(geoJson);
        } catch (e) {
          debugPrint('Error parsing GeoJSON: $e');
        }
      }
    }

    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(34.0522, -118.2437),
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nullsignal.app',
                ),
                PolygonLayer(polygons: geoJsonParser.polygons),
              ],
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'HAZARD INTEL',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: 'mock_hazard',
                onPressed: () => context.read<IntelligenceCubit>().triggerMockHazard(),
                backgroundColor: colors.primary,
                child: const Icon(Icons.warning_amber, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(NullSignalColors colors, TextTheme textTheme) {
    return Row(
      children: [
        _buildActionIcon(Icons.search, colors),
        const SizedBox(width: 12),
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PanicAIHelpScreen()),
              );
            },
            child: _buildActionIcon(Icons.psychology, colors),
          ),
        ),
        const SizedBox(width: 12),
        _buildActionIcon(Icons.terminal, colors),
        const SizedBox(width: 12),
        _buildActionIcon(Icons.key, colors),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SYSTEM RE-SCAN',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, NullSignalColors colors) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, size: 20, color: colors.primary),
    );
  }
}
