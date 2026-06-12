class ProcessoModel {
  final int? id;
  final String tipoProcesso;
  final int? loteId;
  final int? secadorId;
  final int? siloId;
  final String? loteNumero;
  final String? loteCultura;
  final String? secadorNome;
  final String? siloNome;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final String status;
  final int? responsavelId;
  final String? responsavelNome;
  final String? observacoes;
  final Map<String, dynamic>? dadosExtras;

  ProcessoModel({
    this.id,
    required this.tipoProcesso,
    this.loteId,
    this.secadorId,
    this.siloId,
    this.loteNumero,
    this.loteCultura,
    this.secadorNome,
    this.siloNome,
    required this.dataInicio,
    this.dataFim,
    required this.status,
    this.responsavelId,
    this.responsavelNome,
    this.observacoes,
    this.dadosExtras,
  });

  factory ProcessoModel.fromJson(Map<String, dynamic> json) {
    return ProcessoModel(
      id: json['id'],
      tipoProcesso: json['tipo_processo'] ?? 'Secagem',
      loteId: json['lote'],
      secadorId: json['secador'],
      siloId: json['silo'],
      loteNumero: json['lote_numero'],
      loteCultura: json['lote_cultura'],
      secadorNome: json['secador_nome'],
      siloNome: json['silo_nome'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: json['data_fim'] != null ? DateTime.parse(json['data_fim']) : null,
      status: json['status'],
      responsavelId: json['responsavel'],
      responsavelNome: json['responsavel_nome'],
      observacoes: json['observacoes'],
      dadosExtras: json['dados_extras'] is Map<String, dynamic> ? json['dados_extras'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tipo_processo': tipoProcesso,
      'lote': loteId,
      'secador': secadorId,
      'silo': siloId,
      'data_inicio': dataInicio.toIso8601String(),
      'data_fim': dataFim?.toIso8601String(),
      'status': status,
      if (observacoes != null) 'observacoes': observacoes,
      if (dadosExtras != null) 'dados_extras': dadosExtras,
    };
  }
}
