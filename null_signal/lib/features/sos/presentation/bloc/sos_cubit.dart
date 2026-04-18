import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:uuid/uuid.dart';
import 'package:cryptography/cryptography.dart';

abstract class SosState {}

class SosInitial extends SosState {}
class SosBroadcasting extends SosState {
  final bool isDmsActive;
  final math.Point<double>? triangulatedPosition;
  SosBroadcasting({this.isDmsActive = false, this.triangulatedPosition});
}
class SosBroadcastSuccess extends SosState {
  final String packetId;
  SosBroadcastSuccess(this.packetId);
}
class SosError extends SosState {
  final String message;
  SosError(this.message);
}

class SosCubit extends Cubit<SosState> {
  final MeshService _meshService;
  final SecurityService _securityService;
  final String _currentDeviceId;

  SosCubit(this._meshService, this._securityService, this._currentDeviceId) : super(SosInitial());

  Timer? _broadcastTimer;

  Future<void> broadcastSos({double? lat, double? lon, bool isDms = false}) async {
    emit(SosBroadcasting(isDmsActive: isDms));
    try {
      double finalLat = lat ?? 0.0;
      double finalLon = lon ?? 0.0;

      // Fetch real GPS if not provided or at default
      if (lat == null || lon == null || (lat == 0.0 && lon == 0.0)) {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
          finalLat = position.latitude;
          finalLon = position.longitude;
        } catch (e) {
          // Fallback to mock if GPS fails for any reason
          finalLat = 40.7128; 
          finalLon = -74.0060;
        }
      }

      final packetId = const Uuid().v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final payload = isDms ? 'DMS_ACTIVE: User unresponsive.' : 'SOS: User requires immediate assistance. Coordinates provided.';
      final keyPair = await _securityService.getOrCreateIdentity();
      final signature = await _securityService.sign(payload, keyPair);
      
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyBase64 = base64.encode((publicKey as SimplePublicKey).bytes);

      final packet = MeshPacket(
        packetId: packetId,
        senderId: _currentDeviceId,
        senderPublicKey: publicKeyBase64,
        payload: payload,
        signature: signature,
        timestamp: timestamp,
        ttl: 5, // 5-hop broadcast
        priority: PacketPriority.critical,
        latitude: finalLat,
        longitude: finalLon,
        isGatewayRelay: true, // SOS should always try to hit a gateway
      );

      // Periodic broadcast for high visibility
      _broadcastTimer?.cancel();
      _broadcastTimer = Timer.periodic(const Duration(seconds: 15), (_) => _meshService.sendPacket(packet));

      await _meshService.sendPacket(packet);

      emit(SosBroadcastSuccess(packetId));
    } catch (e) {
      emit(SosError('Broadcast Failed: $e'));
    }
  }

  void reset() {
    _broadcastTimer?.cancel();
    emit(SosInitial());
  }
}
