class ReceitaSecagemModel {
  final int? id;
  final String cultura;
  final String nome;
  final double umidadeAlvo;
  final double tempArAlvo;
  final double tempArMax;
  final double tempMassaMax;
  final double? tempExaustaoAlvo;
  final double histerese;
  final String modoDescarga;
  final double descargaOnMin;
  final double descargaOffMin;
  final double velocidadeRoloPct;
  final double ventilacaoPct;
  final int tempoResfriamentoMin;
  final double? vazaoArAlvo;
  final double saidaAcimaAmbienteMax;
  final double deltaExaustaoFim;
  final String? observacao;
  final bool ativo;

  const ReceitaSecagemModel({
    this.id,
    required this.cultura,
    required this.nome,
    required this.umidadeAlvo,
    required this.tempArAlvo,
    required this.tempArMax,
    required this.tempMassaMax,
    this.tempExaustaoAlvo,
    this.histerese = 2.0,
    this.modoDescarga = 'intermitente_tempo',
    this.descargaOnMin = 3.0,
    this.descargaOffMin = 12.0,
    this.velocidadeRoloPct = 60.0,
    this.ventilacaoPct = 100.0,
    this.tempoResfriamentoMin = 30,
    this.vazaoArAlvo,
    this.saidaAcimaAmbienteMax = 10.0,
    this.deltaExaustaoFim = 20.0,
    this.observacao,
    this.ativo = true,
  });

  factory ReceitaSecagemModel.fromJson(Map<String, dynamic> json) {
    return ReceitaSecagemModel(
      id: json['id'],
      cultura: json['cultura'] ?? '',
      nome: json['nome'] ?? '',
      umidadeAlvo: _toDouble(json['umidade_alvo']) ?? 13.5,
      tempArAlvo: _toDouble(json['temp_ar_alvo']) ?? 90.0,
      tempArMax: _toDouble(json['temp_ar_max']) ?? 110.0,
      tempMassaMax: _toDouble(json['temp_massa_max']) ?? 50.0,
      tempExaustaoAlvo: _toDouble(json['temp_exaustao_alvo']),
      histerese: _toDouble(json['histerese']) ?? 2.0,
      modoDescarga: json['modo_descarga'] ?? 'intermitente_tempo',
      descargaOnMin: _toDouble(json['descarga_on_min']) ?? 3.0,
      descargaOffMin: _toDouble(json['descarga_off_min']) ?? 12.0,
      velocidadeRoloPct: _toDouble(json['velocidade_rolo_pct']) ?? 60.0,
      ventilacaoPct: _toDouble(json['ventilacao_pct']) ?? 100.0,
      tempoResfriamentoMin: (json['tempo_resfriamento_min'] as num?)?.toInt() ?? 30,
      vazaoArAlvo: _toDouble(json['vazao_ar_alvo']),
      saidaAcimaAmbienteMax: _toDouble(json['saida_acima_ambiente_max']) ?? 10.0,
      deltaExaustaoFim: _toDouble(json['delta_exaustao_fim']) ?? 20.0,
      observacao: json['observacao'],
      ativo: json['ativo'] ?? true,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
