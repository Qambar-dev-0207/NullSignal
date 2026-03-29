import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';

class MeshState {
  final List<MeshDevice> devices;
  final bool isScanning;

  MeshState({required this.devices, required this.isScanning});

  int get connectedNodeCount => devices.where((d) => d.isConnected).length;
}

class MeshCubit extends Cubit<MeshState> {
  final MeshService _meshService;
  StreamSubscription? _deviceSubscription;

  MeshCubit(this._meshService) : super(MeshState(devices: [], isScanning: false));

  void startScanning() async {
    emit(MeshState(devices: state.devices, isScanning: true));
    await _meshService.start();
    _deviceSubscription = _meshService.devicesStream.listen((devices) {
      emit(MeshState(devices: devices, isScanning: true));
    });
  }

  void stopScanning() async {
    await _deviceSubscription?.cancel();
    await _meshService.stop();
    emit(MeshState(devices: [], isScanning: false));
  }

  @override
  Future<void> close() {
    _deviceSubscription?.cancel();
    return super.close();
  }
}
