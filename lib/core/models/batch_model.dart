class BatchModel {
  int? id;
  String numeroLote;
  int farm;
  String? farmName;
  String cultura;
  String? variedade;
  String safra;
  double pesoInicial;
  double umidadeInicial;
  DateTime? dataEntrada;
  double? pesoFinal;
  double? umidadeFinal;
  DateTime? dataSaida;
  int? silo;
  String? siloName;
  String status;
  String? observacoes;

  BatchModel({
    this.id,
    required this.numeroLote,
    required this.farm,
    this.farmName,
    required this.cultura,
    this.variedade,
    required this.safra,
    required this.pesoInicial,
    required this.umidadeInicial,
    this.dataEntrada,
    this.pesoFinal,
    this.umidadeFinal,
    this.dataSaida,
    this.silo,
    this.siloName,
    required this.status,
    this.observacoes,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'],
      numeroLote: json['numero_lote'],
      farm: json['farm'],
      farmName: json['farm_name'],
      cultura: json['cultura'],
      variedade: json['variedade'],
      safra: json['safra'],
      pesoInicial: (json['peso_inicial'] as num).toDouble(),
      umidadeInicial: (json['umidade_inicial'] as num).toDouble(),
      dataEntrada: json['data_entrada'] != null ? DateTime.parse(json['data_entrada']) : null,
      pesoFinal: json['peso_final'] != null ? (json['peso_final'] as num).toDouble() : null,
      umidadeFinal: json['umidade_final'] != null ? (json['umidade_final'] as num).toDouble() : null,
      dataSaida: json['data_saida'] != null ? DateTime.parse(json['data_saida']) : null,
      silo: json['silo'],
      siloName: json['silo_name'],
      status: json['status'],
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_lote': numeroLote,
      'farm': farm,
      'cultura': cultura,
      'variedade': variedade,
      'safra': safra,
      'peso_inicial': pesoInicial,
      'umidade_inicial': umidadeInicial,
      'peso_final': pesoFinal,
      'umidade_final': umidadeFinal,
      'data_saida': dataSaida?.toIso8601String(),
      'silo': silo,
      'status': status,
      'observacoes': observacoes,
    };
  }
}
