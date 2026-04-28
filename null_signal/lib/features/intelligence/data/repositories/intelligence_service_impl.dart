import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/intelligence/domain/repositories/intelligence_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:cryptography/cryptography.dart';

import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class IntelligenceServiceImpl implements IntelligenceService {
  final MeshService _meshService;
  final GatewayMonitor _gatewayMonitor;
  final AIService _aiService;
  final SecurityService _securityService;
  static const double maxHazardRadiusKm = 10.0;

  // Streams
  final _polygonsSubject = BehaviorSubject<List<String>>.seeded([]);
  final _neighborCountSubject = BehaviorSubject<int>.seeded(0);
  final _crowdAlertsSubject = PublishSubject<String>();
  final _localGForceSubject = BehaviorSubject<double>.seeded(0.0);
  final _damageHeatmapSubject = BehaviorSubject<Map<String, double>>.seeded({});

  StreamSubscription? _meshSubscription;
  StreamSubscription? _accelerometerSubscription;
  Timer? _pollingTimer;
  Timer? _crowdTimer;
  
  final List<int> _crowdHistory = [];
  static const double seismicSpikeThreshold = 15.0;
  static const int _maxPolygons = 50;
  static const int _maxHeatmapEntries = 100;
  static const int _maxMatches = 50;
  DateTime _lastSeismicBroadcast = DateTime.fromMillisecondsSinceEpoch(0);

  IntelligenceServiceImpl(this._meshService, this._gatewayMonitor, this._aiService, this._securityService);

  @override
  Stream<List<String>> get hazardPolygonsStream => _polygonsSubject.stream;
  @override
  Stream<int> get neighborCountStream => _neighborCountSubject.stream;
  @override
  Stream<String> get crowdAlertsStream => _crowdAlertsSubject.stream;
  @override
  Stream<double> get localGForceStream => _localGForceSubject.stream;
  @override
  Stream<Map<String, double>> get damageHeatmapStream => _damageHeatmapSubject.stream;

  @override
  void start() {
    _meshSubscription = _meshService.incomingPackets.listen(_handleIncomingPacket);
    
    // Seismic Monitoring — debounce broadcasts to max 1 per 30s
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final gForce = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _localGForceSubject.add(gForce);
      if (gForce > seismicSpikeThreshold) {
        final now = DateTime.now();
        if (now.difference(_lastSeismicBroadcast).inSeconds >= 30) {
          _lastSeismicBroadcast = now;
          _broadcastSeismicEvent(gForce);
        }
      }
    });

    // Crowd Monitoring — 5 min interval; AI inference per call is expensive
    _crowdTimer = Timer.periodic(const Duration(minutes: 5), (_) => _checkCrowdDensity());

    // Hazard Polling
    _pollingTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      if (_gatewayMonitor.isGateway) {
        pollHazardData();
      }
    });
  }

  void _handleIncomingPacket(MeshPacket packet) async {
    switch (packet.packetType) {
      case PacketType.hazardMap:
        try {
          final position = await Geolocator.getCurrentPosition();
          final distance = const Distance().as(
            LengthUnit.Kilometer,
            LatLng(position.latitude, position.longitude),
            LatLng(packet.latitude, packet.longitude),
          );

          if (distance <= maxHazardRadiusKm) {
            final current = _polygonsSubject.value;
            if (!current.contains(packet.payload)) {
              final updated = [...current, packet.payload];
              _polygonsSubject.add(updated.length > _maxPolygons ? updated.sublist(updated.length - _maxPolygons) : updated);
            }
          }
        } catch (_) {
          final current = _polygonsSubject.value;
          if (!current.contains(packet.payload)) {
            final updated = [...current, packet.payload];
            _polygonsSubject.add(updated.length > _maxPolygons ? updated.sublist(updated.length - _maxPolygons) : updated);
          }
        }
        break;
      case PacketType.crowdAlert:
        _crowdAlertsSubject.add(packet.payload);
        break;
      case PacketType.seismicEvent:
        if (packet.payload.startsWith('SEISMIC_MAGNITUDE:')) {
          final magStr = packet.payload.substring('SEISMIC_MAGNITUDE:'.length);
          final magnitude = double.tryParse(magStr) ?? 0.0;
          final current = Map<String, double>.from(_damageHeatmapSubject.value);
          current[packet.senderId] = magnitude;
          if (current.length > _maxHeatmapEntries) {
            final oldest = current.keys.first;
            current.remove(oldest);
          }
          _damageHeatmapSubject.add(current);
        }
        break;
      default:
        break;
    }
  }

  // --- Hazard Methods ---
  @override
  Future<void> pollHazardData() async => await injectMockHazard();

  @override
  Future<void> injectMockHazard() async {
    const mockGeoJson = '{"type":"Feature","properties":{"hazard":"FLOOD"},"geometry":{"type":"Polygon","coordinates":[[[-118.25,34.05],[-118.24,34.05],[-118.24,34.06],[-118.25,34.06],[-118.25,34.05]]]}}';
    await _broadcastPacket(PacketType.hazardMap, mockGeoJson, PacketPriority.high);
    final updated = [..._polygonsSubject.value, mockGeoJson];
    _polygonsSubject.add(updated.length > _maxPolygons ? updated.sublist(updated.length - _maxPolygons) : updated);
  }

  // --- Crowd Methods ---
  void _checkCrowdDensity() async {
    final count = _meshService.currentDevices.length;
    _neighborCountSubject.add(count);
    _crowdHistory.add(count);
    if (_crowdHistory.length > 10) _crowdHistory.removeAt(0);

    if (count > 5) {
      double rate = _crowdHistory.length >= 2 ? (count - _crowdHistory[_crowdHistory.length - 2]) / 30.0 : 0;
      if (rate > 0.1 || count > 10) {
        final analysis = await _aiService.chat("Analyze risk: Count $count, Rate $rate. High risk of crush?");
        if (analysis.contains('RISK') || analysis.contains('DANGER')) {
          await _broadcastPacket(PacketType.crowdAlert, analysis, PacketPriority.critical);
          _crowdAlertsSubject.add(analysis);
        }
      }
    }
  }

  // --- Seismic Methods ---
  void _broadcastSeismicEvent(double magnitude) async {
    await _broadcastPacket(PacketType.seismicEvent, 'SEISMIC_MAGNITUDE:$magnitude', PacketPriority.high);
  }

  // --- Helper ---
  Future<void> _broadcastPacket(PacketType type, String payload, PacketPriority priority) async {
    final keyPair = await _securityService.getOrCreateIdentity();
    final signature = await _securityService.sign(payload, keyPair);
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBase64 = base64.encode((publicKey as SimplePublicKey).bytes);

    final packet = MeshPacket(
      packetId: const Uuid().v4(),
      senderId: _meshService.deviceId,
      senderPublicKey: publicKeyBase64,
      packetType: type,
      payload: payload,
      signature: signature,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: 4,
      priority: priority,
      latitude: 0.0,
      longitude: 0.0,
    );
    await _meshService.sendPacket(packet);
  }

  @override
  void stop() {
    _meshSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _pollingTimer?.cancel();
    _crowdTimer?.cancel();
  }
}
