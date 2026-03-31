enum MeshDeviceStatus {
  discovered,
  connecting,
  connected,
  disconnected
}

class MeshDevice {
  final String deviceId;
  final String deviceName;
  final MeshDeviceStatus status;
  final double? batteryLevel;
  final int? rssi; // Signal Strength
  final bool isGateway;
  final String? publicKey; // Base64 encoded public key

  MeshDevice({
    required this.deviceId,
    required this.deviceName,
    required this.status,
    this.batteryLevel,
    this.rssi,
    this.isGateway = false,
    this.publicKey,
  });

  bool get isConnected => status == MeshDeviceStatus.connected;

  MeshDevice copyWith({
    String? deviceId,
    String? deviceName,
    MeshDeviceStatus? status,
    double? batteryLevel,
    int? rssi,
    bool? isGateway,
    String? publicKey,
  }) {
    return MeshDevice(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      rssi: rssi ?? this.rssi,
      isGateway: isGateway ?? this.isGateway,
      publicKey: publicKey ?? this.publicKey,
    );
  }
}
