import 'dart:async';
import 'dart:math';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:rxdart/rxdart.dart';

class SimulatedMeshService implements MeshService {
  final GatewayMonitor _gatewayMonitor;
  final SecurityService _securityService;
  final _random = Random();
  final BehaviorSubject<List<MeshDevice>> _devicesSubject = BehaviorSubject<List<MeshDevice>>.seeded([]);
  final PublishSubject<MeshPacket> _incomingPacketsSubject = PublishSubject<MeshPacket>();
  
  Timer? _simulationTimer;
  final Map<String, MeshDevice> _simulatedDevices = {};

  SimulatedMeshService(this._gatewayMonitor, this._securityService);

  @override
  String get deviceId => "LOCAL_NODE_HOST";

  @override
  Stream<List<MeshDevice>> get devicesStream => _devicesSubject.stream;

  @override
  Stream<MeshPacket> get incomingPackets => _incomingPacketsSubject.stream;

  @override
  List<MeshDevice> get currentDevices => _devicesSubject.value;

  @override
  Future<void> start() async {
    // Initial known peers
    _addSimulatedDevice('AX-209', 'Mobile Node', isGateway: false, isConnected: true);
    _addSimulatedDevice('RT-442', 'Relay Tower', isGateway: true, isConnected: true);
    
    _updateDevices();

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _simulateFluctuations();
      
      // Randomly "discover" a new scanned device
      if (_random.nextDouble() > 0.7 && _simulatedDevices.length < 10) {
        final id = "NODE_0x${_random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0').toUpperCase()}";
        _addSimulatedDevice(id, 'Scanned Device', isGateway: false, isConnected: false);
      }
    });
  }

  void _addSimulatedDevice(String id, String name, {required bool isGateway, required bool isConnected}) {
    _simulatedDevices[id] = MeshDevice(
      deviceId: id,
      deviceName: name,
      status: isConnected ? MeshDeviceStatus.connected : MeshDeviceStatus.discovered,
      isGateway: isGateway,
      batteryLevel: 0.5 + (_random.nextDouble() * 0.5),
      rssi: -50 - _random.nextInt(40),
    );
    _updateDevices();
  }

  void _simulateFluctuations() {
    for (final id in _simulatedDevices.keys) {
      final device = _simulatedDevices[id]!;
      int newRssi = device.rssi! + (_random.nextInt(7) - 3);
      newRssi = newRssi.clamp(-100, -30);
      
      _simulatedDevices[id] = device.copyWith(rssi: newRssi);
    }
    _updateDevices();
  }

  void _updateDevices() {
    _devicesSubject.add(_simulatedDevices.values.toList());
  }

  @override
  Future<void> stop() async {
    _simulationTimer?.cancel();
    _simulatedDevices.clear();
    _updateDevices();
  }

  @override
  Future<void> connect(MeshDevice device) async {
    final existing = _simulatedDevices[device.deviceId];
    if (existing != null) {
      _simulatedDevices[device.deviceId] = existing.copyWith(status: MeshDeviceStatus.connected);
      _updateDevices();
    }
  }

  @override
  Future<void> reconnect(String deviceId) async {
    final existing = _simulatedDevices[deviceId];
    if (existing != null) {
      _simulatedDevices[deviceId] = existing.copyWith(status: MeshDeviceStatus.connected);
      _updateDevices();
    }
  }

  @override
  Future<void> sendPacket(MeshPacket packet) async {
    // Simulate broadcasting by adding it to incoming packets after a delay
    // as if it were echoed back or received by others.
    Future.delayed(const Duration(milliseconds: 500), () {
      _incomingPacketsSubject.add(packet);
    });
  }

  void dispose() {
    stop();
    _devicesSubject.close();
    _incomingPacketsSubject.close();
  }
}
