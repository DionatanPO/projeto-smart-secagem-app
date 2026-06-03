class SecadorModel {
  final int? id;
  final int unidadeArmazenadoraId;
  final String? unidadeArmazenadoraNome;
  final String nome;
  final String tipo;
  final double capacidade;
  final String fonteCalor;
  final String status;
  final String? observacoes;

  // Custos de Capital
  final double? custoAquisicao;
  final double? valorResidual;
  final int? vidaUtilAnos;

  // Custos Operacionais
  final double? custoInstalacao;
  final double? custoManutencaoAnual;
  final double? consumoCombustivelHora;
  final double? precoCombustivel;
  final double? consumoEnergiaKwh;
  final double? precoKwh;
  final double? custoMaoObraHora;

  SecadorModel({
    this.id,
    required this.unidadeArmazenadoraId,
    this.unidadeArmazenadoraNome,
    required this.nome,
    required this.tipo,
    required this.capacidade,
    required this.fonteCalor,
    required this.status,
    this.observacoes,
    this.custoAquisicao,
    this.valorResidual,
    this.vidaUtilAnos,
    this.custoInstalacao,
    this.custoManutencaoAnual,
    this.consumoCombustivelHora,
    this.precoCombustivel,
    this.consumoEnergiaKwh,
    this.precoKwh,
    this.custoMaoObraHora,
  });

  factory SecadorModel.fromJson(Map<String, dynamic> json) {
    return SecadorModel(
      id: json['id'],
      unidadeArmazenadoraId: json['unidade_armazenadora'],
      unidadeArmazenadoraNome: json['unidade_armazenadora_nome'],
      nome: json['nome'] ?? json['name'],
      tipo: json['tipo'] ?? json['type'],
      capacidade: (json['capacidade'] ?? json['capacity'] ?? 0.0).toDouble(),
      fonteCalor: json['fonte_calor'] ?? json['fuel_source'] ?? 'Lenha',
      status: json['status'] ?? 'Disponível',
      observacoes: json['observacoes'] ?? json['observations'],
      custoAquisicao: _toDouble(json['custo_aquisicao']),
      valorResidual: _toDouble(json['valor_residual']),
      vidaUtilAnos: json['vida_util_anos'],
      custoInstalacao: _toDouble(json['custo_instalacao']),
      custoManutencaoAnual: _toDouble(json['custo_manutencao_anual']),
      consumoCombustivelHora: _toDouble(json['consumo_combustivel_hora']),
      precoCombustivel: _toDouble(json['preco_combustivel']),
      consumoEnergiaKwh: _toDouble(json['consumo_energia_kwh']),
      precoKwh: _toDouble(json['preco_kwh']),
      custoMaoObraHora: _toDouble(json['custo_mao_obra_hora']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'unidade_armazenadora': unidadeArmazenadoraId,
      'nome': nome,
      'tipo': tipo,
      'capacidade': capacidade,
      'fonte_calor': fonteCalor,
      'status': status,
      'observacoes': observacoes,
      'custo_aquisicao': custoAquisicao,
      'valor_residual': valorResidual,
      'vida_util_anos': vidaUtilAnos,
      'custo_instalacao': custoInstalacao,
      'custo_manutencao_anual': custoManutencaoAnual,
      'consumo_combustivel_hora': consumoCombustivelHora,
      'preco_combustivel': precoCombustivel,
      'consumo_energia_kwh': consumoEnergiaKwh,
      'preco_kwh': precoKwh,
      'custo_mao_obra_hora': custoMaoObraHora,
    };
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
