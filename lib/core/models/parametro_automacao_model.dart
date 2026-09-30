class ParametroAutomacaoModel {
  final int? id;
  final int secadorId;
  final String? secadorNome;
  final int? receitaId;
  final String? receitaNome;
  final int? sensorAmbienteId;
  final String? sensorAmbientePhysicalId;

  final String modoOperacao;
  final String cultura;
  final double? umidadeEntrada;
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
  final int tempoResfriamentoMin;

  final double ventilacaoPct;
  final double? pressaoPlenumMin;
  final double? vazaoArAlvo;
  final double saidaAcimaAmbienteMax;
  final double deltaExaustaoFim;
  final double taxaSecagemMaxPph;

  final bool intertravamentoFornalha;
  final bool corteEmergenciaIncendio;
  final bool correcaoAmbienteAuto;
  final bool ativo;

  const ParametroAutomacaoModel({
    this.id,
    required this.secadorId,
    this.secadorNome,
    this.receitaId,
    this.receitaNome,
    this.sensorAmbienteId,
    this.sensorAmbientePhysicalId,
    this.modoOperacao = 'manual',
    this.cultura = '',
    this.umidadeEntrada,
    this.umidadeAlvo = 13.5,
    this.tempArAlvo = 90.0,
    this.tempArMax = 110.0,
    this.tempMassaMax = 50.0,
    this.tempExaustaoAlvo,
    this.histerese = 2.0,
    this.modoDescarga = 'intermitente_tempo',
    this.descargaOnMin = 3.0,
    this.descargaOffMin = 12.0,
    this.velocidadeRoloPct = 60.0,
    this.tempoResfriamentoMin = 30,
    this.ventilacaoPct = 100.0,
    this.pressaoPlenumMin,
    this.vazaoArAlvo,
    this.saidaAcimaAmbienteMax = 10.0,
    this.deltaExaustaoFim = 20.0,
    this.taxaSecagemMaxPph = 1.8,
    this.intertravamentoFornalha = true,
    this.corteEmergenciaIncendio = true,
    this.correcaoAmbienteAuto = true,
    this.ativo = true,
  });

  bool get isValid => tempArAlvo <= tempArMax;

  factory ParametroAutomacaoModel.defaults(int secadorId) {
    return ParametroAutomacaoModel(secadorId: secadorId);
  }

  factory ParametroAutomacaoModel.fromJson(Map<String, dynamic> json) {
    return ParametroAutomacaoModel(
      id: json['id'],
      secadorId: (json['secador'] as num?)?.toInt() ?? 0,
      secadorNome: json['secador_nome'],
      receitaId: json['receita'],
      receitaNome: json['receita_nome'],
      sensorAmbienteId: json['sensor_ambiente'],
      sensorAmbientePhysicalId: json['sensor_ambiente_physical_id'],
      modoOperacao: json['modo_operacao'] ?? 'manual',
      cultura: json['cultura'] ?? '',
      umidadeEntrada: _toDouble(json['umidade_entrada']),
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
      tempoResfriamentoMin: (json['tempo_resfriamento_min'] as num?)?.toInt() ?? 30,
      ventilacaoPct: _toDouble(json['ventilacao_pct']) ?? 100.0,
      pressaoPlenumMin: _toDouble(json['pressao_plenum_min']),
      vazaoArAlvo: _toDouble(json['vazao_ar_alvo']),
      saidaAcimaAmbienteMax: _toDouble(json['saida_acima_ambiente_max']) ?? 10.0,
      deltaExaustaoFim: _toDouble(json['delta_exaustao_fim']) ?? 20.0,
      taxaSecagemMaxPph: _toDouble(json['taxa_secagem_max_pph']) ?? 1.8,
      intertravamentoFornalha: json['intertravamento_fornalha'] ?? true,
      corteEmergenciaIncendio: json['corte_emergencia_incendio'] ?? true,
      correcaoAmbienteAuto: json['correcao_ambiente_auto'] ?? true,
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (receitaId != null) 'receita': receitaId,
      if (sensorAmbienteId != null) 'sensor_ambiente': sensorAmbienteId,
      'modo_operacao': modoOperacao,
      'cultura': cultura,
      'umidade_entrada': umidadeEntrada,
      'umidade_alvo': umidadeAlvo,
      'temp_ar_alvo': tempArAlvo,
      'temp_ar_max': tempArMax,
      'temp_massa_max': tempMassaMax,
      'temp_exaustao_alvo': tempExaustaoAlvo,
      'histerese': histerese,
      'modo_descarga': modoDescarga,
      'descarga_on_min': descargaOnMin,
      'descarga_off_min': descargaOffMin,
      'velocidade_rolo_pct': velocidadeRoloPct,
      'tempo_resfriamento_min': tempoResfriamentoMin,
      'ventilacao_pct': ventilacaoPct,
      'pressao_plenum_min': pressaoPlenumMin,
      'vazao_ar_alvo': vazaoArAlvo,
      'saida_acima_ambiente_max': saidaAcimaAmbienteMax,
      'delta_exaustao_fim': deltaExaustaoFim,
      'taxa_secagem_max_pph': taxaSecagemMaxPph,
      'intertravamento_fornalha': intertravamentoFornalha,
      'corte_emergencia_incendio': corteEmergenciaIncendio,
      'correcao_ambiente_auto': correcaoAmbienteAuto,
      'ativo': ativo,
    };
  }

  ParametroAutomacaoModel copyWith({
    int? receitaId,
    int? sensorAmbienteId,
    String? modoOperacao,
    String? cultura,
    double? umidadeEntrada,
    double? umidadeAlvo,
    double? tempArAlvo,
    double? tempArMax,
    double? tempMassaMax,
    double? tempExaustaoAlvo,
    double? histerese,
    String? modoDescarga,
    double? descargaOnMin,
    double? descargaOffMin,
    double? velocidadeRoloPct,
    int? tempoResfriamentoMin,
    double? ventilacaoPct,
    double? pressaoPlenumMin,
    double? vazaoArAlvo,
    double? saidaAcimaAmbienteMax,
    double? deltaExaustaoFim,
    double? taxaSecagemMaxPph,
    bool? intertravamentoFornalha,
    bool? corteEmergenciaIncendio,
    bool? correcaoAmbienteAuto,
    bool? ativo,
  }) {
    return ParametroAutomacaoModel(
      id: id,
      secadorId: secadorId,
      secadorNome: secadorNome,
      receitaId: receitaId ?? this.receitaId,
      receitaNome: receitaNome,
      sensorAmbienteId: sensorAmbienteId ?? this.sensorAmbienteId,
      sensorAmbientePhysicalId: sensorAmbientePhysicalId,
      modoOperacao: modoOperacao ?? this.modoOperacao,
      cultura: cultura ?? this.cultura,
      umidadeEntrada: umidadeEntrada ?? this.umidadeEntrada,
      umidadeAlvo: umidadeAlvo ?? this.umidadeAlvo,
      tempArAlvo: tempArAlvo ?? this.tempArAlvo,
      tempArMax: tempArMax ?? this.tempArMax,
      tempMassaMax: tempMassaMax ?? this.tempMassaMax,
      tempExaustaoAlvo: tempExaustaoAlvo ?? this.tempExaustaoAlvo,
      histerese: histerese ?? this.histerese,
      modoDescarga: modoDescarga ?? this.modoDescarga,
      descargaOnMin: descargaOnMin ?? this.descargaOnMin,
      descargaOffMin: descargaOffMin ?? this.descargaOffMin,
      velocidadeRoloPct: velocidadeRoloPct ?? this.velocidadeRoloPct,
      tempoResfriamentoMin: tempoResfriamentoMin ?? this.tempoResfriamentoMin,
      ventilacaoPct: ventilacaoPct ?? this.ventilacaoPct,
      pressaoPlenumMin: pressaoPlenumMin ?? this.pressaoPlenumMin,
      vazaoArAlvo: vazaoArAlvo ?? this.vazaoArAlvo,
      saidaAcimaAmbienteMax: saidaAcimaAmbienteMax ?? this.saidaAcimaAmbienteMax,
      deltaExaustaoFim: deltaExaustaoFim ?? this.deltaExaustaoFim,
      taxaSecagemMaxPph: taxaSecagemMaxPph ?? this.taxaSecagemMaxPph,
      intertravamentoFornalha: intertravamentoFornalha ?? this.intertravamentoFornalha,
      corteEmergenciaIncendio: corteEmergenciaIncendio ?? this.corteEmergenciaIncendio,
      correcaoAmbienteAuto: correcaoAmbienteAuto ?? this.correcaoAmbienteAuto,
      ativo: ativo ?? this.ativo,
    );
  }

  ParametroAutomacaoModel applyReceita(dynamic receita) {
    return copyWith(
      receitaId: receita.id,
      cultura: receita.cultura,
      umidadeAlvo: receita.umidadeAlvo,
      tempArAlvo: receita.tempArAlvo,
      tempArMax: receita.tempArMax,
      tempMassaMax: receita.tempMassaMax,
      tempExaustaoAlvo: receita.tempExaustaoAlvo,
      histerese: receita.histerese,
      modoDescarga: receita.modoDescarga,
      descargaOnMin: receita.descargaOnMin,
      descargaOffMin: receita.descargaOffMin,
      velocidadeRoloPct: receita.velocidadeRoloPct,
      ventilacaoPct: receita.ventilacaoPct,
      tempoResfriamentoMin: receita.tempoResfriamentoMin,
      vazaoArAlvo: receita.vazaoArAlvo,
      saidaAcimaAmbienteMax: receita.saidaAcimaAmbienteMax,
      deltaExaustaoFim: receita.deltaExaustaoFim,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
