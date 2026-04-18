import 'dart:async';
import 'package:null_signal/core/models/mesh_packet.dart';

abstract class SatelliteGatewayService {
  /// Whether the device has satellite hardware available
  Future<bool> isSatelliteAvailable();

  /// Send a critical mesh packet via the Android Satellite SOS API (Simulated)
  Future<bool> sendViaSatellite(MeshPacket packet);

  /// Stream of satellite connection status
  Stream<SatelliteStatus> get statusStream;
}

enum SatelliteStatus {
  unavailable,
  searching,
  connected,
  sending,
  sent,
  failed,
}

class SatelliteGatewayServiceImpl implements SatelliteGatewayService {
  final _statusSubject = StreamController<SatelliteStatus>.broadcast();

  @override
  Stream<SatelliteStatus> get statusStream => _statusSubject.stream;

  @override
  Future<bool> isSatelliteAvailable() async {
    // In a real implementation, this would check against Android 14+ Satellite APIs
    // For simulation, we assume high-end 2026 devices have it.
    return true; 
  }

  @override
  Future<bool> sendViaSatellite(MeshPacket packet) async {
    _statusSubject.add(SatelliteStatus.searching);
    await Future.delayed(const Duration(seconds: 5));
    
    _statusSubject.add(SatelliteStatus.connected);
    await Future.delayed(const Duration(seconds: 3));
    
    _statusSubject.add(SatelliteStatus.sending);
    await Future.delayed(const Duration(seconds: 10));
    
    _statusSubject.add(SatelliteStatus.sent);
    return true;
  }
}
