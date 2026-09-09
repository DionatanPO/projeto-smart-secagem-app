import 'dart:convert';

class TelemetryModel {
  final int? id;
  final int sensorId;
  final String sensorPhysicalId;
  final double temperature;
  final double humidity;
  final double? gasLevel;
  final double? vibration;
  final DateTime timestamp;
  final DateTime? receivedAt;

  TelemetryModel({
    this.id,
    required this.sensorId,
    required this.sensorPhysicalId,
    required this.temperature,
    required this.humidity,
    this.gasLevel,
    this.vibration,
    required this.timestamp,
    this.receivedAt,
  });

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    double? gasLevel;
    double? vibration;

    final dadosExtras = json['dados_extras'];
    if (dadosExtras != null) {
      Map<String, dynamic> extras;
      if (dadosExtras is Map) {
        extras = dadosExtras.cast<String, dynamic>();
      } else if (dadosExtras is String) {
        extras = (jsonDecode(dadosExtras) as Map).cast<String, dynamic>();
      } else {
        extras = {};
      }
      gasLevel = (extras['nivel_gas'] as num?)?.toDouble();
      vibration = (extras['vibracao'] as num?)?.toDouble();
    }

    return TelemetryModel(
      id: json['id'],
      sensorId: json['sensor'] ?? 0,
      sensorPhysicalId: json['sensor_physical_id'] ?? '',
      temperature: (json['temperatura'] as num).toDouble(),
      humidity: (json['umidade'] as num).toDouble(),
      gasLevel: gasLevel ?? (json['nivel_gas'] as num?)?.toDouble(),
      vibration: vibration ?? (json['vibracao'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      receivedAt: json['received_at'] != null ? DateTime.parse(json['received_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final extras = <String, dynamic>{};
    if (gasLevel != null) extras['nivel_gas'] = gasLevel;
    if (vibration != null) extras['vibracao'] = vibration;

    return {
      'sensor': sensorId,
      'sensor_physical_id': sensorPhysicalId,
      'temperatura': temperature,
      'umidade': humidity,
      'dados_extras': extras,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
