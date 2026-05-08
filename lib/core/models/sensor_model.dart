class SensorModel {
  final int? id;
  final String sensorId;
  final String tipo;
  final int? siloId;
  final int? secadorId;
  final int? farmId;
  final String description;
  final String status;
  final String? siloName;
  final String? secadorName;
  final String? farmName;

  SensorModel({
    this.id,
    required this.sensorId,
    this.tipo = 'sensor_temperatura',
    this.siloId,
    this.secadorId,
    this.farmId,
    required this.description,
    required this.status,
    this.siloName,
    this.secadorName,
    this.farmName,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'],
      sensorId: json['sensor_id'],
      tipo: json['tipo'] ?? 'sensor_temperatura',
      siloId: json['silo'],
      secadorId: json['secador'],
      farmId: json['farm'],
      description: json['description'],
      status: json['status'],
      siloName: json['silo_name'],
      secadorName: json['secador_name'],
      farmName: json['farm_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sensor_id': sensorId,
      'tipo': tipo,
      'silo': siloId,
      'secador': secadorId,
      'farm': farmId,
      'description': description,
      'status': status,
    };
  }
}
