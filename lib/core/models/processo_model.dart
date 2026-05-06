class ProcessoModel {
  final int? id;
  final String tipoProcesso;
  final int? loteId;
  final String? loteNumero;
  final String? loteCultura;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final String status;
  final int? responsavelId;
  final String? responsavelNome;

  ProcessoModel({
    this.id,
    required this.tipoProcesso,
    this.loteId,
    this.loteNumero,
    this.loteCultura,
    required this.dataInicio,
    this.dataFim,
    required this.status,
    this.responsavelId,
    this.responsavelNome,
  });

  factory ProcessoModel.fromJson(Map<String, dynamic> json) {
    return ProcessoModel(
      id: json['id'],
      tipoProcesso: json['tipo_processo'] ?? 'Secagem',
      loteId: json['lote'],
      loteNumero: json['lote_numero'],
      loteCultura: json['lote_cultura'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: json['data_fim'] != null ? DateTime.parse(json['data_fim']) : null,
      status: json['status'],
      responsavelId: json['responsavel'],
      responsavelNome: json['responsavel_nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tipo_processo': tipoProcesso,
      'lote': loteId,
      'data_inicio': dataInicio.toIso8601String(),
      'data_fim': dataFim?.toIso8601String(),
      'status': status,
      // O responsável é atribuído automaticamente pelo backend pelo token
    };
  }
}
