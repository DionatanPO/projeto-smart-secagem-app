class CustoProcessoModel {
  final int processoId;
  final String tipoProcesso;
  final String status;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final double duracaoHoras;

  final int? loteId;
  final String? loteNumero;
  final String? loteCultura;
  final double? lotePesoInicial;
  final double? lotePesoFinal;

  final int? secadorId;
  final String? secadorNome;
  final String? secadorFonteCalor;

  final double custoCombustivel;
  final double custoEnergia;
  final double custoMaoObra;
  final double custoManutencao;
  final double custoDepreciacao;
  final double custoTotal;
  final double custoPorHora;
  final double? custoPorTonAgua;
  final double? aguaRemovidaKg;

  CustoProcessoModel({
    required this.processoId,
    required this.tipoProcesso,
    required this.status,
    required this.dataInicio,
    this.dataFim,
    required this.duracaoHoras,
    this.loteId,
    this.loteNumero,
    this.loteCultura,
    this.lotePesoInicial,
    this.lotePesoFinal,
    this.secadorId,
    this.secadorNome,
    this.secadorFonteCalor,
    required this.custoCombustivel,
    required this.custoEnergia,
    required this.custoMaoObra,
    required this.custoManutencao,
    required this.custoDepreciacao,
    required this.custoTotal,
    required this.custoPorHora,
    this.custoPorTonAgua,
    this.aguaRemovidaKg,
  });

  double get aguaRemovidaToneladas => aguaRemovidaKg != null ? aguaRemovidaKg! / 1000 : 0;

  factory CustoProcessoModel.fromJson(Map<String, dynamic> json) {
    return CustoProcessoModel(
      processoId: json['processo_id'],
      tipoProcesso: json['tipo_processo'] ?? '',
      status: json['status'] ?? '',
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: json['data_fim'] != null ? DateTime.parse(json['data_fim']) : null,
      duracaoHoras: (json['duracao_horas'] ?? 0).toDouble(),
      loteId: json['lote_id'],
      loteNumero: json['lote_numero'],
      loteCultura: json['lote_cultura'],
      lotePesoInicial: _toDouble(json['lote_peso_inicial']),
      lotePesoFinal: _toDouble(json['lote_peso_final']),
      secadorId: json['secador_id'],
      secadorNome: json['secador_nome'],
      secadorFonteCalor: json['secador_fonte_calor'],
      custoCombustivel: (json['custo_combustivel'] ?? 0).toDouble(),
      custoEnergia: (json['custo_energia'] ?? 0).toDouble(),
      custoMaoObra: (json['custo_mao_obra'] ?? 0).toDouble(),
      custoManutencao: (json['custo_manutencao'] ?? 0).toDouble(),
      custoDepreciacao: (json['custo_depreciacao'] ?? 0).toDouble(),
      custoTotal: (json['custo_total'] ?? 0).toDouble(),
      custoPorHora: (json['custo_por_hora'] ?? 0).toDouble(),
      custoPorTonAgua: _toDouble(json['custo_por_ton_agua']),
      aguaRemovidaKg: _toDouble(json['agua_removida_kg']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
