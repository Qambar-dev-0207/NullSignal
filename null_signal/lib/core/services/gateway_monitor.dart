import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

class GatewayMonitor {
  final Connectivity _connectivity = Connectivity();
  final BehaviorSubject<bool> _isGatewaySubject = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isGatewayStream => _isGatewaySubject.stream;
  bool get isGateway => _isGatewaySubject.value;

  StreamSubscription? _subscription;

  void start() {
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isOnline = results.any((result) => 
          result == ConnectivityResult.wifi || 
          result == ConnectivityResult.mobile || 
          result == ConnectivityResult.ethernet);
      _isGatewaySubject.add(isOnline);
    });
  }

  void stop() {
    _subscription?.cancel();
  }

  void dispose() {
    stop();
    _isGatewaySubject.close();
  }
}
