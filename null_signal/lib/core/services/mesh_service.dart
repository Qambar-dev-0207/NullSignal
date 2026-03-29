import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';

abstract class MeshService {
  /// Unique identifier for this device in the mesh
  String get deviceId;

  /// Stream of all discovered and connected devices
  Stream<List<MeshDevice>> get devicesStream;
  
  /// Stream of incoming packets from the mesh
  Stream<MeshPacket> get incomingPackets;
  
  /// Start advertising and discovery
  Future<void> start();
  
  /// Stop all mesh activity
  Future<void> stop();
  
  /// Initiate connection to a specific device
  Future<void> connect(MeshDevice device);
  
  /// Send a packet to the mesh (broadcast or targeted)
  Future<void> sendPacket(MeshPacket packet);
  
  /// Current list of known devices
  List<MeshDevice> get currentDevices;
}
