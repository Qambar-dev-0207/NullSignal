abstract class IntelligenceService {
  void start();
  void stop();

  // Hazard Maps
  Stream<List<String>> get hazardPolygonsStream;
  Future<void> pollHazardData();
  Future<void> injectMockHazard();

  // Crowd Monitoring
  Stream<int> get neighborCountStream;
  Stream<String> get crowdAlertsStream;

  // Seismic Monitoring
  Stream<double> get localGForceStream;
  Stream<Map<String, double>> get damageHeatmapStream;
}
