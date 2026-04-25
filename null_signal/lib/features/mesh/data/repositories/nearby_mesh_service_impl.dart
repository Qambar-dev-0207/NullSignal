import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
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
  final Isar _isar;
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final String _serviceId = "com.nullsignal.p2p";
  late final RoutingEngine _routingEngine;
  KeyPair? _myKeyPair;
  Timer? _heartbeatTimer;
  Timer? _pruningTimer;
  final Set<String> _connectingDeviceIds = {};

  NearbyMeshServiceImpl(this._gatewayMonitor, this._securityService, this._isar, {SatelliteGatewayService? satelliteService}) {
    _routingEngine = RoutingEngine(_isar);
    developer.log('[NULLSIGNAL] MeshService: Initialized', name: 'MeshService');
  }

  @override
  String get deviceId => _securityService.deviceId;

  final BehaviorSubject<List<MeshDevice>> _devicesSubject = BehaviorSubject<List<MeshDevice>>.seeded([]);
  final PublishSubject<MeshPacket> _incomingPacketsSubject = PublishSubject<MeshPacket>();

  final Map<String, MeshDevice> _discoveredDevices = {};
  final Map<String, String> _endpointToDeviceId = {};

  @override
  Stream<List<MeshDevice>> get devicesStream => _devicesSubject.stream;

  @override
  Stream<MeshPacket> get incomingPackets => _incomingPacketsSubject.stream;

  @override
  Stream<List<Peer>> get peersStream => _isar.peers.where().sortByLastSeenDesc().watch(fireImmediately: true);

  @override
  List<MeshDevice> get currentDevices => _devicesSubject.value;

  Future<bool> _checkPermissions() async {
    developer.log('[NULLSIGNAL] MeshService: Requesting Mesh Permissions...', name: 'MeshService');
    
    // 1. Basic permission checks
    List<Permission> permissions = [
      Permission.location,
      Permission.nearbyWifiDevices,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted && permission != Permission.locationAlways) {
        developer.log('[NULLSIGNAL] MeshService: Permission $permission DENIED', name: 'MeshService');
        allGranted = false;
      }
    });

    return allGranted;
  }

  @override
  Future<void> start() async {
    developer.log('[NULLSIGNAL] MeshService: STARTING with ID: $deviceId', name: 'MeshService');
    
    if (!await _checkPermissions()) {
      developer.log('[NULLSIGNAL] MeshService: CRITICAL - Permissions missing.', name: 'MeshService');
      return;
    }

    _myKeyPair = await _securityService.getOrCreateIdentity();
    final advertisingName = _gatewayMonitor.isGateway ? "$deviceId|G" : deviceId;

    // 1. Start Advertising
    try {
      developer.log('[NULLSIGNAL] MeshService: Activating Advertising as $advertisingName...', name: 'MeshService');
      bool started = await Nearby().startAdvertising(
        advertisingName,
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: (id, status) {
          developer.log('[NULLSIGNAL] MeshService: Connection Result for $id: $status', name: 'MeshService');
          _onConnectionResult(id, status);
        },
        onDisconnected: (id) {
          developer.log('[NULLSIGNAL] MeshService: Device Disconnected: $id', name: 'MeshService');
          _onDisconnected(id);
        },
        serviceId: _serviceId,
      );
      if (!started) {
        developer.log('[NULLSIGNAL] MeshService: Advertising failed to start (returned false)', name: 'MeshService');
      }
    } catch (e) {
      developer.log('[NULLSIGNAL] MeshService: Advertising ERROR: $e', name: 'MeshService');
    }

    // 2. Start Discovery
    try {
      developer.log('[NULLSIGNAL] MeshService: Activating Discovery...', name: 'MeshService');
      bool started = await Nearby().startDiscovery(
        deviceId, // Discovery name
        _strategy,
        onEndpointFound: (id, name, serviceId) {
          developer.log('[NULLSIGNAL] MeshService: NODE FOUND: $id ($name)', name: 'MeshService');
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
          
          // Use device ID comparison for deterministic connection initiator
          if (deviceId.compareTo(id) < 0) {
            developer.log('[NULLSIGNAL] MeshService: Primary. Initiating to $id...', name: 'MeshService');
            connect(device);
          }
        },
        onEndpointLost: (id) {
          developer.log('[NULLSIGNAL] MeshService: NODE LOST: $id', name: 'MeshService');
          _discoveredDevices.remove(id);
          _endpointToDeviceId.remove(id);
          _updateDevices();
        },
        serviceId: _serviceId,
      );
      if (!started) {
        developer.log('[NULLSIGNAL] MeshService: Discovery failed to start (returned false)', name: 'MeshService');
      }
    } catch (e) {
      developer.log('[NULLSIGNAL] MeshService: Discovery ERROR: $e', name: 'MeshService');
    }

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
    developer.log('[NULLSIGNAL] MeshService: Accepting connection from $id (${info.endpointName})', name: 'MeshService');
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
            
            final publicKeyBytes = base64.decode(packet.senderPublicKey);
            final senderPublicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
            final isValid = await _securityService.verify(packet.payload, packet.signature, senderPublicKey);
            
            if (!isValid) {
              developer.log('[NULLSIGNAL] MeshService: Invalid Signature on packet ${packet.packetId}', name: 'MeshService');
              return;
            }

            // Update mapping and device info
            _endpointToDeviceId[id] = packet.senderId;
            final device = _discoveredDevices[id];
            if (device != null && device.publicKey == null) {
              _discoveredDevices[id] = device.copyWith(publicKey: packet.senderPublicKey);
              _updateDevices();
            }

            // 1. Check if we've already seen this packet to prevent loops/duplicates
            if (!await _routingEngine.shouldForward(packet, deviceId)) {
              // Note: shouldForward returns false if it's already seen OR if it's for us.
            }
            
            // Re-evaluating routing check:
            final isNew = (await _isar.seenPackets.filter().packetIdEqualTo(packet.packetId).findFirst()) == null;
            if (!isNew) return; // Skip duplicate processing

            // 2. Mark as seen
            await _isar.writeTxn(() async {
              await _isar.seenPackets.put(SeenPacket(
                packetId: packet.packetId,
                timestamp: DateTime.now().millisecondsSinceEpoch,
              ));
            });

            final receiverId = packet.receiverId;
            final forUs = receiverId == deviceId || receiverId == null;

            if (forUs && packet.payload != 'HEARTBEAT') {
              _incomingPacketsSubject.add(packet);
            }

            // 3. Save to history (except Heartbeats)
            if (packet.payload != 'HEARTBEAT') {
              await _isar.writeTxn(() async {
                final existingPeer = await _isar.peers.filter().deviceIdEqualTo(packet.senderId).findFirst();
                if (existingPeer == null) {
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
            }

            // 4. Internet Gateway Relay
            if (packet.isGatewayRelay && _gatewayMonitor.isGateway) {
              _bridgeToInternet(packet);
            }
            
            // 5. Forwarding logic
            if (packet.ttl > 0 && receiverId != deviceId) {
              final forwardedPacket = _routingEngine.decrementTtl(packet);
              sendPacket(forwardedPacket);
            }
          } catch (e) {
            developer.log('[NULLSIGNAL] MeshService: Packet Processing Error: $e', name: 'MeshService');
          }
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
        developer.log('[NULLSIGNAL] MeshService: CONNECTED TO $id', name: 'MeshService');
        newStatus = MeshDeviceStatus.connected;
        break;
      case Status.REJECTED:
        developer.log('[NULLSIGNAL] MeshService: REJECTED BY $id', name: 'MeshService');
        newStatus = MeshDeviceStatus.disconnected;
        break;
      case Status.ERROR:
        developer.log('[NULLSIGNAL] MeshService: ERROR WITH $id', name: 'MeshService');
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
    _endpointToDeviceId.clear();
    _updateDevices();
  }

  @override
  Future<void> connect(MeshDevice device) async {
    if (_connectingDeviceIds.contains(device.deviceId)) return;
    if (_discoveredDevices[device.deviceId]?.isConnected == true) return;
    
    _connectingDeviceIds.add(device.deviceId);
    
    try {
      developer.log('[NULLSIGNAL] MeshService: Connecting to ${device.deviceId}...', name: 'MeshService');
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
          Future.delayed(const Duration(seconds: 5), () {
            final d = _discoveredDevices[id];
            if (d != null) connect(d);
          });
        },
      ).timeout(const Duration(seconds: 30)); 
    } catch (e) {
      _connectingDeviceIds.remove(device.deviceId);
      developer.log('[NULLSIGNAL] MeshService: FAILED to ${device.deviceId}: $e', name: 'MeshService');
      Future.delayed(const Duration(seconds: 10), () => connect(device));
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

    final jsonString = jsonEncode(packetWithPublicKey.toJson());
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    
    for (final device in currentDevices) {
      if (device.isConnected) {
        try {
          await Nearby().sendBytesPayload(device.deviceId, bytes);
        } catch (e) {
          developer.log('[NULLSIGNAL] MeshService: Send Error to ${device.deviceId}: $e', name: 'MeshService');
        }
      }
    }
  }

  void dispose() {
    stop();
    _devicesSubject.close();
    _incomingPacketsSubject.close();
  }
}
