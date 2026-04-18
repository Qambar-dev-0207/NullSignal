import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cryptography/cryptography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:uuid/uuid.dart';

class MeshState {
  final List<MeshDevice> connectedDevices;
  final List<MeshDevice> scannedDevices;
  final bool isScanning;

  MeshState({
    required this.connectedDevices,
    required this.scannedDevices,
    required this.isScanning,
  });

  int get connectedNodeCount => connectedDevices.length;
}

class MeshCubit extends Cubit<MeshState> {
  final MeshService _meshService;
  final SecurityService _securityService;
  final String _deviceId;
  StreamSubscription? _deviceSubscription;

  MeshCubit(this._meshService, this._securityService, this._deviceId) : super(MeshState(
    connectedDevices: [],
    scannedDevices: [],
    isScanning: false,
  ));

  void startScanning() async {
    emit(MeshState(
      connectedDevices: state.connectedDevices,
      scannedDevices: state.scannedDevices,
      isScanning: true,
    ));
    await _meshService.start();
    
    _deviceSubscription = _meshService.devicesStream.listen((devices) {
      final connected = devices.where((d) => d.isConnected).toList();
      final scanned = devices.where((d) => !d.isConnected).toList();
      
      emit(MeshState(
        connectedDevices: connected,
        scannedDevices: scanned,
        isScanning: true,
      ));
    });

    // Handle incoming direct messages
    _meshService.incomingPackets.listen((packet) async {
      if (packet.receiverId == _deviceId) {
        developer.log('MeshCubit: New direct message received from ${packet.senderId}');
        // In a real app, we would decrypt and show a notification or update a chat UI
        // For now, we'll log it and assume the receiver logic is working.
      }
    });
  }

  void connectToDevice(MeshDevice device) async {
    await _meshService.connect(device);
  }

  Future<void> sendDirectMessage(MeshDevice device, String message) async {
    try {
      final packetId = const Uuid().v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final myKeyPair = await _securityService.getOrCreateIdentity();
      
      String payloadToTransmit = message;
      
      // Perform E2EE if recipient's public key is known
      if (device.publicKey != null) {
        try {
          final recipientPublicKeyBytes = base64.decode(device.publicKey!);
          final recipientPublicKey = SimplePublicKey(recipientPublicKeyBytes, type: KeyPairType.ed25519);
          
          // Derive shared secret using X25519 (SecurityService handles mapping/derivation internally)
          final sharedKey = await _securityService.deriveSharedSecret(myKeyPair, recipientPublicKey);
          
          // Encrypt payload
          payloadToTransmit = await _securityService.encryptE2E(message, sharedKey);
          developer.log('MeshCubit: Message E2EE encrypted for ${device.deviceId}');
        } catch (e) {
          developer.log('MeshCubit: E2EE Encryption failed, falling back to cleartext: $e');
        }
      }

      final signature = await _securityService.sign(payloadToTransmit, myKeyPair);
      final myPublicKey = await myKeyPair.extractPublicKey();

      final packet = MeshPacket(
        packetId: packetId,
        senderId: _deviceId,
        senderPublicKey: base64.encode((myPublicKey as SimplePublicKey).bytes),
        receiverId: device.deviceId,
        payload: payloadToTransmit,
        signature: signature,
        timestamp: timestamp,
        ttl: 3, 
        priority: PacketPriority.medium,
        latitude: 0.0,
        longitude: 0.0,
      );

      await _meshService.sendPacket(packet);
    } catch (e) {
      developer.log('MeshCubit: Failed to send direct message: $e');
    }
  }

  void stopScanning() async {
    await _deviceSubscription?.cancel();
    await _meshService.stop();
    emit(MeshState(
      connectedDevices: [],
      scannedDevices: [],
      isScanning: false,
    ));
  }

  @override
  Future<void> close() {
    _deviceSubscription?.cancel();
    return super.close();
  }
}
