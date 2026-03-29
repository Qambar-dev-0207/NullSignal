import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';

class PanicNearbyScreen extends StatelessWidget {
  const PanicNearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEARBY SIGNALS',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 32),
          BlocBuilder<MeshCubit, MeshState>(
            builder: (context, state) {
              final connectedCount = state.connectedNodeCount;
              final totalDiscovered = state.devices.length;
              final color = connectedCount > 0 ? const Color(0xFFFFEB3B) : Colors.red;

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.hub, size: 64, color: color),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$connectedCount ACTIVE NODES', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('$totalDiscovered DEVICES DETECTED', style: const TextStyle(fontSize: 18, color: Colors.white70)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('SIGNAL DISCOVERY LIST', style: TextStyle(color: Color(0xFFFFEB3B), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 16),
                  if (state.devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFFEB3B)),
                            SizedBox(height: 16),
                            Text('SCANNING FOR BT/WIFI SIGNALS...', style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.devices.length,
                        itemBuilder: (context, index) {
                          final device = state.devices[index];
                          final isConnected = device.isConnected;
                          
                          return Card(
                            color: Colors.white.withValues(alpha: 0.05),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isConnected ? const Color(0xFFFFEB3B) : Colors.white24,
                                width: isConnected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                                color: isConnected ? const Color(0xFFFFEB3B) : Colors.white54,
                              ),
                              title: Text(
                                device.deviceName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                isConnected ? 'CONNECTED TO MESH' : 'DISCOVERED SIGNAL (AUTO-CONNECTING)',
                                style: TextStyle(color: isConnected ? const Color(0xFFFFEB3B) : Colors.white54, fontSize: 12),
                              ),
                              trailing: isConnected 
                                ? const Icon(Icons.check_circle, color: Color(0xFFFFEB3B), size: 20)
                                : const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
