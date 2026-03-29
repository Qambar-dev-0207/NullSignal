import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:nearby_connections/nearby_connections.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyMeshServiceImpl implements MeshService {
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final String _serviceId = "com.nullsignal.p2p";
  final String _userName = "User_${DateTime.now().millisecondsSinceEpoch % 1000}";

  @override
  String get deviceId => _userName;

  final BehaviorSubject<List<MeshDevice>> _devicesSubject = BehaviorSubject<List<MeshDevice>>.seeded([]);
  final PublishSubject<MeshPacket> _incomingPacketsSubject = PublishSubject<MeshPacket>();

  final Map<String, MeshDevice> _discoveredDevices = {};

  @override
  Stream<List<MeshDevice>> get devicesStream => _devicesSubject.stream;

  @override
  Stream<MeshPacket> get incomingPackets => _incomingPacketsSubject.stream;

  @override
  List<MeshDevice> get currentDevices => _devicesSubject.value;

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  @override
  Future<void> start() async {
    developer.log('MeshService: Starting...', name: 'MeshService');
    if (!await _checkPermissions()) {
      developer.log('MeshService: Permissions denied', name: 'MeshService');
      return;
    }

    // 1. Start Advertising
    try {
      await Nearby().startAdvertising(
        _userName,
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );
      developer.log('MeshService: Advertising started', name: 'MeshService');
    } catch (e) {
      developer.log('MeshService: Advertising failed: $e', name: 'MeshService');
    }

    // 2. Start Discovery
    try {
      await Nearby().startDiscovery(
        _userName,
        _strategy,
        onEndpointFound: (id, name, serviceId) {
          developer.log('MeshService: Endpoint found: $id ($name)', name: 'MeshService');
          final device = MeshDevice(
            deviceId: id,
            deviceName: name,
            status: MeshDeviceStatus.discovered,
          );
          _discoveredDevices[id] = device;
          _updateDevices();
          
          // Auto-connect for mesh behavior
          connect(device);
        },
        onEndpointLost: (id) {
          developer.log('MeshService: Endpoint lost: $id', name: 'MeshService');
          _discoveredDevices.remove(id);
          _updateDevices();
        },
        serviceId: _serviceId,
      );
      developer.log('MeshService: Discovery started', name: 'MeshService');
    } catch (e) {
      developer.log('MeshService: Discovery failed: $e', name: 'MeshService');
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    developer.log('MeshService: Connection initiated with $id (${info.endpointName})', name: 'MeshService');
    // Accept all connections for decentralized mesh
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (id, payload) {
        developer.log('MeshService: Payload received from $id', name: 'MeshService');
        if (payload.type == PayloadType.BYTES) {
          final jsonString = utf8.decode(payload.bytes!);
          try {
            final json = jsonDecode(jsonString);
            final packet = MeshPacket.fromJson(json);
            developer.log('MeshService: Mesh packet received: ${packet.packetId} (Priority: ${packet.priority})', name: 'MeshService');
            _incomingPacketsSubject.add(packet);
          } catch (e) {
            developer.log('MeshService: Failed to parse mesh packet: $e', name: 'MeshService');
          }
        }
      },
      onPayloadTransferUpdate: (id, update) {
        if (update.status == PayloadStatus.FAILURE) {
          developer.log('MeshService: Payload transfer failed with $id', name: 'MeshService');
        }
      },
    );
  }

  void _onConnectionResult(String id, Status status) {
    developer.log('MeshService: Connection result for $id: $status', name: 'MeshService');
    final existing = _discoveredDevices[id];
    
    // If it's a new device that initiated connection to us
    final device = existing ?? MeshDevice(deviceId: id, deviceName: 'Unknown', status: MeshDeviceStatus.connecting);

    MeshDeviceStatus newStatus;
    switch (status) {
      case Status.CONNECTED:
        newStatus = MeshDeviceStatus.connected;
        break;
      case Status.REJECTED:
      case Status.ERROR:
        newStatus = MeshDeviceStatus.disconnected;
        break;
    }
    _discoveredDevices[id] = device.copyWith(status: newStatus);
    _updateDevices();
  }

  void _onDisconnected(String id) {
    developer.log('MeshService: Disconnected from $id', name: 'MeshService');
    final existing = _discoveredDevices[id];
    if (existing != null) {
      _discoveredDevices[id] = existing.copyWith(status: MeshDeviceStatus.disconnected);
      _updateDevices();
    }
  }

  void _updateDevices() {
    _devicesSubject.add(_discoveredDevices.values.toList());
  }

  @override
  Future<void> stop() async {
    developer.log('MeshService: Stopping...', name: 'MeshService');
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    await Nearby().stopAllEndpoints();
    _discoveredDevices.clear();
    _updateDevices();
  }

  @override
  Future<void> connect(MeshDevice device) async {
    developer.log('MeshService: Requesting connection to ${device.deviceId}', name: 'MeshService');
    try {
      await Nearby().requestConnection(
        _userName,
        device.deviceId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      developer.log('MeshService: Connection request failed: $e', name: 'MeshService');
    }
  }

  @override
  Future<void> sendPacket(MeshPacket packet) async {
    developer.log('MeshService: Broadcasting packet ${packet.packetId} to ${currentDevices.length} nodes', name: 'MeshService');
    final jsonString = jsonEncode(packet.toJson());
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    
    int sentCount = 0;
    for (final device in currentDevices) {
      if (device.isConnected) {
        await Nearby().sendBytesPayload(device.deviceId, bytes);
        sentCount++;
      }
    }
    developer.log('MeshService: Packet sent to $sentCount connected nodes', name: 'MeshService');
  }

  void dispose() {
    stop();
    _devicesSubject.close();
    _incomingPacketsSubject.close();
  }
}
