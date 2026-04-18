import 'package:null_signal/features/ai/domain/entities/sector_summary.dart';

abstract class MeshInsightService {
  /// Start monitoring the mesh for insights
  void start();

  /// Stop monitoring
  void stop();

  /// Stream of generated sector summaries
  Stream<List<SectorSummary>> get sectorSummariesStream;

  /// Trigger immediate synthesis for a specific area
  Future<void> triggerSynthesis({required double lat, required double lon, double radius = 1000});
  
  /// Get all currently stored summaries
  Future<List<SectorSummary>> getStoredSummaries();
}
