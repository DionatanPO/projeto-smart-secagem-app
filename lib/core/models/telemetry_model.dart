class TelemetryModel {
  final int? id;
  final String sensorPhysicalId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final DateTime? receivedAt;

  TelemetryModel({
    this.id,
    required this.sensorPhysicalId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    this.receivedAt,
  });

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryModel(
      id: json['id'],
      sensorPhysicalId: json['sensor_physical_id'] ?? '',
      temperature: (json['temperatura'] as num).toDouble(),
      humidity: (json['umidade'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      receivedAt: json['received_at'] != null ? DateTime.parse(json['received_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensor_physical_id': sensorPhysicalId,
      'temperatura': temperature,
      'umidade': humidity,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
