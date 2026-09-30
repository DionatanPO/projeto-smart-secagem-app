class SensorModel {
  static const String tipoTemperatura = 'sensor_temperatura';
  static const String tipoMancal = 'sensor_mancal';
  static const String tipoAbafando = 'sensor_abafando';

  // Tipos da automação de secadores (plenum, massa, exaustão, fornalha, ambiente)
  // Temperatura e umidade externas podem vir de sensores separados.
  static const String tipoPlenum = 'plenum';
  static const String tipoMassaGraos = 'massa_graos';
  static const String tipoPpp = 'ppp';
  static const String tipoExaustao = 'exaustao';
  static const String tipoFornalha = 'fornalha';
  static const String tipoAmbiente = 'ambiente';
  static const String tipoEstacao = 'estacao_meteorologica';
  static const String tipoUmidade = 'sensor_umidade';
  static const String tipoCo2 = 'sensor_co2';

  static const List<String> tiposIncendio = [tipoMancal, tipoAbafando];
  static const List<String> tiposAmbiente = [tipoAmbiente, tipoEstacao];

  static String tipoLabel(String tipo) {
    switch (tipo) {
      case tipoMancal:
        return 'Mancal';
      case tipoAbafando:
        return 'Abafamento';
      case tipoPlenum:
        return 'Plenum';
      case tipoMassaGraos:
        return 'Massa de grãos';
      case tipoPpp:
        return 'PPP';
      case tipoExaustao:
        return 'Exaustão';
      case tipoFornalha:
        return 'Fornalha';
      case tipoAmbiente:
      case tipoEstacao:
        return 'Ambiente';
      case tipoUmidade:
        return 'Umidade';
      case tipoCo2:
        return 'CO₂';
      default:
        return 'Temperatura';
    }
  }

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

  bool get isFireSensor => tiposIncendio.contains(tipo);

  /// Sensor de unidade (estação meteorológica): sem silo/secador, só unidade.
  bool get isAmbiente =>
      tiposAmbiente.contains(tipo) && siloId == null && secadorId == null;

  SensorModel({
    this.id,
    required this.sensorId,
    this.tipo = tipoTemperatura,
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
      tipo: json['tipo'] ?? tipoTemperatura,
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
