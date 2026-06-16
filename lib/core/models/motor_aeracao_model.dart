class MotorAeracaoModel {
  final int? id;
  final String motorId;
  final String description;
  final String status;
  final String estado;
  final double? potenciaKW;
  final double? rpm;
  final double? vazaoAr;
  final double? horimetro;
  final double? consumoAtualKW;
  final int? siloId;
  final int? secadorId;
  final String? siloName;
  final String? secadorName;

  MotorAeracaoModel({
    this.id,
    required this.motorId,
    required this.description,
    this.status = 'ativo',
    this.estado = 'desligado',
    this.potenciaKW,
    this.rpm,
    this.vazaoAr,
    this.horimetro,
    this.consumoAtualKW,
    this.siloId,
    this.secadorId,
    this.siloName,
    this.secadorName,
  });

  factory MotorAeracaoModel.fromJson(Map<String, dynamic> json) {
    return MotorAeracaoModel(
      id: json['id'],
      motorId: json['motor_id'],
      description: json['description'] ?? '',
      status: json['status'] ?? 'ativo',
      estado: json['estado'] ?? 'desligado',
      potenciaKW: (json['potencia_kw'] as num?)?.toDouble(),
      rpm: (json['rpm'] as num?)?.toDouble(),
      vazaoAr: (json['vazao_ar'] as num?)?.toDouble(),
      horimetro: (json['horimetro'] as num?)?.toDouble(),
      consumoAtualKW: (json['consumo_atual_kw'] as num?)?.toDouble(),
      siloId: json['silo'],
      secadorId: json['secador'],
      siloName: json['silo_name'],
      secadorName: json['secador_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'motor_id': motorId,
      'description': description,
      'status': status,
      'estado': estado,
      'potencia_kw': potenciaKW,
      'rpm': rpm,
      'vazao_ar': vazaoAr,
      'horimetro': horimetro,
      'consumo_atual_kw': consumoAtualKW,
      'silo': siloId,
      'secador': secadorId,
    };
  }

  MotorAeracaoModel copyWith({
    int? id,
    String? motorId,
    String? description,
    String? status,
    String? estado,
    double? potenciaKW,
    double? rpm,
    double? vazaoAr,
    double? horimetro,
    double? consumoAtualKW,
    int? siloId,
    int? secadorId,
    String? siloName,
    String? secadorName,
  }) {
    return MotorAeracaoModel(
      id: id ?? this.id,
      motorId: motorId ?? this.motorId,
      description: description ?? this.description,
      status: status ?? this.status,
      estado: estado ?? this.estado,
      potenciaKW: potenciaKW ?? this.potenciaKW,
      rpm: rpm ?? this.rpm,
      vazaoAr: vazaoAr ?? this.vazaoAr,
      horimetro: horimetro ?? this.horimetro,
      consumoAtualKW: consumoAtualKW ?? this.consumoAtualKW,
      siloId: siloId ?? this.siloId,
      secadorId: secadorId ?? this.secadorId,
      siloName: siloName ?? this.siloName,
      secadorName: secadorName ?? this.secadorName,
    );
  }
}
