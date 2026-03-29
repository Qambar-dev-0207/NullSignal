abstract class AIService {
  /// Initializes the on-device AI model
  Future<void> initialize();

  /// Gets a triage scoring response based on user symptoms
  Future<String> getTriageResponse(String symptoms);

  /// Gets offline first-aid guidance for a specific injury/condition
  Future<String> getFirstAidGuidance(String condition);

  /// Closes the AI engine to free up resources
  Future<void> dispose();
}
