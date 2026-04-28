import 'dart:async';
import 'package:isar/isar.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/features/ai/domain/entities/sector_summary.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/domain/repositories/mesh_insight_service.dart';
import 'package:rxdart/rxdart.dart';

class MeshInsightServiceImpl implements MeshInsightService {
  final MeshService _meshService;
  final AIService _aiService;
  final Isar _isar;
  
  final _summariesSubject = BehaviorSubject<List<SectorSummary>>.seeded([]);
  StreamSubscription? _meshSubscription;
  Timer? _synthesisTimer;
  
  // Buffering packets for synthesis — capped per sector to prevent OOM
  final Map<String, List<MeshPacket>> _sectorBuffer = {};
  static const int _maxPacketsPerSector = 100;

  MeshInsightServiceImpl(this._meshService, this._aiService, this._isar);

  @override
  Stream<List<SectorSummary>> get sectorSummariesStream => _summariesSubject.stream;

  @override
  void start() {
    if (_meshSubscription != null) return; // idempotent
    _meshSubscription = _meshService.incomingPackets.listen(_onPacketReceived);
    _synthesisTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _runAutoSynthesis();
    });
    _loadStoredSummaries();
  }

  void _loadStoredSummaries() async {
    final summaries = await _isar.sectorSummarys.where().sortByTimestampDesc().findAll();
    _summariesSubject.add(summaries);
  }

  void _onPacketReceived(MeshPacket packet) {
    // Only buffer packets with relevant payloads (e.g. SOS, medical reports)
    // For now, we buffer everything with priority > medium
    if (packet.priority.index >= PacketPriority.medium.index) {
      final sectorId = _getSectorId(packet.latitude, packet.longitude);
      final bucket = _sectorBuffer.putIfAbsent(sectorId, () => []);
      bucket.add(packet);
      if (bucket.length > _maxPacketsPerSector) bucket.removeAt(0);
    }
  }

  String _getSectorId(double lat, double lon) {
    // Basic sectoring by rounding coordinates to 2 decimal places (~1.1km precision)
    final sLat = lat.toStringAsFixed(2);
    final sLon = lon.toStringAsFixed(2);
    return "SECTOR_${sLat}_$sLon";
  }

  Future<void> _runAutoSynthesis() async {
    for (final sectorId in _sectorBuffer.keys) {
      final packets = _sectorBuffer[sectorId];
      if (packets != null && packets.isNotEmpty) {
        final avgLat = packets.map((p) => p.latitude).reduce((a, b) => a + b) / packets.length;
        final avgLon = packets.map((p) => p.longitude).reduce((a, b) => a + b) / packets.length;
        
        await triggerSynthesis(lat: avgLat, lon: avgLon, sectorId: sectorId);
      }
    }
    _sectorBuffer.clear();
  }

  @override
  Future<void> triggerSynthesis({
    required double lat, 
    required double lon, 
    double radius = 1000,
    String? sectorId,
  }) async {
    final id = sectorId ?? _getSectorId(lat, lon);
    final packets = _sectorBuffer[id] ?? [];
    
    if (packets.isEmpty) {
      // If triggered manually, pull from Isar history
      final historicPackets = await _isar.meshPackets
        .filter()
        .latitudeBetween(lat - 0.01, lat + 0.01)
        .longitudeBetween(lon - 0.01, lon + 0.01)
        .findAll();
      packets.addAll(historicPackets);
    }
    
    if (packets.isEmpty) return;

    // Build prompt for Gemini Nano
    String reportList = packets.map((p) => "- [${p.priority.name}] ${p.payload}").join("\n");
    String prompt = """
    Synthesize these mesh network reports for $id into a concise Sector Summary.
    Identify total survivor count, urgent needs, and general status.
    
    Reports:
    $reportList
    
    Format the response strictly as:
    SUMMARY: [One sentence synthesis]
    SURVIVORS: [Estimated total]
    NEEDS: [Comma separated list of urgent needs]
    """;

    try {
      final response = await _aiService.chat(prompt);
      final summary = _parseResponse(response, id, lat, lon, radius);
      
      await _isar.writeTxn(() => _isar.sectorSummarys.put(summary));
      _loadStoredSummaries();
    } catch (e) {
      // Log error
    }
  }

  SectorSummary _parseResponse(String response, String sectorId, double lat, double lon, double radius) {
    final summaryMatch = RegExp(r"SUMMARY: (.*)").firstMatch(response);
    final survivorMatch = RegExp(r"SURVIVORS: (\d+)").firstMatch(response);
    final needsMatch = RegExp(r"NEEDS: (.*)").firstMatch(response);
    
    return SectorSummary(
      sectorId: sectorId,
      summary: summaryMatch?.group(1) ?? "Status synthesis in progress.",
      timestamp: DateTime.now().millisecondsSinceEpoch,
      centerLatitude: lat,
      centerLongitude: lon,
      radius: radius,
      survivorCount: int.tryParse(survivorMatch?.group(1) ?? "0") ?? 0,
      urgentNeeds: needsMatch?.group(1)?.split(",").map((e) => e.trim()).toList() ?? [],
    );
  }

  @override
  Future<List<SectorSummary>> getStoredSummaries() async {
    return await _isar.sectorSummarys.where().sortByTimestampDesc().findAll();
  }

  @override
  void stop() {
    _meshSubscription?.cancel();
    _synthesisTimer?.cancel();
  }
}
