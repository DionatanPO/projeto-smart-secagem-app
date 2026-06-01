class SensorModel {
  final int? id;
  final String sensorId;
  final String tipo;
  final int? siloId;
  final int? secadorId;
  final int? unidadeArmazenadoraId;
  final String description;
  final String status;
  final String? siloName;
  final String? secadorName;
  final String? unidadeArmazenadoraNome;

  SensorModel({
    this.id,
    required this.sensorId,
    this.tipo = 'sensor_temperatura',
    this.siloId,
    this.secadorId,
    this.unidadeArmazenadoraId,
    required this.description,
    required this.status,
    this.siloName,
    this.secadorName,
    this.unidadeArmazenadoraNome,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'],
      sensorId: json['sensor_id'],
      tipo: json['tipo'] ?? 'sensor_temperatura',
      siloId: json['silo'],
      secadorId: json['secador'],
      unidadeArmazenadoraId: json['unidade_armazenadora'],
      description: json['description'],
      status: json['status'],
      siloName: json['silo_name'],
      secadorName: json['secador_name'],
      unidadeArmazenadoraNome: json['unidade_armazenadora_nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sensor_id': sensorId,
      'tipo': tipo,
      'silo': siloId,
      'secador': secadorId,
      'unidade_armazenadora': unidadeArmazenadoraId,
      'description': description,
      'status': status,
    };
  }
}
