import 'dart:async';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/models/resource_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:cryptography/cryptography.dart';

class ResourceBrokerService {
  final MeshService _meshService;
  final SecurityService _securityService;
  static const int _maxMatches = 50;

  final _matchesSubject = BehaviorSubject<List<ResourceMatch>>.seeded([]);
  StreamSubscription? _meshSubscription;

  ResourceBrokerService(this._meshService, AIService aiService, Isar isar, this._securityService);

  Stream<List<ResourceMatch>> get matchesStream => _matchesSubject.stream;
  
  void start() {
    _meshSubscription = _meshService.incomingPackets.listen(_onPacketReceived);
  }

  void _onPacketReceived(MeshPacket packet) async {
    if (packet.payload.startsWith('RESOURCE_EXCHANGE:')) {
      final jsonStr = packet.payload.substring('RESOURCE_EXCHANGE:'.length);
      try {
        final payload = ResourceExchangePayload.fromJson(jsonDecode(jsonStr));
        await _checkForMatches(payload, packet.senderId);
      } catch (_) {}
    }
  }

  Future<void> broadcastOffer(String name, String desc, ResourceCategory category, int quantity) async {
    final payload = ResourceExchangePayload(
      resourceName: name,
      description: desc,
      type: ResourceType.offer,
      quantity: quantity,
      category: category,
    );
    await _sendResourcePacket(payload);
  }

  Future<void> broadcastNeed(String name, String desc, ResourceCategory category, int quantity) async {
    final payload = ResourceExchangePayload(
      resourceName: name,
      description: desc,
      type: ResourceType.need,
      quantity: quantity,
      category: category,
    );
    await _sendResourcePacket(payload);
  }

  Future<void> _sendResourcePacket(ResourceExchangePayload payload) async {
    final packetId = const Uuid().v4();
    final jsonStr = jsonEncode(payload.toJson());
    final fullPayload = 'RESOURCE_EXCHANGE:$jsonStr';
    
    final keyPair = await _securityService.getOrCreateIdentity();
    final signature = await _securityService.sign(fullPayload, keyPair);
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBase64 = base64.encode((publicKey as SimplePublicKey).bytes);

    final packet = MeshPacket(
      packetId: packetId,
      senderId: _meshService.deviceId,
      senderPublicKey: publicKeyBase64,
      payload: fullPayload,
      signature: signature,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: 3,
      priority: PacketPriority.medium,
      latitude: 0.0,
      longitude: 0.0,
    );
    
    await _meshService.sendPacket(packet);
  }

  Future<void> _checkForMatches(ResourceExchangePayload incoming, String remoteId) async {
    // For simulation, we assume on-device AI matches categories
    // In production, Gemini Nano would do semantic matching
    
    // Mocking a match for simulation
    if (incoming.resourceName.toLowerCase().contains('insulin') || incoming.resourceName.toLowerCase().contains('medical')) {
       final match = ResourceMatch(
         resourceName: incoming.resourceName,
         peerId: remoteId,
         timestamp: DateTime.now().millisecondsSinceEpoch,
         matchConfidence: 0.95,
         swapPoint: 'Sector A Safe Zone',
       );
       final current = _matchesSubject.value;
       final updated = [...current, match];
       _matchesSubject.add(updated.length > _maxMatches ? updated.sublist(updated.length - _maxMatches) : updated);
    }
  }

  void stop() {
    _meshSubscription?.cancel();
  }
}

class ResourceMatch {
  final String resourceName;
  final String peerId;
  final int timestamp;
  final double matchConfidence;
  final String swapPoint;

  ResourceMatch({
    required this.resourceName,
    required this.peerId,
    required this.timestamp,
    required this.matchConfidence,
    required this.swapPoint,
  });
}
