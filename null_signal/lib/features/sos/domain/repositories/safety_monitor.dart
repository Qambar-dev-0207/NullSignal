import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SafetyMonitor {
  /// Threshold for motion detection (low sensitivity)
  final double motionThreshold = 0.1;
  
  /// Inactivity timeout before SOS (default 8 mins)
  final Duration inactivityLimit = const Duration(minutes: 8);

  Timer? _inactivityTimer;
  StreamSubscription? _sensorSubscription;

  /// Stream to notify the UI that a safety check-in is required
  final _onCheckInRequired = StreamController<bool>.broadcast();
  Stream<bool> get onCheckInRequired => _onCheckInRequired.stream;

  /// Stream to notify the system to broadcast Auto-SOS
  final _onAutoSosTriggered = StreamController<void>.broadcast();
  Stream<void> get onAutoSosTriggered => _onAutoSosTriggered.stream;

  void start() {
    _resetTimer();
    _sensorSubscription = accelerometerEventStream().listen((event) {
      // If any axis shows significant movement, reset the timer
      if (event.x.abs() > motionThreshold || 
          event.y.abs() > motionThreshold || 
          event.z.abs() > motionThreshold) {
        _resetTimer();
      }
    });
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityLimit, () {
      _onCheckInRequired.add(true);
      // Wait another 30s for manual dismissal before triggering Auto-SOS
      Timer(const Duration(seconds: 30), () {
        _onAutoSosTriggered.add(null);
      });
    });
  }

  void userConfirmedSafe() {
    _resetTimer();
    _onCheckInRequired.add(false);
  }

  void stop() {
    _inactivityTimer?.cancel();
    _sensorSubscription?.cancel();
  }

  void dispose() {
    stop();
    _onCheckInRequired.close();
    _onAutoSosTriggered.close();
  }
}
