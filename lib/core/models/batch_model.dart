class BatchModel {
  int? id;
  String? numeroLote;
  int unidadeArmazenadora;
  String? unidadeArmazenadoraNome;
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
  int? cliente;
  String? clienteNome;
  String status;
  String? observacoes;
  String? placaCaminhao;
  String? motoristaNome;
  double? pesoCaminhao;

  BatchModel({
    this.id,
    this.numeroLote,
    required this.unidadeArmazenadora,
    this.unidadeArmazenadoraNome,
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
    this.cliente,
    this.clienteNome,
    required this.status,
    this.observacoes,
    this.placaCaminhao,
    this.motoristaNome,
    this.pesoCaminhao,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'],
      numeroLote: json['numero_lote'],
      unidadeArmazenadora: json['unidade_armazenadora'],
      unidadeArmazenadoraNome: json['unidade_armazenadora_nome'],
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
      cliente: json['cliente'],
      clienteNome: json['cliente_nome'],
      status: json['status'],
      observacoes: json['observacoes'],
      placaCaminhao: json['placa_caminhao'],
      motoristaNome: json['motorista_nome'],
      pesoCaminhao: json['peso_caminhao'] != null ? (json['peso_caminhao'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_lote': numeroLote,
      'unidade_armazenadora': unidadeArmazenadora,
      'cultura': cultura,
      'variedade': variedade,
      'safra': safra,
      'peso_inicial': pesoInicial,
      'umidade_inicial': umidadeInicial,
      'peso_final': pesoFinal,
      'umidade_final': umidadeFinal,
      'data_saida': dataSaida?.toIso8601String(),
      'silo': silo,
      'cliente': cliente,
      'status': status,
      'observacoes': observacoes,
      'placa_caminhao': placaCaminhao,
      'motorista_nome': motoristaNome,
      'peso_caminhao': pesoCaminhao,
    };
  }
}
