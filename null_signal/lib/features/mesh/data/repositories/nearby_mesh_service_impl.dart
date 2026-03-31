import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:nearby_connections/nearby_connections.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:null_signal/features/mesh/domain/repositories/routing_engine.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cryptography/cryptography.dart';

class NearbyMeshServiceImpl implements MeshService {
  final GatewayMonitor _gatewayMonitor;
  final SecurityService _securityService;
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final String _serviceId = "com.nullsignal.p2p";
  final String _userName = "User_${DateTime.now().millisecondsSinceEpoch % 1000}";
  final RoutingEngine _routingEngine = RoutingEngine();
  KeyPair? _myKeyPair;

  NearbyMeshServiceImpl(this._gatewayMonitor, this._securityService);

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

    _myKeyPair ??= await _securityService.generateIdentity();
    final advertisingName = _gatewayMonitor.isGateway ? "$_userName|G" : _userName;

    // 1. Start Advertising
    try {
      await Nearby().startAdvertising(
        advertisingName,
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );
      developer.log('MeshService: Advertising started as $advertisingName', name: 'MeshService');
    } catch (e) {
      developer.log('MeshService: Advertising failed: $e', name: 'MeshService');
    }

    // 2. Start Discovery
    try {
      await Nearby().startDiscovery(
        advertisingName,
        _strategy,
        onEndpointFound: (id, name, serviceId) {
          developer.log('MeshService: Endpoint found: $id ($name)', name: 'MeshService');
          final isGateway = name.endsWith('|G');
          final cleanName = isGateway ? name.substring(0, name.length - 2) : name;
          final device = MeshDevice(
            deviceId: id,
            deviceName: cleanName,
            status: MeshDeviceStatus.discovered,
            isGateway: isGateway,
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
      onPayLoadRecieved: (id, payload) async {
        developer.log('MeshService: Payload received from $id', name: 'MeshService');
        if (payload.type == PayloadType.BYTES) {
          final jsonString = utf8.decode(payload.bytes!);
          try {
            final json = jsonDecode(jsonString);
            final packet = MeshPacket.fromJson(json);
            developer.log('MeshService: Mesh packet received: ${packet.packetId} (Priority: ${packet.priority})', name: 'MeshService');
            
            // 1. Convert packet.senderPublicKey from base64 to PublicKey
            final publicKeyBytes = base64.decode(packet.senderPublicKey);
            final senderPublicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
            
            // Store public key for E2EE if we know this device
            final device = _discoveredDevices[packet.senderId];
            if (device != null && device.publicKey != packet.senderPublicKey) {
              _discoveredDevices[packet.senderId] = device.copyWith(publicKey: packet.senderPublicKey);
              _updateDevices();
            }

            // 2. Use SecurityService.verify() to validate the packet
            final isValid = await _securityService.verify(packet.payload, packet.signature, senderPublicKey);
            
            if (!isValid) {
              developer.log('MeshService: Invalid packet signature from ${packet.senderId}. DROPPING.', name: 'MeshService');
              return;
            }

            // 3. If valid AND packet.isGatewayRelay is true AND gatewayMonitor.isGateway is true
            if (packet.isGatewayRelay && _gatewayMonitor.isGateway) {
              developer.log('GATEWAY: Bridging packet ${packet.packetId} to internet', name: 'MeshService');
            }
            
            // Handle packet routing for multi-hop
            if (_routingEngine.shouldForward(packet, _userName)) {
              developer.log('MeshService: Forwarding packet ${packet.packetId}', name: 'MeshService');
              final forwardedPacket = _routingEngine.decrementTtl(packet);
              sendPacket(forwardedPacket);
            }
            
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
  Future<void> reconnect(String deviceId) async {
    developer.log('MeshService: Attempting to reconnect to $deviceId', name: 'MeshService');
    try {
      await Nearby().requestConnection(
        _userName,
        deviceId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      developer.log('MeshService: Reconnection failed: $e', name: 'MeshService');
    }
  }

  @override
  Future<void> sendPacket(MeshPacket packet) async {
    developer.log('MeshService: Broadcasting packet ${packet.packetId} to ${currentDevices.length} nodes', name: 'MeshService');
    
    // Ensure the local PublicKey is attached to every packet sent.
    _myKeyPair ??= await _securityService.generateIdentity();
    final publicKey = await _myKeyPair!.extractPublicKey();
    final publicKeyBase64 = base64.encode((publicKey as SimplePublicKey).bytes);

    final packetWithPublicKey = MeshPacket(
      packetId: packet.packetId,
      senderId: packet.senderId,
      senderPublicKey: publicKeyBase64,
      receiverId: packet.receiverId,
      payload: packet.payload,
      signature: packet.signature,
      timestamp: packet.timestamp,
      ttl: packet.ttl,
      priority: packet.priority,
      latitude: packet.latitude,
      longitude: packet.longitude,
      isGatewayRelay: packet.isGatewayRelay,
    );

    final jsonString = jsonEncode(packetWithPublicKey.toJson());
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
