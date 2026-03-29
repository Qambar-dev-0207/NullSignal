import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:uuid/uuid.dart';

abstract class SosState {}

class SosInitial extends SosState {}
class SosBroadcasting extends SosState {}
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

  Future<void> broadcastSos({required double lat, required double lon}) async {
    emit(SosBroadcasting());
    try {
      final packetId = const Uuid().v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      const payload = 'SOS: User requires immediate assistance. Coordinates provided.';
      final keyPair = await _securityService.generateIdentity();
      final signature = await _securityService.sign(payload, keyPair);

      final packet = MeshPacket(
        packetId: packetId,
        senderId: _currentDeviceId,
        payload: payload,
        signature: signature.toString(),
        timestamp: timestamp,
        ttl: 5, // 5-hop broadcast
        priority: PacketPriority.critical,
        latitude: lat,
        longitude: lon,
      );

      await _meshService.sendPacket(packet);
      emit(SosBroadcastSuccess(packetId));
    } catch (e) {
      emit(SosError('Broadcast Failed: $e'));
    }
  }

  void reset() => emit(SosInitial());
}
