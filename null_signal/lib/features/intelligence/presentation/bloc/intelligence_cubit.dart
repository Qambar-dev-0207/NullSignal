import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/features/intelligence/domain/repositories/intelligence_service.dart';

class IntelligenceState {
  final List<String> hazardPolygons;
  final int neighborCount;
  final String? latestCrowdAlert;
  final double localGForce;
  final Map<String, double> damageHeatmap;

  IntelligenceState({
    this.hazardPolygons = const [],
    this.neighborCount = 0,
    this.latestCrowdAlert,
    this.localGForce = 0.0,
    this.damageHeatmap = const {},
  });

  IntelligenceState copyWith({
    List<String>? hazardPolygons,
    int? neighborCount,
    String? latestCrowdAlert,
    double? localGForce,
    Map<String, double>? damageHeatmap,
  }) {
    return IntelligenceState(
      hazardPolygons: hazardPolygons ?? this.hazardPolygons,
      neighborCount: neighborCount ?? this.neighborCount,
      latestCrowdAlert: latestCrowdAlert ?? this.latestCrowdAlert,
      localGForce: localGForce ?? this.localGForce,
      damageHeatmap: damageHeatmap ?? this.damageHeatmap,
    );
  }
}

class IntelligenceCubit extends Cubit<IntelligenceState> {
  final IntelligenceService _service;
  final List<StreamSubscription> _subscriptions = [];

  IntelligenceCubit(this._service) : super(IntelligenceState());

  void initialize() {
    _service.start();
    
    _subscriptions.add(_service.hazardPolygonsStream.listen((polygons) {
      emit(state.copyWith(hazardPolygons: polygons));
    }));

    _subscriptions.add(_service.neighborCountStream.listen((count) {
      emit(state.copyWith(neighborCount: count));
    }));

    _subscriptions.add(_service.crowdAlertsStream.listen((alert) {
      emit(state.copyWith(latestCrowdAlert: alert));
    }));

    _subscriptions.add(_service.localGForceStream.listen((g) {
      emit(state.copyWith(localGForce: g));
    }));

    _subscriptions.add(_service.damageHeatmapStream.listen((heatmap) {
      emit(state.copyWith(damageHeatmap: heatmap));
    }));
  }

  void triggerMockHazard() => _service.injectMockHazard();

  @override
  Future<void> close() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _service.stop();
    return super.close();
  }
}
