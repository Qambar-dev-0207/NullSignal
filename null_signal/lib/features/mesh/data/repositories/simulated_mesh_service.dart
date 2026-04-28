import 'dart:async';
import 'dart:math';
import 'package:isar/isar.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/models/peer.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class SimulatedMeshService implements MeshService {
  final SecurityService _securityService;
  final _random = Random();
  final BehaviorSubject<List<MeshDevice>> _devicesSubject =
      BehaviorSubject<List<MeshDevice>>.seeded([]);
  final PublishSubject<MeshPacket> _incomingPacketsSubject =
      PublishSubject<MeshPacket>();

  Timer? _simulationTimer;
  Timer? _messageTimer;
  Timer? _joinLeaveTimer;
  final Map<String, MeshDevice> _simulatedDevices = {};

  // Fixed roster — realistic names for demo topology
  static const _roster = [
    ('Node_alpha1', 'Rescue-Alpha',   false, true,  -45, 0.92),
    ('Node_beta22', 'Field-Beta',     false, true,  -58, 0.71),
    ('Node_gw001',  'Gateway-Tower',  true,  true,  -52, 0.88),
    ('Node_delta4', 'Medic-Delta',    false, true,  -63, 0.55),
    ('Node_echo55', 'Survivor-Echo',  false, false, -78, 0.34),
    ('Node_foxt6',  'Relay-Foxtrot',  false, false, -81, 0.60),
    ('Node_golf77', 'Command-Golf',   true,  false, -70, 0.95),
  ];

  // Simulated status messages from peer nodes
  static const _peerMessages = [
    'Sector B clear. Moving to sector C.',
    'Medical supplies needed at grid 4-4.',
    'Road blocked: main bridge impassable.',
    'Found 3 survivors near the school.',
    'Water rising fast in the lower district.',
    'Generator fuel at 20%. Need resupply.',
    'Establishing relay point on hilltop.',
    'Requesting triage support — multiple injuries.',
  ];

  SimulatedMeshService(GatewayMonitor gatewayMonitor, this._securityService, Isar isar);

  @override
  String get deviceId => _securityService.deviceId;

  @override
  Stream<List<MeshDevice>> get devicesStream => _devicesSubject.stream;

  @override
  Stream<MeshPacket> get incomingPackets => _incomingPacketsSubject.stream;

  @override
  Stream<List<Peer>> get peersStream => Stream.value([]);

  @override
  List<MeshDevice> get currentDevices => _devicesSubject.value;

  @override
  Future<void> start() async {
    // Stagger initial node appearance to simulate real discovery
    for (int i = 0; i < _roster.length; i++) {
      final (id, name, isGateway, isConnected, rssi, battery) = _roster[i];
      Future.delayed(Duration(milliseconds: 600 * i), () {
        if (!_devicesSubject.isClosed) {
          _addNode(id, name, isGateway: isGateway, isConnected: isConnected,
              rssi: rssi, battery: battery);
        }
      });
    }

    // Signal fluctuations every 3s
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fluctuate();
    });

    // Simulate incoming peer messages every 8–15s
    _messageTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _simulateIncomingMessage();
    });

    // Occasional node join/leave after initial load
    _joinLeaveTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _simulateJoinLeave();
    });
  }

  void _addNode(String id, String name, {
    required bool isGateway,
    required bool isConnected,
    int rssi = -65,
    double battery = 0.7,
  }) {
    _simulatedDevices[id] = MeshDevice(
      deviceId: id,
      deviceName: name,
      status: isConnected ? MeshDeviceStatus.connected : MeshDeviceStatus.discovered,
      isGateway: isGateway,
      batteryLevel: battery,
      rssi: rssi,
      publicKey: 'SIM_PUBKEY_${id.hashCode.abs()}',
    );
    _push();
  }

  void _fluctuate() {
    for (final id in _simulatedDevices.keys.toList()) {
      final d = _simulatedDevices[id]!;
      final newRssi = (d.rssi! + (_random.nextInt(9) - 4)).clamp(-98, -30);
      final newBattery = ((d.batteryLevel ?? 0.7) - 0.001).clamp(0.05, 1.0);
      _simulatedDevices[id] = d.copyWith(rssi: newRssi, batteryLevel: newBattery);
    }
    _push();
  }

  void _simulateIncomingMessage() {
    final connected = _simulatedDevices.values
        .where((d) => d.isConnected)
        .toList();
    if (connected.isEmpty) return;

    final sender = connected[_random.nextInt(connected.length)];
    final msg = _peerMessages[_random.nextInt(_peerMessages.length)];

    final packet = MeshPacket(
      packetId: const Uuid().v4(),
      senderId: sender.deviceId,
      senderPublicKey: sender.publicKey ?? 'SIM_KEY',
      receiverId: null, // broadcast
      payload: msg,
      signature: 'SIM_SIGNATURE',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: 3,
      priority: PacketPriority.medium,
      latitude: 40.7128 + (_random.nextDouble() * 0.02 - 0.01),
      longitude: -74.0060 + (_random.nextDouble() * 0.02 - 0.01),
    );

    _incomingPacketsSubject.add(packet);
  }

  void _simulateJoinLeave() {
    // 40% chance: new node discovers itself
    if (_random.nextDouble() < 0.4 && _simulatedDevices.length < 12) {
      final suffix = _random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0').toUpperCase();
      final id = 'Node_$suffix';
      _addNode(id, 'Survivor-$suffix',
          isGateway: false, isConnected: false,
          rssi: -75 - _random.nextInt(20), battery: 0.2 + _random.nextDouble() * 0.5);
      return;
    }

    // 20% chance: discovered node connects
    final discovered = _simulatedDevices.values
        .where((d) => d.status == MeshDeviceStatus.discovered)
        .toList();
    if (discovered.isNotEmpty && _random.nextDouble() < 0.2) {
      final d = discovered[_random.nextInt(discovered.length)];
      _simulatedDevices[d.deviceId] = d.copyWith(status: MeshDeviceStatus.connected);
      _push();
    }
  }

  void _push() => _devicesSubject.add(_simulatedDevices.values.toList());

  @override
  Future<void> stop() async {
    _simulationTimer?.cancel();
    _messageTimer?.cancel();
    _joinLeaveTimer?.cancel();
    _simulatedDevices.clear();
    _push();
  }

  @override
  Future<void> connect(MeshDevice device) async {
    final existing = _simulatedDevices[device.deviceId];
    if (existing != null) {
      _simulatedDevices[device.deviceId] =
          existing.copyWith(status: MeshDeviceStatus.connected);
      _push();

      // Simulate the connected node sending a greeting message
      await Future.delayed(const Duration(milliseconds: 800));
      _incomingPacketsSubject.add(MeshPacket(
        packetId: const Uuid().v4(),
        senderId: device.deviceId,
        senderPublicKey: device.publicKey ?? 'SIM_KEY',
        receiverId: deviceId,
        payload: '[${existing.deviceName}] Connected. Standing by.',
        signature: 'SIM_SIGNATURE',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        ttl: 1,
        priority: PacketPriority.low,
        latitude: 0.0,
        longitude: 0.0,
      ));
    }
  }

  @override
  Future<void> reconnect(String deviceId) async {
    final existing = _simulatedDevices[deviceId];
    if (existing != null) {
      _simulatedDevices[deviceId] =
          existing.copyWith(status: MeshDeviceStatus.connected);
      _push();
    }
  }

  @override
  Future<void> sendPacket(MeshPacket packet) async {
    // Echo broadcast packets back after relay delay to show mesh propagation
    if (packet.receiverId == null && packet.payload != 'HEARTBEAT') {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!_incomingPacketsSubject.isClosed) {
        _incomingPacketsSubject.add(packet);
      }
    }
  }

  void dispose() {
    stop();
    _devicesSubject.close();
    _incomingPacketsSubject.close();
  }
}
