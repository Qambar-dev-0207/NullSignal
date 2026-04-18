import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:nearby_connections/nearby_connections.dart';
import 'package:isar/isar.dart';
import 'package:http/http.dart' as http;
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/models/peer.dart';
import 'package:null_signal/core/models/contact.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/core/services/satellite_gateway_service.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:null_signal/features/mesh/domain/repositories/routing_engine.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';

class NearbyMeshServiceImpl implements MeshService {
  final GatewayMonitor _gatewayMonitor;
  final SecurityService _securityService;
  final SatelliteGatewayService? _satelliteService;
  final Isar _isar;
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final String _serviceId = "com.nullsignal.p2p";
  late final RoutingEngine _routingEngine;
  KeyPair? _myKeyPair;
  Timer? _heartbeatTimer;
  Timer? _pruningTimer;
  final Set<String> _connectingDeviceIds = {};

  NearbyMeshServiceImpl(this._gatewayMonitor, this._securityService, this._isar, {SatelliteGatewayService? satelliteService}) 
    : _satelliteService = satelliteService {
    _routingEngine = RoutingEngine(_isar);
  }

  @override
  String get deviceId => _securityService.deviceId;

  final BehaviorSubject<List<MeshDevice>> _devicesSubject = BehaviorSubject<List<MeshDevice>>.seeded([]);
  final PublishSubject<MeshPacket> _incomingPacketsSubject = PublishSubject<MeshPacket>();

  final Map<String, MeshDevice> _discoveredDevices = {};

  @override
  Stream<List<MeshDevice>> get devicesStream => _devicesSubject.stream;

  @override
  Stream<MeshPacket> get incomingPackets => _incomingPacketsSubject.stream;

  @override
  Stream<List<Peer>> get peersStream => _isar.peers.where().sortByLastSeenDesc().watch(fireImmediately: true);

  @override
  List<MeshDevice> get currentDevices => _devicesSubject.value;

  Future<bool> _checkPermissions() async {
    List<Permission> permissions = [
      Permission.location,
      Permission.nearbyWifiDevices,
    ];

    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
      ]);
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    bool essentialGranted = statuses[Permission.location]?.isGranted ?? false;
    if (Platform.isAndroid) {
      essentialGranted = essentialGranted && 
        (statuses[Permission.bluetoothScan]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothAdvertise]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothConnect]?.isGranted ?? false);
    }

    if (!essentialGranted) {
      developer.log('MeshService: Essential permissions missing: ${statuses.entries.where((e) => !e.value.isGranted).map((e) => e.key).toList()}', name: 'MeshService');
    }

    return essentialGranted;
  }

  @override
  Future<void> start() async {
    developer.log('MeshService: Starting...', name: 'MeshService');
    if (!await _checkPermissions()) {
      developer.log('MeshService: Permissions denied', name: 'MeshService');
    }

    _myKeyPair = await _securityService.getOrCreateIdentity();
    final advertisingName = _gatewayMonitor.isGateway ? "$deviceId|G" : deviceId;

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
          
          // AUTO-CONNECT logic for immediate mesh formation
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

    // 3. Start Heartbeat & Pruning
    _startHeartbeat();
    _startPruning();
  }

  void _startPruning() {
    _pruningTimer?.cancel();
    _pruningTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _routingEngine.pruneSeenCache();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendHeartbeat();
    });
  }

  Future<void> _sendHeartbeat() async {
    if (currentDevices.where((d) => d.isConnected).isEmpty) return;
    
    final packetId = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    _myKeyPair ??= await _securityService.getOrCreateIdentity();
    const payload = 'HEARTBEAT';
    final signature = await _securityService.sign(payload, _myKeyPair!);
    
    final publicKey = await _myKeyPair!.extractPublicKey();
    final publicKeyBase64 = base64.encode((publicKey as SimplePublicKey).bytes);

    final packet = MeshPacket(
      packetId: packetId,
      senderId: deviceId,
      senderPublicKey: publicKeyBase64,
      payload: payload,
      signature: signature,
      timestamp: timestamp,
      ttl: 1,
      priority: PacketPriority.low,
      latitude: 0.0,
      longitude: 0.0,
    );

    sendPacket(packet);
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    developer.log('MeshService: Auto-accepting connection with $id', name: 'MeshService');
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (id, payload) async {
        if (payload.type == PayloadType.BYTES) {
          final bytes = payload.bytes;
          if (bytes == null) return;
          final jsonString = utf8.decode(bytes);
          try {
            final json = jsonDecode(jsonString);
            final packet = MeshPacket.fromJson(json);
            
            // 1. Validate Signature
            final publicKeyBytes = base64.decode(packet.senderPublicKey);
            final senderPublicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
            final isValid = await _securityService.verify(packet.payload, packet.signature, senderPublicKey);
            
            if (!isValid) return;

            // 2. Direct for us or Broadcast
            final receiverId = packet.receiverId;
            if (receiverId == deviceId || receiverId == null) {
              if (packet.payload != 'HEARTBEAT') {
                _incomingPacketsSubject.add(packet);
              }
              // If it's specifically for us, we don't need to check forwarding (though mesh typically floods)
              if (receiverId == deviceId) return;
            }

            // 3. Forwarding (Flood Routing with duplicate suppression)
            if (!await _routingEngine.shouldForward(packet, deviceId)) return;

            await _isar.writeTxn(() async {
              final existingPeer = await _isar.peers.filter().deviceIdEqualTo(packet.senderId).findFirst();
              if (existingPeer == null) {
                final device = _discoveredDevices[id];
                final newPeer = Peer(
                  deviceId: packet.senderId,
                  deviceName: device?.deviceName ?? 'Unknown Node',
                  publicKey: packet.senderPublicKey,
                  lastSeen: DateTime.now().millisecondsSinceEpoch,
                );
                await _isar.peers.put(newPeer);
              } else {
                final updatedPeer = existingPeer.copyWith(
                  publicKey: packet.senderPublicKey,
                  lastSeen: DateTime.now().millisecondsSinceEpoch,
                );
                await _isar.peers.put(updatedPeer);
              }
              await _isar.meshPackets.put(packet);
            });

            if (packet.isGatewayRelay && _gatewayMonitor.isGateway) {
              _bridgeToInternet(packet);
            }
            
            final forwardedPacket = _routingEngine.decrementTtl(packet);
            sendPacket(forwardedPacket);
            
            if (packet.payload != 'HEARTBEAT') {
              _incomingPacketsSubject.add(packet);
            }
          } catch (_) {}
        }
      },
      onPayloadTransferUpdate: (id, payloadTransferUpdate) {},
    );
  }

  Future<void> _bridgeToInternet(MeshPacket packet) async {
    try {
      final url = Uri.parse('https://api.nullsignal.io/v1/sos/relay');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'packetId': packet.packetId,
          'senderId': packet.senderId,
          'coordinates': {'lat': packet.latitude, 'lon': packet.longitude},
          'payload': packet.payload,
          'timestamp': packet.timestamp,
        }),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  void _onConnectionResult(String id, Status status) {
    final existing = _discoveredDevices[id];
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
    _heartbeatTimer?.cancel();
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    await Nearby().stopAllEndpoints();
    _discoveredDevices.clear();
    _updateDevices();
  }

  @override
  Future<void> connect(MeshDevice device) async {
    if (_connectingDeviceIds.contains(device.deviceId) || device.isConnected) return;
    
    _connectingDeviceIds.add(device.deviceId);
    int retries = 0;
    const maxRetries = 2;

    while (retries <= maxRetries) {
      try {
        await Nearby().requestConnection(
          deviceId,
          device.deviceId,
          onConnectionInitiated: _onConnectionInitiated,
          onConnectionResult: (id, status) {
            _connectingDeviceIds.remove(id);
            _onConnectionResult(id, status);
          },
          onDisconnected: (id) {
            _connectingDeviceIds.remove(id);
            _onDisconnected(id);
          },
        ).timeout(const Duration(seconds: 15));
        return; // Success or initiated
      } catch (e) {
        retries++;
        if (retries <= maxRetries) {
          await Future.delayed(Duration(seconds: 2 * retries));
        } else {
          _connectingDeviceIds.remove(device.deviceId);
          developer.log('MeshService: Failed to connect to ${device.deviceId} after $maxRetries retries', name: 'MeshService');
        }
      }
    }
  }

  @override
  Future<void> reconnect(String deviceId) async {
    try {
      await Nearby().requestConnection(
        this.deviceId,
        deviceId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      ).timeout(const Duration(seconds: 15));
    } catch (_) {}
  }

  @override
  Future<void> sendPacket(MeshPacket packet) async {
    _myKeyPair ??= await _securityService.getOrCreateIdentity();
    final publicKey = await _myKeyPair!.extractPublicKey();
    final publicKeyBase64 = base64.encode((publicKey as SimplePublicKey).bytes);

    final packetWithPublicKey = MeshPacket(
      packetId: packet.packetId,
      senderId: packet.senderId,
      senderPublicKey: publicKeyBase64,
      receiverId: packet.receiverId,
      packetType: packet.packetType,
      payload: packet.payload,
      signature: packet.signature,
      timestamp: packet.timestamp,
      ttl: packet.ttl,
      priority: packet.priority,
      latitude: packet.latitude,
      longitude: packet.longitude,
      isGatewayRelay: packet.isGatewayRelay,
    );

    await _isar.writeTxn(() async {
      await _isar.seenPackets.put(SeenPacket(packetId: packet.packetId, timestamp: packet.timestamp));
      await _isar.meshPackets.put(packetWithPublicKey);
    });

    if (packet.isGatewayRelay && _gatewayMonitor.isGateway) {
      _bridgeToInternet(packetWithPublicKey);
    } else if (packet.isGatewayRelay && packet.priority == PacketPriority.critical && _satelliteService != null) {
      _satelliteService.isSatelliteAvailable().then((available) {
        if (available) {
          _satelliteService.sendViaSatellite(packetWithPublicKey);
        }
      });
    }

    final jsonString = jsonEncode(packetWithPublicKey.toJson());
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    
    for (final device in currentDevices) {
      if (device.isConnected) {
        await Nearby().sendBytesPayload(device.deviceId, bytes);
      }
    }
  }

  void dispose() {
    stop();
    _devicesSubject.close();
    _incomingPacketsSubject.close();
  }
}
