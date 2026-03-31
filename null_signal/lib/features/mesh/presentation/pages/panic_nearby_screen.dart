import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';

class PanicNearbyScreen extends StatefulWidget {
  const PanicNearbyScreen({super.key});

  @override
  State<PanicNearbyScreen> createState() => _PanicNearbyScreenState();
}

class _PanicNearbyScreenState extends State<PanicNearbyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return NullSignalScaffold(
      title: 'NullSignal',
      actions: [
        Text(
          'MESH ACTIVE',
          style: textTheme.labelSmall?.copyWith(
            color: colors.primaryContainer,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.battery_charging_full, size: 20, color: colors.primary),
        const SizedBox(width: 24),
      ],
      body: BlocBuilder<MeshCubit, MeshState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3D MESH VISUALIZATION HERO
                _animateIn(
                  delay: 0,
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.voidBlack.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.outlineVariant.withOpacity(0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: Mesh3DPainter(
                                  colors: colors,
                                  connectedCount: state.connectedNodeCount,
                                  scannedCount: state.scannedDevices.length,
                                  rotation: _rotationController.value * 2 * math.pi,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOPOGRAPHY', style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withOpacity(0.4))),
                              Text('LIVE MESH CLOUD', style: textTheme.labelSmall?.copyWith(fontSize: 14, fontStyle: FontStyle.italic, color: colors.primaryContainer)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // PEERS SECTION
                _animateIn(
                  delay: 1,
                  child: Text(
                    'ACTIVE PEERS (${state.connectedDevices.length})',
                    style: textTheme.labelSmall?.copyWith(color: colors.onSurface.withOpacity(0.4)),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(state.connectedDevices.length, (index) {
                  return _animateIn(
                    delay: 2 + index,
                    child: _buildDeviceCard(state.connectedDevices[index], colors, textTheme, isConnected: true),
                  );
                }),
                
                const SizedBox(height: 32),

                // SCANNED DEVICES SECTION
                _animateIn(
                  delay: 3 + state.connectedDevices.length,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SCANNED VOID (${state.scannedDevices.length})',
                        style: textTheme.labelSmall?.copyWith(color: colors.onSurface.withOpacity(0.4)),
                      ),
                      if (state.isScanning)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.grey)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (state.scannedDevices.isEmpty)
                  _animateIn(
                    delay: 4 + state.connectedDevices.length,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('NO UNVERIFIED NODES FOUND', style: textTheme.labelSmall?.copyWith(fontSize: 9, color: colors.onSurface.withOpacity(0.2))),
                      ),
                    ),
                  )
                else
                  ...List.generate(state.scannedDevices.length, (index) {
                    return _animateIn(
                      delay: 4 + state.connectedDevices.length + index,
                      child: _buildDeviceCard(state.scannedDevices[index], colors, textTheme, isConnected: false),
                    );
                  }),

                const SizedBox(height: 32),
                
                // THROUGHPUT BENTO (Minimal Refined)
                _animateIn(
                  delay: 5 + state.connectedDevices.length + state.scannedDevices.length,
                  child: _buildTechnicalSummary(colors, textTheme),
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
      duration: Duration(milliseconds: 600 + (delay * 50)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildDeviceCard(MeshDevice device, NullSignalColors colors, TextTheme textTheme, {required bool isConnected}) {
    final int signalPercent = device.rssi != null ? ((device.rssi! + 100) * 1.4).clamp(0, 100).toInt() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? colors.surfaceContainerLowest : colors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: !isConnected ? Border.all(color: colors.outlineVariant.withOpacity(0.1)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isConnected ? colors.primaryContainer.withOpacity(0.1) : colors.onSurface.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConnected ? Icons.hub : Icons.sensors,
              size: 16,
              color: isConnected ? colors.primaryContainer : colors.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.deviceId, style: textTheme.labelSmall?.copyWith(fontSize: 12, color: colors.onSurface)),
                Text(
                  isConnected ? 'CONNECTED / SECURE' : 'UNVERIFIED NODE',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 8, 
                    color: isConnected ? colors.primaryContainer : colors.onSurface.withOpacity(0.4)
                  ),
                ),
                if (device.isGateway) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: colors.primaryContainer.withOpacity(0.3)),
                    ),
                    child: Text(
                      'GATEWAY NODE',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        color: colors.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isConnected) ...[
            _buildMetricMini('SIG', '$signalPercent%', colors),
            const SizedBox(width: 16),
            _buildMetricMini('LAT', '0.4ms', colors),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.send, size: 16, color: colors.primaryContainer),
              onPressed: () => _showSendMessageDialog(context, device),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ] else
            TextButton(
              onPressed: () {
                context.read<MeshCubit>().connectToDevice(device);
              },
              style: TextButton.styleFrom(
                backgroundColor: colors.primaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('CONNECT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricMini(String label, String value, NullSignalColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 7, color: colors.onSurface.withOpacity(0.4), fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 10, color: colors.primaryContainer, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildTechnicalSummary(NullSignalColors colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('UPTIME', '99.8%', colors),
          _buildSummaryItem('PROTOCOL', 'P2P v2.1', colors),
          _buildSummaryItem('THROUGHPUT', '12.4 Mbps', colors),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, NullSignalColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: colors.onSurface.withOpacity(0.4), letterSpacing: 1.0)),
        Text(value, style: TextStyle(fontSize: 11, color: colors.onSurface, fontWeight: FontWeight.w900)),
      ],
    );
  }

  void _showSendMessageDialog(BuildContext context, MeshDevice device) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('MESSAGE TO ${device.deviceId}', style: const TextStyle(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter secure message...',
            hintStyle: TextStyle(color: Colors.white30),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MeshCubit>().sendDirectMessage(device, controller.text);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message sent to mesh tunnel')),
              );
            },
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }
}

class Node3D {
  final double x, y, z;
  final bool isConnected;

  Node3D(this.x, this.y, this.z, this.isConnected);
}

class Mesh3DPainter extends CustomPainter {
  final NullSignalColors colors;
  final int connectedCount;
  final int scannedCount;
  final double rotation;

  Mesh3DPainter({
    required this.colors,
    required this.connectedCount,
    required this.scannedCount,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.5);
    final radius = size.width * 0.35;
    
    final nodes = <Node3D>[];

    // Generate Nodes in a 3D sphere volume
    for (int i = 0; i < (connectedCount + scannedCount); i++) {
      double phi = math.acos(-1 + (2 * i) / (connectedCount + scannedCount));
      double theta = math.sqrt((connectedCount + scannedCount) * math.pi) * phi;
      
      nodes.add(Node3D(
        math.cos(theta) * math.sin(phi),
        math.sin(theta) * math.sin(phi),
        math.cos(phi),
        i < connectedCount,
      ));
    }

    // Apply rotation and project to 2D
    final projectedPoints = <Offset>[];
    final depths = <double>[];
    
    for (var node in nodes) {
      // Rotation around Y axis
      double x = node.x * math.cos(rotation) - node.z * math.sin(rotation);
      double z = node.x * math.sin(rotation) + node.z * math.cos(rotation);
      double y = node.y;

      // Simple perspective projection
      double perspective = 1.5 / (2.0 + z);
      projectedPoints.add(Offset(
        center.dx + x * radius * perspective,
        center.dy + y * radius * perspective,
      ));
      depths.add(z);
    }

    // Draw connection lines first (only between "nearby" projected points or all for mesh look)
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < projectedPoints.length; i++) {
      for (int j = i + 1; j < projectedPoints.length; j++) {
        double dist = (nodes[i].x - nodes[j].x).abs() + (nodes[i].y - nodes[j].y).abs() + (nodes[i].z - nodes[j].z).abs();
        if (dist < 1.2) {
          double avgDepth = (depths[i] + depths[j]) / 2;
          linePaint.color = colors.primaryContainer.withOpacity((0.1 * (1.0 - avgDepth)).clamp(0.0, 0.2));
          canvas.drawLine(projectedPoints[i], projectedPoints[j], linePaint);
        }
      }
    }

    // Draw Nodes
    final nodePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < projectedPoints.length; i++) {
      double z = depths[i];
      double opacity = (0.8 * (1.0 - z)).clamp(0.1, 1.0);
      double sizeMult = (1.0 - z).clamp(0.5, 2.0);
      
      nodePaint.color = (nodes[i].isConnected ? colors.primaryContainer : colors.onSurface.withOpacity(0.3)).withOpacity(opacity);
      canvas.drawCircle(projectedPoints[i], 3.0 * sizeMult, nodePaint);
      
      if (nodes[i].isConnected) {
        canvas.drawCircle(
          projectedPoints[i], 
          6.0 * sizeMult, 
          Paint()..color = colors.primaryContainer.withOpacity(opacity * 0.2)
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
