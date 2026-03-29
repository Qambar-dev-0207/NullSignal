import 'package:vibration/vibration.dart';

class FeedbackService {
  /// Provides Morse SOS vibration pattern (... --- ...)
  static Future<void> triggerSosHaptics() async {
    if (await Vibration.hasVibrator()) {
      // S (...) O (---) S (...) in milliseconds
      Vibration.vibrate(pattern: [
        100, 200, 100, 200, 100, 200, // S
        400, 600, 400, 600, 400, 600, // O
        100, 200, 100, 200, 100, 200, // S
      ]);
    }
  }

  /// Single short pulse for generic confirmation
  static Future<void> triggerConfirmation() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100);
    }
  }

  /// Double pulse for status change
  static Future<void> triggerDoublePulse() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 100, 100, 100]);
    }
  }
}
