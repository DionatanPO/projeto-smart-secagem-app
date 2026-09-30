import 'dart:math' as math;
import 'package:get/get.dart';
import '../../../core/models/parametro_automacao_model.dart';
import '../../../core/models/receita_secagem_model.dart';
import '../../../core/models/sensor_model.dart';
import '../../../core/models/secador_model.dart';
import '../../../core/models/telemetry_model.dart';
import '../../../core/services/api_service.dart';

class AutomacaoController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final SecadorModel secador;
  AutomacaoController(this.secador);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final isDirty = false.obs;
  final parametros = Rxn<ParametroAutomacaoModel>();
  final receitas = <ReceitaSecagemModel>[].obs;

  // Ambiente (unidade) x interior (secador)
  // Temperatura e umidade externas podem vir de sensores separados
  // (ex: um termômetro + um higrômetro), por isso são combinadas.
  final sensoresAmbiente = <SensorModel>[].obs;
  final ambienteAtual = Rxn<TelemetryModel>();
  final extTemp = Rxn<double>();
  final extUmid = Rxn<double>();
  final extCo2 = Rxn<double>();
  final interiorAtual = Rxn<TelemetryModel>();
  final intCo2 = Rxn<double>();

  // Fim de secagem (literatura BR): plenum/exaustão/saída classificados por tipo.
  final tiposSensores = <int, String>{};
  final plenumTemp = Rxn<double>();
  final exaustTemp = Rxn<double>();
  final saidaTemp = Rxn<double>();

  double? get deltaT {
    final tInt = interiorAtual.value?.temperature;
    final tExt = extTemp.value;
    if (tInt == null || tExt == null) return null;
    return tInt - tExt;
  }

  /// Espelha api/services/automacao_service.avaliar_fim_secagem.
  Map<String, dynamic> get fimSecagem {
    final draft = parametros.value;
    final motivos = <String>[];
    double? deltaEx;
    double? acimaAmb;
    if (draft != null) {
      final pl = plenumTemp.value;
      final ex = exaustTemp.value;
      if (pl != null && ex != null) {
        deltaEx = pl - ex;
        if (deltaEx < draft.deltaExaustaoFim) {
          motivos.add(
              'Delta plenum–exaustão ${deltaEx.toStringAsFixed(1)}°C < ${draft.deltaExaustaoFim.toStringAsFixed(1)}°C: massa parou de ceder água');
        }
      }
      final sa = saidaTemp.value;
      final te = extTemp.value;
      if (sa != null && te != null) {
        acimaAmb = sa - te;
        if (acimaAmb <= draft.saidaAcimaAmbienteMax) {
          motivos.add(
              'Saída ${sa.toStringAsFixed(1)}°C a ${acimaAmb.toStringAsFixed(1)}°C do ambiente: grão frio');
        }
      }
    }
    return {'fim': motivos.isNotEmpty, 'motivos': motivos, 'deltaEx': deltaEx, 'acimaAmb': acimaAmb};
  }

  String get statusComparacao {
    final tExt = extTemp.value;
    final urExt = extUmid.value;
    final co2 = intCo2.value;
    if (co2 != null && co2 >= 1500) return 'Atenção: CO₂ elevado no secador — possível atividade biológica';
    if (tExt == null && urExt == null && extCo2.value == null) return 'Sem estação externa vinculada à unidade';
    final d = deltaT;
    if (urExt != null && urExt > 85) return 'Atenção: umidade externa alta — risco de condensação';
    if (d == null) return 'Sem leitura de temperatura externa';
    if (d < 30) return 'Delta baixo — verificar fornalha';
    return 'Delta T OK — compensado pelo ambiente';
  }

  /// Calcula a Umidade de Equilíbrio Higroscópico (Ue % b.u.) pela Equação de Chung-Pfost (ASAE D245.5).
  /// Ue_bs = - (1 / C2) * ln[ - (T + C3) * ln(UR) / C1 ]
  /// Ue_bu = (Ue_bs / (1 + Ue_bs)) * 100
  double? get umidadeEquilibrio {
    final t = extTemp.value;
    final urPct = extUmid.value;
    if (t == null || urPct == null) return null;

    final ur = (urPct / 100.0).clamp(0.05, 0.99);
    final tempC = t.clamp(0.0, 60.0);

    final cultura = (parametros.value?.cultura ?? '').toLowerCase();
    double c1 = 312.3;
    double c2 = 15.2;
    double c3 = 30.2;

    if (cultura.contains('soja')) {
      c1 = 419.6;
      c2 = 17.1;
      c3 = 35.7;
    } else if (cultura.contains('arroz')) {
      c1 = 566.8;
      c2 = 18.9;
      c3 = 36.1;
    } else if (cultura.contains('trigo')) {
      c1 = 512.4;
      c2 = 17.5;
      c3 = 35.6;
    }

    try {
      final inner = -((tempC + c3) * math.log(ur)) / c1;
      if (inner <= 0) return null;
      final ueBs = -(1.0 / c2) * math.log(inner);
      if (ueBs <= 0) return null;
      final ueBu = (ueBs / (1.0 + ueBs)) * 100.0;
      return ueBu;
    } catch (_) {
      return null;
    }
  }

  /// Diagnóstico psicrométrico contra sob-secagem (Overdrying)
  Map<String, dynamic> get analiseSobSecagem {
    final ue = umidadeEquilibrio;
    final draft = parametros.value;
    if (ue == null || draft == null) {
      return {'alerta': false, 'tipo': 'sem_leitura', 'mensagem': 'Aguardando telemetria climática'};
    }

    final alvo = draft.umidadeAlvo;
    if (alvo < (ue - 1.5)) {
      return {
        'alerta': true,
        'tipo': 'perigo_perda_peso',
        'mensagem':
            'Alerta de Sob-secagem (Chung-Pfost): Meta de ${alvo.toStringAsFixed(1)}% está abaixo do equilíbrio do ar (${ue.toStringAsFixed(1)}%). Risco de perda de peso comercial e quebra do grão.',
      };
    } else if (alvo > (ue + 2.0)) {
      return {
        'alerta': false,
        'tipo': 'ar_favoravel',
        'mensagem':
            'Ar ambiente com alto potencial secante (Equilíbrio Ue: ${ue.toStringAsFixed(1)}%). Favorável ao processo com baixo consumo térmico.',
      };
    }
    return {
      'alerta': false,
      'tipo': 'equilibrado',
      'mensagem':
          'Equilíbrio higroscópico Ue: ${ue.toStringAsFixed(1)}% em sintonia com a meta comercial de ${alvo.toStringAsFixed(1)}%.',
    };
  }

  /// Recomenda a taxa máxima segura de extração em pontos percentuais/hora (% p.p./h)
  double get taxaSecagemSugeridaCultura {
    final cultura = (parametros.value?.cultura ?? '').toLowerCase();
    if (cultura.contains('soja')) return 1.1;
    if (cultura.contains('arroz')) return 1.2;
    if (cultura.contains('semente')) return 0.8;
    return 1.8; // Milho / padrão
  }

  /// Avalia se a taxa máxima configurada é segura para a integridade física dos grãos
  Map<String, dynamic> get avaliacaoTaxaSecagem {
    final draft = parametros.value;
    if (draft == null) return {'seguro': true, 'aviso': ''};

    final taxaConfigurada = draft.taxaSecagemMaxPph;
    final cultura = draft.cultura.toLowerCase();

    if (cultura.contains('soja') && taxaConfigurada > 1.3) {
      return {
        'seguro': false,
        'aviso':
            'Taxa de ${taxaConfigurada.toStringAsFixed(1)} p.p./h excede o teto seguro para soja (máx 1.2 p.p./h). Risco de quebra de tegumento.',
      };
    } else if (cultura.contains('semente') && taxaConfigurada > 1.0) {
      return {
        'seguro': false,
        'aviso':
            'Para sementes, taxas acima de 1.0 p.p./h provocam fissuras internas e perda de vigor germinativo.',
      };
    } else if (taxaConfigurada > 2.2) {
      return {
        'seguro': false,
        'aviso':
            'Taxa excessiva (>2.0 p.p./h). Risco de trincas térmicas (stress cracks) no endosperma vítreo.',
      };
    }

    return {
      'seguro': true,
      'aviso': 'Taxa de ${taxaConfigurada.toStringAsFixed(1)} p.p./h em conformidade com os limites agronômicos.',
    };
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadParametros(),
        loadReceitas(),
        loadAmbiente(),
        loadInterior(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  ParametroAutomacaoModel? _originalParametros;

  int get changedFieldsCount {
    final orig = _originalParametros;
    final curr = parametros.value;
    if (orig == null || curr == null) return 0;
    int count = 0;
    if (orig.modoOperacao != curr.modoOperacao) count++;
    if (orig.cultura != curr.cultura) count++;
    if (orig.receitaId != curr.receitaId) count++;
    if (orig.umidadeEntrada != curr.umidadeEntrada) count++;
    if (orig.umidadeAlvo != curr.umidadeAlvo) count++;
    if (orig.tempArAlvo != curr.tempArAlvo) count++;
    if (orig.tempArMax != curr.tempArMax) count++;
    if (orig.tempMassaMax != curr.tempMassaMax) count++;
    if (orig.tempExaustaoAlvo != curr.tempExaustaoAlvo) count++;
    if (orig.histerese != curr.histerese) count++;
    if (orig.modoDescarga != curr.modoDescarga) count++;
    if (orig.descargaOnMin != curr.descargaOnMin) count++;
    if (orig.descargaOffMin != curr.descargaOffMin) count++;
    if (orig.velocidadeRoloPct != curr.velocidadeRoloPct) count++;
    if (orig.ventilacaoPct != curr.ventilacaoPct) count++;
    if (orig.vazaoArAlvo != curr.vazaoArAlvo) count++;
    if (orig.saidaAcimaAmbienteMax != curr.saidaAcimaAmbienteMax) count++;
    if (orig.deltaExaustaoFim != curr.deltaExaustaoFim) count++;
    if (orig.taxaSecagemMaxPph != curr.taxaSecagemMaxPph) count++;
    if (orig.intertravamentoFornalha != curr.intertravamentoFornalha) count++;
    if (orig.corteEmergenciaIncendio != curr.corteEmergenciaIncendio) count++;
    if (orig.correcaoAmbienteAuto != curr.correcaoAmbienteAuto) count++;
    if (orig.ativo != curr.ativo) count++;
    return count;
  }

  void revertDraft() {
    if (_originalParametros != null) {
      parametros.value = _originalParametros;
      isDirty.value = false;
    }
  }

  Future<void> loadParametros() async {
    final id = secador.id;
    if (id == null) return;
    try {
      final resp = await _api.dio.get('secadores/$id/parametros/');
      if (resp.statusCode == 200) {
        parametros.value = ParametroAutomacaoModel.fromJson(
          Map<String, dynamic>.from(resp.data),
        );
      }
    } catch (_) {
      parametros.value = ParametroAutomacaoModel.defaults(id);
    }
    parametros.value ??= ParametroAutomacaoModel.defaults(id);
    _originalParametros = parametros.value;
    isDirty.value = false;
  }

  Future<void> loadReceitas() async {
    try {
      final resp = await _api.dio.get('receitas-secagem/', queryParameters: {'ativo': '1'});
      if (resp.statusCode == 200) {
        receitas.assignAll((resp.data as List)
            .map((e) => ReceitaSecagemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList());
      }
    } catch (_) {}
  }

  Future<void> loadAmbiente() async {
    sensoresAmbiente.clear();
    ambienteAtual.value = null;
    extTemp.value = null;
    extUmid.value = null;
    extCo2.value = null;
    final unidadeId = secador.unidadeArmazenadoraId;
    try {
      final resp = await _api.dio.get('sensores/', queryParameters: {
        'unidade': unidadeId,
        'somente_ambiente': '1',
      });
      if (resp.statusCode == 200) {
        final all = (resp.data as List)
            .map((e) => SensorModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        sensoresAmbiente.assignAll(all);
      }
      // Combina a última temperatura e a última umidade entre todos os
      // sensores externos (podem ser aparelhos separados).
      double? temp;
      double? umid;
      double? co2;
      DateTime? tsTemp;
      DateTime? tsUmid;
      String phys = '';
      for (final s in sensoresAmbiente.where((s) => s.id != null)) {
        try {
          final t = await _api.dio.get('telemetria/', queryParameters: {
            'sensor': s.id,
            'limit': 3,
          });
          if (t.statusCode == 200) {
            for (final e in (t.data as List)) {
              final raw = Map<String, dynamic>.from(e);
              final tVal = (raw['temperatura'] as num?)?.toDouble();
              final uVal = (raw['umidade'] as num?)?.toDouble();
              final cVal = (raw['co2_ppm'] as num?)?.toDouble();
              if (temp == null && tVal != null) {
                temp = tVal;
                tsTemp = DateTime.tryParse(raw['timestamp']?.toString() ?? '');
                if (phys.isEmpty) phys = raw['sensor_physical_id']?.toString() ?? s.sensorId;
              }
              if (umid == null && uVal != null) {
                umid = uVal;
                tsUmid ??= DateTime.tryParse(raw['timestamp']?.toString() ?? '');
              }
              if (co2 == null && cVal != null) co2 = cVal;
              if (temp != null && umid != null && co2 != null) break;
            }
          }
        } catch (_) {}
        if (temp != null && umid != null && co2 != null) break;
      }
      extTemp.value = temp;
      extUmid.value = umid;
      extCo2.value = co2;
      if (temp != null || umid != null) {
        ambienteAtual.value = TelemetryModel(
          sensorId: sensoresAmbiente.first.id ?? 0,
          sensorPhysicalId: phys.isEmpty ? 'EXTERNA' : phys,
          temperature: temp ?? 0,
          humidity: umid ?? 0,
          timestamp: tsTemp ?? tsUmid ?? DateTime.now(),
        );
      }
    } catch (_) {}
  }

  Future<void> loadInterior() async {
    final id = secador.id;
    if (id == null) return;
    interiorAtual.value = null;
    intCo2.value = null;
    plenumTemp.value = null;
    exaustTemp.value = null;
    saidaTemp.value = null;
    try {
      // Mapa sensor -> tipo para classificar plenum/exaustão/massa.
      try {
        final sResp = await _api.dio.get('sensores/', queryParameters: {'secador': id});
        if (sResp.statusCode == 200) {
          tiposSensores.clear();
          for (final e in (sResp.data as List)) {
            final m = Map<String, dynamic>.from(e);
            final sid = (m['id'] as num?)?.toInt();
            if (sid != null) tiposSensores[sid] = (m['tipo']?.toString() ?? '');
          }
        }
      } catch (_) {}
      final resp = await _api.dio.get('telemetria/',
          queryParameters: {'secador': id, 'limit': 20});
      if (resp.statusCode == 200 && (resp.data as List).isNotEmpty) {
        final list = (resp.data as List)
            .map((e) => TelemetryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        interiorAtual.value = list.first;
        double? pick(String tipo) {
          for (final r in list) {
            if (tiposSensores[r.sensorId] == tipo) return r.temperature;
          }
          return null;
        }
        plenumTemp.value = pick(SensorModel.tipoPlenum);
        exaustTemp.value = pick(SensorModel.tipoExaustao);
        // Saída do grão: aproxima pela última massa de grãos (sem sensor dedicado).
        saidaTemp.value = pick(SensorModel.tipoMassaGraos);
        for (final r in list) {
          if (r.co2Ppm != null) {
            intCo2.value = r.co2Ppm;
            break;
          }
        }
      }
    } catch (_) {}
  }

  void updateDraft(ParametroAutomacaoModel draft) {
    parametros.value = draft;
    isDirty.value = true;
  }

  void aplicarReceita(ReceitaSecagemModel receita) {
    final current = parametros.value;
    if (current == null) return;
    parametros.value = current.applyReceita(receita);
    isDirty.value = true;
  }

  Future<bool> save() async {
    final draft = parametros.value;
    final id = secador.id;
    if (draft == null || id == null) return false;
    if (!draft.isValid) {
      Get.snackbar('Validação', 'Temp. alvo não pode exceder o corte máximo.');
      return false;
    }
    // Regra dos 18% (SeedNews/Weber): contínua só até 18% b.u. de entrada.
    if ((draft.umidadeEntrada ?? 0) > 18 && draft.modoDescarga == 'continuo') {
      Get.snackbar('Validação',
          'Umidade de entrada acima de 18% exige descarga intermitente. Troque o modo de descarga.');
      return false;
    }
    isSaving.value = true;
    try {
      final resp = await _api.dio.put('secadores/$id/parametros/', data: draft.toJson());
      if (resp.statusCode == 200) {
        parametros.value = ParametroAutomacaoModel.fromJson(
          Map<String, dynamic>.from(resp.data),
        );
        _originalParametros = parametros.value;
        isDirty.value = false;
        Get.snackbar('Sucesso', 'Parâmetros de automação salvos.');
        return true;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao salvar parâmetros.');
    } finally {
      isSaving.value = false;
    }
    return false;
  }

  Future<void> refreshAll() => loadAll();
}
