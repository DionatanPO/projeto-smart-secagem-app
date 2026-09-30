import 'dart:convert';

class TelemetryModel {
  final int? id;
  final int sensorId;
  final String sensorPhysicalId;
  final double temperature;
  final double humidity;
  final double? co2Ppm;
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
    this.co2Ppm,
    this.gasLevel,
    this.vibration,
    required this.timestamp,
    this.receivedAt,
  });

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    double? gasLevel;
    double? vibration;

    final dadosExtras = json['dados_extras'];
    Map<String, dynamic> extras = {};
    if (dadosExtras != null) {
      if (dadosExtras is Map) {
        extras = dadosExtras.cast<String, dynamic>();
      } else if (dadosExtras is String) {
        extras = (jsonDecode(dadosExtras) as Map).cast<String, dynamic>();
      }
      gasLevel = (extras['nivel_gas'] as num?)?.toDouble();
      vibration = (extras['vibracao'] as num?)?.toDouble();
    }

    return TelemetryModel(
      id: json['id'],
      sensorId: json['sensor'] ?? 0,
      sensorPhysicalId: json['sensor_physical_id'] ?? '',
      // Sensores só de umidade (externa) podem postar sem temperatura e vice-versa.
      temperature: (json['temperatura'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['umidade'] as num?)?.toDouble() ?? 0.0,
      // CO₂ tem campo próprio na API; aceita legado em dados_extras.
      co2Ppm: (json['co2_ppm'] as num?)?.toDouble() ??
          (extras['co2_ppm'] as num?)?.toDouble() ??
          (extras['co2'] as num?)?.toDouble(),
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
      if (co2Ppm != null) 'co2_ppm': co2Ppm,
      'dados_extras': extras,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
