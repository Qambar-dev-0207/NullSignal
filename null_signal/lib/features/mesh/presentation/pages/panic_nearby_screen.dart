import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/core/utils/animations.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';

class PanicNearbyScreen extends StatelessWidget {
  const PanicNearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return NullSignalScaffold(
      title: 'Nearby Mesh',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: () => context.read<MeshCubit>().startScanning(),
          color: colors.primary,
        ),
        const SizedBox(width: 8),
      ],
      body: BlocBuilder<MeshCubit, MeshState>(
        builder: (context, state) {
          final allDevices = [...state.connectedDevices, ...state.scannedDevices];
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildMeshRadar(state, colors, textTheme),
              const SizedBox(height: 40),
              Text(
                'DISCOVERED NODES (${allDevices.length})',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.4),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: allDevices.isEmpty
                    ? _buildEmptyState(colors, textTheme)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: allDevices.length,
                        itemBuilder: (context, index) {
                          final device = allDevices[index];
                          return FadeInAnimation(
                            delay: Duration(milliseconds: index * 50),
                            child: _buildDeviceCard(context, device, colors, textTheme),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMeshRadar(MeshState state, NullSignalColors colors, TextTheme textTheme) {
    final allDevices = [...state.connectedDevices, ...state.scannedDevices];
    
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.05),
            blurRadius: 30,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Mesh3DVisualizer(
              devices: allDevices,
              primaryColor: colors.primary,
              isScanning: state.isScanning,
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.isScanning)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, 
                              valueColor: AlwaysStoppedAnimation(Color(0xFFB71C1C)),
                            ),
                          ),
                        ),
                      Text(
                        state.isScanning ? 'MAPPING_MESH_TOPOLOGY...' : 'MESH_STABLE',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, MeshDevice device, NullSignalColors colors, TextTheme textTheme) {
    final isConnected = device.status == MeshDeviceStatus.connected;
    final isConnecting = device.status == MeshDeviceStatus.connecting;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isConnected ? colors.primary.withValues(alpha: 0.03) : colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? colors.primary.withValues(alpha: 0.3) : colors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isConnected ? colors.primary : Colors.transparent,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: isConnected ? colors.primary : colors.onSurface.withValues(alpha: 0.1)),
                      ),
                      child: Icon(
                        device.isGateway ? Icons.settings_input_antenna : Icons.memory,
                        color: isConnected ? colors.primary : colors.onSurface.withValues(alpha: 0.3),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                device.deviceName.toUpperCase(),
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isConnected ? colors.primary : colors.onSurface,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              if (device.isGateway) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.bolt, size: 12, color: colors.primary),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NODE_ID: ${device.deviceId.length > 12 ? device.deviceId.substring(0, 12).toUpperCase() : device.deviceId.toUpperCase()}',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 7, 
                              color: colors.onSurface.withValues(alpha: 0.4),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isConnected) ...[
                      IconButton(
                        icon: Icon(Icons.chat_bubble_outline, color: colors.primary, size: 18),
                        onPressed: () => _showMessagingDialog(context, device),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(border: Border.all(color: colors.primary)),
                        child: Text('LIVE', style: textTheme.labelSmall?.copyWith(fontSize: 7, fontWeight: FontWeight.bold)),
                      ),
                    ] else if (isConnecting)
                      const BaryonLoader(size: 16)
                    else
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => context.read<MeshCubit>().connectToDevice(device),
                        child: Text('CONNECT', style: textTheme.labelSmall?.copyWith(fontSize: 8)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessagingDialog(BuildContext context, MeshDevice device) {
    final controller = TextEditingController();
    final colors = Theme.of(context).extension<NullSignalColors>()!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(side: BorderSide(color: colors.primary.withValues(alpha: 0.2))),
        title: Text('MESSAGE: ${device.deviceName.toUpperCase()}', style: TextStyle(color: colors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colors.onSurface, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Enter encrypted packet data...',
            hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.3)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.1))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5), fontSize: 12)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<MeshCubit>().sendDirectMessage(device, controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PACKET TRANSMITTED')),
                );
              }
            },
            child: const Text('TRANSMIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(NullSignalColors colors, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hub_outlined, size: 48, color: colors.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'NO NODES DETECTED',
            style: textTheme.labelSmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.2), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ensure Bluetooth and Location are active.',
            style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.15), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class Mesh3DVisualizer extends StatefulWidget {
  final List<MeshDevice> devices;
  final Color primaryColor;
  final bool isScanning;

  const Mesh3DVisualizer({
    super.key,
    required this.devices,
    required this.primaryColor,
    required this.isScanning,
  });

  @override
  State<Mesh3DVisualizer> createState() => _Mesh3DVisualizerState();
}

class _Mesh3DVisualizerState extends State<Mesh3DVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Node3D> _nodes = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    
    _generateInitialNodes();
  }

  void _generateInitialNodes() {
    _nodes.clear();
    // Add "Self" node at origin
    _nodes.add(_Node3D(
      x: 0, y: 0, z: 0,
      radius: 8,
      color: widget.primaryColor,
      isSelf: true,
    ));

    for (var device in widget.devices) {
      _nodes.add(_createNodeForDevice(device));
    }
  }

  _Node3D _createNodeForDevice(MeshDevice device) {
    final dist = 80.0 + _random.nextDouble() * 120.0;
    final angle = _random.nextDouble() * 2 * math.pi;
    final elevation = (_random.nextDouble() - 0.5) * math.pi;

    return _Node3D(
      x: dist * math.cos(angle) * math.cos(elevation),
      y: dist * math.sin(elevation),
      z: dist * math.sin(angle) * math.cos(elevation),
      radius: device.status == MeshDeviceStatus.connected ? 6 : 4,
      color: device.status == MeshDeviceStatus.connected ? widget.primaryColor : widget.primaryColor.withValues(alpha: 0.4),
      device: device,
    );
  }

  @override
  void didUpdateWidget(Mesh3DVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.devices.length != oldWidget.devices.length) {
      _syncNodes();
    }
  }

  void _syncNodes() {
    final existingDeviceIds = _nodes.where((n) => n.device != null).map((n) => n.device!.deviceId).toSet();
    
    for (var device in widget.devices) {
      if (!existingDeviceIds.contains(device.deviceId)) {
        _nodes.add(_createNodeForDevice(device));
      }
    }
    
    // Update colors/status
    for (var node in _nodes) {
      if (node.device != null) {
        final d = widget.devices.firstWhere((dev) => dev.deviceId == node.device!.deviceId, orElse: () => node.device!);
        node.color = d.status == MeshDeviceStatus.connected ? widget.primaryColor : widget.primaryColor.withValues(alpha: 0.4);
        node.radius = d.status == MeshDeviceStatus.connected ? 6 : 4;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _Mesh3DPainter(
            nodes: _nodes,
            rotation: _controller.value * 2 * math.pi,
            primaryColor: widget.primaryColor,
          ),
        );
      },
    );
  }
}

class _Node3D {
  double x, y, z;
  double radius;
  Color color;
  final MeshDevice? device;
  final bool isSelf;

  _Node3D({
    required this.x,
    required this.y,
    required this.z,
    required this.radius,
    required this.color,
    this.device,
    this.isSelf = false,
  });
}

class _Mesh3DPainter extends CustomPainter {
  final List<_Node3D> nodes;
  final double rotation;
  final Color primaryColor;

  _Mesh3DPainter({
    required this.nodes,
    required this.rotation,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Projection constants
    const focalLength = 350.0;

    // Transform and project nodes
    final projectedNodes = nodes.map((node) {
      // Rotate around Y axis
      final cosR = math.cos(rotation);
      final sinR = math.sin(rotation);
      
      final rx = node.x * cosR - node.z * sinR;
      final rz = node.x * sinR + node.z * cosR + 400; // Move back into scene
      final ry = node.y;

      // Project
      final scale = focalLength / rz;
      final px = rx * scale + center.dx;
      final py = ry * scale + center.dy;
      
      return (px: px, py: py, rz: rz, scale: scale, node: node);
    }).toList();

    // Sort by depth (Z-buffer)
    projectedNodes.sort((a, b) => b.rz.compareTo(a.rz));

    // Draw lines first (background)
    for (var pNode in projectedNodes) {
      if (pNode.node.isSelf) continue;
      
      final isConnected = pNode.node.device?.status == MeshDeviceStatus.connected;
      if (isConnected) {
        linePaint.color = primaryColor.withValues(alpha: 0.5 * pNode.scale);
        linePaint.strokeWidth = 2.0 * pNode.scale;
        
        // Find self projected position
        final self = projectedNodes.firstWhere((n) => n.node.isSelf);
        canvas.drawLine(Offset(self.px, self.py), Offset(pNode.px, pNode.py), linePaint);
      } else {
        // Subtle grid/network lines to center
        linePaint.color = primaryColor.withValues(alpha: 0.1 * pNode.scale);
        linePaint.strokeWidth = 0.5 * pNode.scale;
        final self = projectedNodes.firstWhere((n) => n.node.isSelf);
        canvas.drawLine(Offset(self.px, self.py), Offset(pNode.px, pNode.py), linePaint);
      }
    }

    // Draw nodes
    for (var pNode in projectedNodes) {
      paint.color = pNode.node.color.withValues(alpha: 0.8 * pNode.scale + 0.2);
      
      // Node glow
      final glowPaint = Paint()
        ..color = pNode.node.color.withValues(alpha: 0.2 * pNode.scale)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(Offset(pNode.px, pNode.py), pNode.node.radius * pNode.scale * 2.5, glowPaint);
      canvas.drawCircle(Offset(pNode.px, pNode.py), pNode.node.radius * pNode.scale, paint);

      if (pNode.node.isSelf) {
         paint.style = PaintingStyle.stroke;
         paint.strokeWidth = 1.0;
         paint.color = primaryColor.withValues(alpha: 0.6);
         canvas.drawCircle(Offset(pNode.px, pNode.py), pNode.node.radius * pNode.scale * 1.8, paint);
         paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Mesh3DPainter oldDelegate) => true;
}

