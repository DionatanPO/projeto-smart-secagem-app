import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/secador_model.dart';
import '../../../core/models/parametro_automacao_model.dart';
import '../controllers/automacao_controller.dart';
import '../widgets/cenarios_automacao_modal.dart';

class _FieldSpec {
  final String label;
  final String help;
  final double value;
  final double min;
  final double max;
  final String unit;
  final double? safeMin;
  final double? safeMax;
  final void Function(double) onChanged;

  const _FieldSpec({
    required this.label,
    required this.help,
    required this.value,
    this.min = 0,
    this.max = 150,
    this.unit = '',
    this.safeMin,
    this.safeMax,
    required this.onChanged,
  });
}

class _Sec {
  final String title;
  final IconData icon;
  final Color color;
  final String desc;
  final String status;
  final Widget body;

  const _Sec(this.title, this.icon, this.color, this.desc, this.status, this.body);
}

class AutomacaoView extends StatefulWidget {
  final SecadorModel secador;
  const AutomacaoView({super.key, required this.secador});

  @override
  State<AutomacaoView> createState() => _AutomacaoViewState();
}

class _AutomacaoViewState extends State<AutomacaoView> with SingleTickerProviderStateMixin {
  late final AutomacaoController controller;
  late final String _tag;
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _horizontalStepController = ScrollController();
  int _stepSelected = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _tag = 'auto_${widget.secador.id}';
    if (Get.isRegistered<AutomacaoController>(tag: _tag)) {
      Get.delete<AutomacaoController>(tag: _tag);
    }
    controller = Get.put(AutomacaoController(widget.secador), tag: _tag);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mainScrollController.dispose();
    _horizontalStepController.dispose();
    Get.delete<AutomacaoController>(tag: _tag);
    super.dispose();
  }

  void _goTo(int i, {bool closeDrawerAfter = false}) {
    setState(() => _stepSelected = i);
    if (closeDrawerAfter && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isDesktop ? null : Obx(() => _stepsDrawer(context)),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.precision_manufacturing_rounded, size: 20, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Automação — ${widget.secador.nome}',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.secador.tipo} • ${widget.secador.capacidade} t/h • ${widget.secador.fonteCalor}',
                    style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Etapas',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshAll,
            tooltip: 'Sincronizar telemetria',
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _saveBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Carregando parâmetros e telemetria...',
                  style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        final draft = controller.parametros.value;
        if (draft == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 48, color: cs.onSurfaceVariant.withOpacity(0.5)),
                const SizedBox(height: 12),
                Text('Sem parâmetros cadastrados', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: controller.refreshAll,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final secs = _sections(context, controller, draft);

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroStatusCard(context, controller, draft),
            const SizedBox(height: 16),
            if (!isDesktop) ...[
              _mobileStepScroller(context, secs),
              const SizedBox(height: 16),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.02, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_stepSelected),
                child: _stepSelected == 0
                    ? _ambienteBanner(context, controller)
                    : _desktopCard(context, secs[_stepSelected - 1], _stepSelected),
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          controller: _mainScrollController,
          padding: EdgeInsets.all(isDesktop ? 28 : 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 280, child: _sideRail(context, controller, secs)),
                        const SizedBox(width: 20),
                        Expanded(child: content),
                      ],
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: content,
                    ),
            ),
          ),
        );
      }),
    );
  }

  // ---------- 1. HERO STATUS CARD ----------

  Widget _heroStatusCard(BuildContext context, AutomacaoController controller, ParametroAutomacaoModel draft) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isAi = draft.modoOperacao == 'ai';
    final bool isAuto = draft.modoOperacao == 'auto';
    final bool isSemi = draft.modoOperacao == 'semi';

    final Color modeColor = isAi
        ? const Color(0xFF8B5CF6)
        : (isAuto
            ? const Color(0xFF10B981)
            : (isSemi ? const Color(0xFFF59E0B) : const Color(0xFF64748B)));

    final bool isAtivo = draft.modoOperacao != 'manual';
    final double? tempAr = controller.plenumTemp.value ?? controller.interiorAtual.value?.temperature;
    final double? delta = controller.deltaT;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? [cs.surface, cs.surface.withOpacity(0.85)]
              : [cs.surface, cs.surface.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pulsing LED indicator
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAtivo ? modeColor : Colors.grey,
                      boxShadow: isAtivo
                          ? [
                              BoxShadow(
                                color: modeColor.withOpacity(0.3 + 0.4 * _pulseController.value),
                                blurRadius: 10 + 6 * _pulseController.value,
                                spreadRadius: 2 * _pulseController.value,
                              )
                            ]
                          : [],
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isAtivo ? 'AUTOMAÇÃO ATIVA' : 'OPERAÇÃO MANUAL',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: isAtivo ? modeColor : cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: modeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: modeColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          _modoLabel(draft.modoOperacao).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: modeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    draft.cultura.isEmpty ? 'Cultura: não informada' : 'Cultura ativa: ${draft.cultura}',
                    style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(),
              if (draft.receitaNome != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_added_rounded, size: 14, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        draft.receitaNome!,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // HUD Mini Telemetry Gauges
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 580;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _heroGaugeBadge(
                  label: 'T. Ar (Plenum)',
                  value: tempAr != null ? '${tempAr.toStringAsFixed(1)}°C' : '—',
                  target: 'Alvo: ${draft.tempArAlvo.toStringAsFixed(0)}°C',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orange,
                  width: isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2,
                ),
                _heroGaugeBadge(
                  label: 'Delta T Térmico',
                  value: delta != null ? '${delta.toStringAsFixed(1)}°C' : '—',
                  target: delta != null && delta >= 30 ? 'Fornalha OK' : 'Baixo ganho',
                  icon: Icons.trending_up_rounded,
                  color: Colors.green,
                  width: isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2,
                ),
                _heroGaugeBadge(
                  label: 'Meta Umidade',
                  value: '${draft.umidadeAlvo.toStringAsFixed(1)}%',
                  target: draft.umidadeEntrada != null
                      ? 'Entrada: ${draft.umidadeEntrada!.toStringAsFixed(1)}%'
                      : 'Sem entrada',
                  icon: Icons.water_drop_rounded,
                  color: Colors.blue,
                  width: isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2,
                ),
                _heroGaugeBadge(
                  label: 'Segurança',
                  value: '${[draft.intertravamentoFornalha, draft.corteEmergenciaIncendio, draft.correcaoAmbienteAuto].where((v) => v).length}/3 Ativos',
                  target: draft.corteEmergenciaIncendio ? 'Corte de Incêndio OK' : '⚠️ Corte Inativo',
                  icon: Icons.shield_rounded,
                  color: draft.corteEmergenciaIncendio ? const Color(0xFF10B981) : Colors.red,
                  width: isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _heroGaugeBadge({
    required String label,
    required String value,
    required String target,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10.5, color: cs.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                Text(target, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 2. STEPPER MOBILE HORIZONTAL ----------

  Widget _mobileStepScroller(BuildContext context, List<_Sec> secs) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        controller: _horizontalStepController,
        scrollDirection: Axis.horizontal,
        itemCount: secs.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = _stepSelected == i;
          final title = i == 0 ? 'Visão geral' : secs[i - 1].title;
          final icon = i == 0 ? Icons.dashboard_rounded : secs[i - 1].icon;
          final color = i == 0 ? cs.primary : secs[i - 1].color;

          return InkWell(
            onTap: () => _goTo(i),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : cs.outlineVariant.withOpacity(0.4),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 15, color: isSelected ? Colors.white : cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- SEÇÕES E REGRAS ----------

  String _modoLabel(String m) {
    switch (m) {
      case 'auto':
        return 'Automático';
      case 'semi':
        return 'Semi-auto';
      case 'ai':
        return 'Modo IA (P&D)';
      default:
        return 'Manual';
    }
  }

  String _descargaLabel(String m) =>
      m == 'continuo' ? 'Contínua' : (m == 'intermitente_umidade' ? 'Intermitente (umidade)' : 'Intermitente (tempo)');

  List<_Sec> _sections(BuildContext context, AutomacaoController controller, ParametroAutomacaoModel draft) {
    final ativas = [
      draft.intertravamentoFornalha,
      draft.corteEmergenciaIncendio,
      draft.correcaoAmbienteAuto,
    ].where((v) => v).length;

    return [
      _Sec(
        'Receita e Operação',
        Icons.restaurant_menu_rounded,
        const Color(0xFF3B82F6),
        'Preset por cultura com faixas recomendadas pela EMBRAPA e definição do nível de autonomia do secador.',
        '${draft.cultura.isEmpty ? 'Sem cultura' : draft.cultura} • ${_modoLabel(draft.modoOperacao)}',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _receitaContent(context, controller, draft),
          const SizedBox(height: 20),
          _modoContent(context, controller, draft),
        ]),
      ),
      _Sec(
        'Controle Térmico',
        Icons.thermostat_rounded,
        const Color(0xFFF97316),
        'Coração da secagem. O ar quente do plenum atravessa a massa e remove a umidade. Limites rígidos protegem contra trinca e queima do grão.',
        'Ar ${draft.tempArAlvo.toStringAsFixed(0)}°C → corte ${draft.tempArMax.toStringAsFixed(0)}°C',
        _fieldGrid(context, [
          _FieldSpec(
            label: 'T. Ar Alvo (°C)',
            help: 'Plenum desejado. Milho: 100–110°C • Soja: 80–90°C • Arroz: 70–80°C • Semente: ≤60°C.',
            value: draft.tempArAlvo,
            min: 40,
            max: 130,
            unit: '°C',
            safeMin: 60,
            safeMax: 110,
            onChanged: (v) => controller.updateDraft(draft.copyWith(tempArAlvo: v)),
          ),
          _FieldSpec(
            label: 'T. Ar Corte Máx (°C)',
            help: 'Segurança absoluta: acima desta temperatura a fornalha é desligada instantaneamente.',
            value: draft.tempArMax,
            min: 50,
            max: 140,
            unit: '°C',
            safeMin: 70,
            safeMax: 120,
            onChanged: (v) => controller.updateDraft(draft.copyWith(tempArMax: v)),
          ),
          _FieldSpec(
            label: 'T. Massa Máx (°C)',
            help: 'Teto térmico do grão. Acima de 50–55°C ocorrem trincas no milho e perda total de germinação em sementes.',
            value: draft.tempMassaMax,
            min: 30,
            max: 80,
            unit: '°C',
            safeMin: 35,
            safeMax: 50,
            onChanged: (v) => controller.updateDraft(draft.copyWith(tempMassaMax: v)),
          ),
          _FieldSpec(
            label: 'Histerese de Controle (°C)',
            help: 'Banda liga/desliga. Exemplo: alvo 105 ± 2°C evita acionamento intermitente nocivo aos relés.',
            value: draft.histerese,
            min: 0.5,
            max: 10,
            unit: '°C',
            safeMin: 1.0,
            safeMax: 3.0,
            onChanged: (v) => controller.updateDraft(draft.copyWith(histerese: v)),
          ),
        ]),
      ),
      _Sec(
        'Controle de Umidade & Cinética',
        Icons.water_drop_rounded,
        const Color(0xFF0EA5E9),
        'Meta comercial, prevenção de sob-secagem (Chung-Pfost) e limitador de taxa de extração (dU/dt) contra trincas.',
        '${draft.umidadeEntrada?.toStringAsFixed(1) ?? '—'}% → ${draft.umidadeAlvo.toStringAsFixed(1)}% • Máx ${draft.taxaSecagemMaxPph.toStringAsFixed(1)} p.p./h',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldGrid(context, [
              _FieldSpec(
                label: 'Umidade de Entrada (%)',
                help: 'Umidade do lote recém-chegado. Acima de 18% requer obrigatoriamente descarga intermitente.',
                value: draft.umidadeEntrada ?? 0,
                min: 10,
                max: 35,
                unit: '%',
                safeMin: 12,
                safeMax: 24,
                onChanged: (v) => controller.updateDraft(draft.copyWith(umidadeEntrada: v)),
              ),
              _FieldSpec(
                label: 'Umidade Alvo Saída (%)',
                help: 'Meta final. Padrão comercial: 13–14% • Armazenamento prolongado / sementes: ~12,5%.',
                value: draft.umidadeAlvo,
                min: 10,
                max: 18,
                unit: '%',
                safeMin: 12.0,
                safeMax: 14.0,
                onChanged: (v) => controller.updateDraft(draft.copyWith(umidadeAlvo: v)),
              ),
              _FieldSpec(
                label: 'Taxa Máx. de Secagem (p.p./h)',
                help: 'Limitador de estresse térmico (dU/dt). Milho: ≤1.8 • Soja: ≤1.2 • Sementes: ≤1.0 p.p./h.',
                value: draft.taxaSecagemMaxPph,
                min: 0.5,
                max: 3.0,
                unit: ' p.p./h',
                safeMin: 0.8,
                safeMax: controller.taxaSecagemSugeridaCultura,
                onChanged: (v) => controller.updateDraft(draft.copyWith(taxaSecagemMaxPph: v)),
              ),
            ]),
            const SizedBox(height: 16),
            _chungPfostCard(context, controller, draft),
          ],
        ),
      ),
      _Sec(
        'Descarga e Ventilação',
        Icons.air_rounded,
        const Color(0xFF10B981),
        'Regula a velocidade de descida dos grãos e os tempos de repouso para homogeneização e economia de energia térmica.',
        '${_descargaLabel(draft.modoDescarga)} • ${draft.descargaOnMin.toStringAsFixed(0)}/${draft.descargaOffMin.toStringAsFixed(0)} min',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _descargaSelector(context, controller, draft),
          const SizedBox(height: 18),
          _fieldGrid(context, [
            _FieldSpec(
              label: 'Tempo Descarga ON (min)',
              help: 'Tempo ativo de giro dos rolos de descarga por ciclo.',
              value: draft.descargaOnMin,
              min: 0.5,
              max: 30,
              unit: 'min',
              safeMin: 1,
              safeMax: 10,
              onChanged: (v) => controller.updateDraft(draft.copyWith(descargaOnMin: v)),
            ),
            _FieldSpec(
              label: 'Tempo Descarga OFF (min)',
              help: 'Tempo de equalização térmica e de umidade no repouso da massa.',
              value: draft.descargaOffMin,
              min: 0,
              max: 60,
              unit: 'min',
              safeMin: 5,
              safeMax: 30,
              onChanged: (v) => controller.updateDraft(draft.copyWith(descargaOffMin: v)),
            ),
            _FieldSpec(
              label: 'Velocidade dos Rolos (%)',
              help: 'Velocidade dos rolos basculantes. Mais % = maior fluxo, menor tempo de contato.',
              value: draft.velocidadeRoloPct,
              min: 10,
              max: 100,
              unit: '%',
              safeMin: 30,
              safeMax: 80,
              onChanged: (v) => controller.updateDraft(draft.copyWith(velocidadeRoloPct: v)),
            ),
            _FieldSpec(
              label: 'Potência Ventilação (%)',
              help: 'Vazão forçada dos ventiladores axiais/centrífugos.',
              value: draft.ventilacaoPct,
              min: 20,
              max: 100,
              unit: '%',
              safeMin: 60,
              safeMax: 100,
              onChanged: (v) => controller.updateDraft(draft.copyWith(ventilacaoPct: v)),
            ),
          ]),
        ]),
      ),
      _Sec(
        'Vazão e Critérios de Fim',
        Icons.wind_power_rounded,
        const Color(0xFF06B6D4),
        'Detecção inteligente de encerramento do processo: aproximação da temperatura de exaustão ao plenum e resfriamento final.',
        'Meta ${(draft.vazaoArAlvo ?? 0).toStringAsFixed(0)} m³/h • Δfim ${draft.deltaExaustaoFim.toStringAsFixed(0)}°C',
        _fieldGrid(context, [
          _FieldSpec(
            label: 'Vazão de Ar Alvo (m³/h)',
            help: 'Vazão específica requerida. Compare com o inversor dos motores do ventilador.',
            value: draft.vazaoArAlvo ?? 0,
            min: 0,
            max: 100000,
            unit: 'm³/h',
            onChanged: (v) => controller.updateDraft(draft.copyWith(vazaoArAlvo: v)),
          ),
          _FieldSpec(
            label: 'Saída Fria: Máx Acima Ambiente (°C)',
            help: 'O grão deve ser descarregado frio na moega/elevador (máx 5–10°C acima da temperatura ambiente).',
            value: draft.saidaAcimaAmbienteMax,
            min: 1,
            max: 25,
            unit: '°C',
            safeMin: 3,
            safeMax: 10,
            onChanged: (v) => controller.updateDraft(draft.copyWith(saidaAcimaAmbienteMax: v)),
          ),
          _FieldSpec(
            label: 'Delta Plenum–Exaustão Fim (°C)',
            help: 'Quando o delta cai abaixo deste patamar, a taxa de evaporação cessou indicando secagem concluída.',
            value: draft.deltaExaustaoFim,
            min: 5,
            max: 50,
            unit: '°C',
            safeMin: 15,
            safeMax: 25,
            onChanged: (v) => controller.updateDraft(draft.copyWith(deltaExaustaoFim: v)),
          ),
        ]),
      ),
      _Sec(
        'Segurança e Intertravamentos',
        Icons.shield_rounded,
        const Color(0xFFEF4444),
        'Camada de proteção de missão crítica: impede ignição sem fluxo de ar e combate sinistros de forma autônoma.',
        '$ativas/3 salvaguardas ativas',
        Column(children: [
          _securityCard(
            context: context,
            title: 'Intertravar Fornalha sem Ventilador',
            sub: 'Impede o acendimento e queima da fornalha se os ventiladores não acusarem fluxo de ar positivo.',
            isCritical: true,
            value: draft.intertravamentoFornalha,
            onChanged: (v) => controller.updateDraft(draft.copyWith(intertravamentoFornalha: v)),
          ),
          const SizedBox(height: 10),
          _securityCard(
            context: context,
            title: 'Corte de Emergência por Incêndio',
            sub: 'Em caso de pico térmico anômalo ou fumaça, extingue a fornalha e aciona damper de alívio.',
            isCritical: true,
            value: draft.corteEmergenciaIncendio,
            onChanged: (v) => controller.updateDraft(draft.copyWith(corteEmergenciaIncendio: v)),
          ),
          const SizedBox(height: 10),
          _securityCard(
            context: context,
            title: 'Compensação Psicométrica do Ambiente',
            sub: 'Ajusta dinamicamente a taxa de descarga conforme a umidade relativa externa da estação.',
            isCritical: false,
            value: draft.correcaoAmbienteAuto,
            onChanged: (v) => controller.updateDraft(draft.copyWith(correcaoAmbienteAuto: v)),
          ),
        ]),
      ),
    ];
  }

  // ---------- 3. SIDE RAIL (DESKTOP) ----------

  Widget _sideRail(BuildContext context, AutomacaoController controller, List<_Sec> secs) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget item(int i, String label, IconData icon, Color color, String status) {
      final sel = _stepSelected == i;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _goTo(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: sel
                  ? (isDark ? color.withOpacity(0.18) : color.withOpacity(0.10))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? color.withOpacity(0.5) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (sel ? color : cs.onSurfaceVariant).withOpacity(sel ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 17,
                      color: sel ? color : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? (isDark ? Colors.white : color) : cs.onSurface,
                        ),
                      ),
                      Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 10.5, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (sel)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final delta = controller.deltaT;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
            child: Row(
              children: [
                Icon(Icons.dashboard_customize_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'SUBSISTEMAS',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          item(0, 'Visão Geral & Telemetria', Icons.sensors_rounded, cs.primary,
              delta == null ? 'Estação em monitoramento' : 'ΔT ${delta.toStringAsFixed(1)}°C'),
          const SizedBox(height: 6),
          for (var i = 0; i < secs.length; i++) ...[
            item(i + 1, secs[i].title, secs[i].icon, secs[i].color, secs[i].status),
            if (i < secs.length - 1) const SizedBox(height: 4),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () {
              final d = controller.parametros.value;
              if (d != null) {
                CenariosAutomacaoModal.show(
                  context,
                  controller: controller,
                  draft: d,
                  onNavigateToStep: (step) => _goTo(step),
                );
              }
            },
            icon: const Icon(Icons.account_tree_rounded, size: 16),
            label: const Text('Ver Fluxos & Cenários', style: TextStyle(fontSize: 12)),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 38),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 4. DRAWER (MOBILE) ----------

  Widget _stepsDrawer(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final draft = controller.parametros.value;
    if (draft == null) return const SizedBox.shrink();
    final secs = _sections(context, controller, draft);
    final delta = controller.deltaT;

    return NavigationDrawer(
      selectedIndex: _stepSelected,
      onDestinationSelected: (i) => _goTo(i, closeDrawerAfter: true),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 16, 4),
          child: Text(widget.secador.nome,
              style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 16),
          child: Text('Etapas de Configuração',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: cs.primary)),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.sensors_rounded),
          label: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Visão Geral & Telemetria', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(delta == null ? 'Sem Delta T' : 'ΔT ${delta.toStringAsFixed(1)}°C',
                  style: GoogleFonts.inter(fontSize: 10.5, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        const Divider(height: 16),
        for (var i = 0; i < secs.length; i++)
          NavigationDrawerDestination(
            icon: Icon(secs[i].icon, color: secs[i].color),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(secs[i].title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(secs[i].status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 10.5, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
      ],
    );
  }

  // ---------- 5. CARD COM ACCENT STRIP ----------

  Widget _desktopCard(BuildContext context, _Sec sec, int number) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Accent strip lateral
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [sec.color, sec.color.withOpacity(0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sec.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(sec.icon, size: 20, color: sec.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sec.title.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: sec.color,
                            ),
                          ),
                          Text(
                            sec.status,
                            style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: sec.color.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sec.color.withOpacity(0.25)),
                      ),
                      child: Text(
                        'ETAPA $number DE 6',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: sec.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  sec.desc,
                  style: GoogleFonts.inter(fontSize: 12.5, height: 1.45, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 18),
                sec.body,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 6. RECEITA & OPERAÇÃO MODERNA ----------

  Widget _receitaContent(BuildContext context, AutomacaoController controller, ParametroAutomacaoModel draft) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_stories_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'Preset Agronômico de Secagem',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: draft.receitaId != null && controller.receitas.any((r) => r.id == draft.receitaId)
              ? draft.receitaId
              : null,
          hint: Text('Selecionar receita predefinida (Milho, Soja, Arroz...)',
              style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            prefixIcon: const Icon(Icons.grain_rounded),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: controller.receitas
              .map((r) => DropdownMenuItem(
                    value: r.id,
                    child: Text(
                      '${r.cultura} — ${r.nome} (Ar: ${r.tempArAlvo.toStringAsFixed(0)}°C, Alvo: ${r.umidadeAlvo.toStringAsFixed(1)}%)',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                  ))
              .toList(),
          onChanged: (id) {
            if (id == null) return;
            final rec = controller.receitas.firstWhere((r) => r.id == id);
            controller.aplicarReceita(rec);
            Get.snackbar(
              'Preset Aplicado',
              'Parâmetros para "${rec.nome}" carregados. Lembre-se de salvar.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: cs.surfaceContainerHighest,
              colorText: cs.onSurface,
            );
          },
        ),
        if (draft.receitaNome != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              Text(
                'Base configurada: ${draft.receitaNome}',
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _modoContent(BuildContext context, AutomacaoController controller, ParametroAutomacaoModel draft) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'Nível de Autonomia Operacional',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final isMedium = constraints.maxWidth > 420;
          final itemWidth = isWide 
              ? (constraints.maxWidth - 30) / 4 
              : (isMedium ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth);
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _modoCardOption(
                title: 'Manual',
                sub: 'Operador comanda fornalha e descarga',
                icon: Icons.handyman_rounded,
                selected: draft.modoOperacao == 'manual',
                color: const Color(0xFF64748B),
                width: itemWidth,
                onTap: () => controller.updateDraft(draft.copyWith(modoOperacao: 'manual', ativo: false)),
              ),
              _modoCardOption(
                title: 'Semi-auto',
                sub: 'Sistema sugere, operador autoriza',
                icon: Icons.touch_app_rounded,
                selected: draft.modoOperacao == 'semi',
                color: const Color(0xFFF59E0B),
                width: itemWidth,
                onTap: () => controller.updateDraft(draft.copyWith(modoOperacao: 'semi', ativo: true)),
              ),
              _modoCardOption(
                title: 'Automático',
                sub: 'Gateway regula ciclo e intertravamentos',
                icon: Icons.smart_toy_rounded,
                selected: draft.modoOperacao == 'auto',
                color: const Color(0xFF10B981),
                width: itemWidth,
                onTap: () => controller.updateDraft(draft.copyWith(modoOperacao: 'auto', ativo: true)),
              ),
              _modoCardOption(
                title: 'Modo IA',
                sub: 'IA preditiva com ajuste autônomo contínuo',
                badgeText: 'P&D FUTURO',
                icon: Icons.auto_awesome_rounded,
                selected: draft.modoOperacao == 'ai',
                color: const Color(0xFF8B5CF6),
                width: itemWidth,
                onTap: () {
                  controller.updateDraft(draft.copyWith(modoOperacao: 'ai', ativo: true));
                  Get.snackbar(
                    'Modo IA (Estudos Futuros)',
                    'Em fase de P&D: Controle preditivo neural MPC com aprendizado de reforço para máxima eficiência.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.9),
                    colorText: Colors.white,
                    icon: const Icon(Icons.psychology_rounded, color: Colors.white),
                    duration: const Duration(seconds: 4),
                  );
                },
              ),
            ],
          );
        }),
        if (draft.modoOperacao == 'ai') ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.science_rounded, size: 20, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modo IA Ativado (Em Desenvolvimento / Estudos Futuros)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Neste modo, redes neurais e algoritmos de controle preditivo baseado em modelo (MPC) irão ajustar a modulação do queimador, fluxo de ar e velocidade de descarga em tempo real, antecipando frentes térmicas antes dos sensores registrarem variação de umidade. A lógica executiva está reservada para as próximas versões de P&D.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.4,
                          color: cs.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          key: ValueKey('cultura|${draft.cultura}|${draft.receitaId}'),
          initialValue: draft.cultura,
          decoration: InputDecoration(
            labelText: 'Cultura Atual no Secador',
            prefixIcon: const Icon(Icons.eco_rounded),
            helperText: 'Exemplo: Milho Safrinha, Soja Grão, Trigo, Arroz Irrigado.',
            helperStyle: GoogleFonts.inter(fontSize: 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onFieldSubmitted: (v) => controller.updateDraft(draft.copyWith(cultura: v)),
        ),
      ],
    );
  }

  Widget _modoCardOption({
    required String title,
    required String sub,
    required IconData icon,
    required bool selected,
    required Color color,
    required double width,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : cs.outlineVariant.withOpacity(0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? color : cs.onSurfaceVariant.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: selected ? Colors.white : cs.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: selected ? color : cs.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withOpacity(0.4), width: 0.8),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  // ---------- 7. DESCARGA SELECTOR COM CARDS ----------

  Widget _descargaSelector(BuildContext context, AutomacaoController controller, ParametroAutomacaoModel draft) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _descargaOption(
            title: 'Contínua',
            desc: 'Descarga ininterrupta dos rolos',
            icon: Icons.sync_rounded,
            selected: draft.modoDescarga == 'continuo',
            width: isWide ? (constraints.maxWidth - 20) / 3 : constraints.maxWidth,
            onTap: () => controller.updateDraft(draft.copyWith(modoDescarga: 'continuo')),
          ),
          _descargaOption(
            title: 'Intermitente (Tempo)',
            desc: 'Ciclos fixos de descarga e repouso',
            icon: Icons.timer_rounded,
            selected: draft.modoDescarga == 'intermitente_tempo',
            width: isWide ? (constraints.maxWidth - 20) / 3 : constraints.maxWidth,
            onTap: () => controller.updateDraft(draft.copyWith(modoDescarga: 'intermitente_tempo')),
          ),
          _descargaOption(
            title: 'Intermitente (Umidade)',
            desc: 'Aciona com base no sensor de massa',
            icon: Icons.water_drop_rounded,
            selected: draft.modoDescarga == 'intermitente_umidade',
            width: isWide ? (constraints.maxWidth - 20) / 3 : constraints.maxWidth,
            onTap: () => controller.updateDraft(draft.copyWith(modoDescarga: 'intermitente_umidade')),
          ),
        ],
      );
    });
  }

  Widget _descargaOption({
    required String title,
    required String desc,
    required IconData icon,
    required bool selected,
    required double width,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    const color = Color(0xFF10B981);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.10) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : cs.outlineVariant.withOpacity(0.35),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? color : cs.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? color : cs.onSurface,
                    ),
                  ),
                  Text(desc, style: GoogleFonts.inter(fontSize: 9.5, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- 8. SEGURANÇA MINI-CARDS ----------

  Widget _securityCard({
    required BuildContext context,
    required String title,
    required String sub,
    required bool isCritical,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = value ? const Color(0xFF10B981) : (isCritical ? Colors.red : Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: value ? activeColor.withOpacity(0.06) : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? activeColor.withOpacity(0.35) : cs.outlineVariant.withOpacity(0.3),
          width: value ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCritical ? Icons.security_rounded : Icons.shield_outlined,
              size: 20,
              color: activeColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCritical)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'CRÍTICO',
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.red),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(sub, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _chungPfostCard(BuildContext context, AutomacaoController controller, ParametroAutomacaoModel draft) {
    final cs = Theme.of(context).colorScheme;
    final ue = controller.umidadeEquilibrio;
    final analise = controller.analiseSobSecagem;
    final taxaInfo = controller.avaliacaoTaxaSecagem;

    final bool isAlerta = analise['alerta'] as bool? ?? false;
    final bool taxaSegura = taxaInfo['seguro'] as bool? ?? true;
    final cardColor = isAlerta ? Colors.amber.shade700 : const Color(0xFF0EA5E9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calculate_rounded, size: 18, color: cardColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'EQUAÇÃO DE CHUNG-PFOST & CINÉTICA (ASAE D245.5)',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: cardColor,
                  ),
                ),
              ),
              if (ue != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ue do Ar: ${ue.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: cardColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isAlerta ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                size: 16,
                color: isAlerta ? Colors.amber.shade800 : const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  analise['mensagem'] as String? ?? '',
                  style: GoogleFonts.inter(fontSize: 11.5, height: 1.4, color: cs.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                taxaSegura ? Icons.speed_rounded : Icons.emergency_rounded,
                size: 16,
                color: taxaSegura ? const Color(0xFF10B981) : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  taxaInfo['aviso'] as String? ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: taxaSegura ? FontWeight.w500 : FontWeight.w700,
                    color: taxaSegura ? cs.onSurfaceVariant : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Nota agronômica: Secar grãos abaixo da umidade de equilíbrio consome lenha excessiva e gera quebra mecânica com redução direta do peso faturável na balança.',
            style: GoogleFonts.inter(fontSize: 10, fontStyle: FontStyle.italic, color: cs.onSurfaceVariant.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  // ---------- 9. CAMPOS NUMÉRICOS COM RANGE BARS ----------

  Widget _fieldGrid(BuildContext context, List<_FieldSpec> fields) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 580 ? 2 : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 116,
        ),
        itemCount: fields.length,
        itemBuilder: (context, i) => _numFieldWithRange(context, fields[i]),
      );
    });
  }

  Widget _numFieldWithRange(BuildContext context, _FieldSpec spec) {
    final cs = Theme.of(context).colorScheme;
    final double safeMin = spec.safeMin ?? spec.min;
    final double safeMax = spec.safeMax ?? spec.max;

    final double normalized = ((spec.value - spec.min) / (spec.max - spec.min == 0 ? 1 : spec.max - spec.min))
        .clamp(0.0, 1.0);

    final bool inSafe = spec.value >= safeMin && spec.value <= safeMax;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  spec.label,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tooltip(
                message: spec.help,
                child: Icon(Icons.info_outline_rounded, size: 15, color: cs.onSurfaceVariant.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('${spec.label}|${spec.value}'),
                  initialValue: spec.value % 1 == 0 ? spec.value.toInt().toString() : spec.value.toString(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixText: spec.unit,
                  ),
                  onFieldSubmitted: (v) {
                    final parsed = double.tryParse(v.replaceAll(',', '.'));
                    if (parsed != null) spec.onChanged(parsed);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Botões rápidos de decremento/incremento
              IconButton.filledTonal(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () => spec.onChanged(math.max(spec.min, spec.value - 1)),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => spec.onChanged(math.min(spec.max, spec.value + 1)),
              ),
            ],
          ),
          const Spacer(),
          // Range bar visual
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 4,
              width: double.infinity,
              color: cs.outlineVariant.withOpacity(0.2),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: normalized,
                child: Container(
                  color: inSafe ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${spec.min.toInt()}${spec.unit}',
                  style: GoogleFonts.inter(fontSize: 9, color: cs.onSurfaceVariant)),
              if (spec.safeMin != null && spec.safeMax != null)
                Text(
                  'Seguro: ${spec.safeMin!.toInt()}–${spec.safeMax!.toInt()}${spec.unit}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: inSafe ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                ),
              Text('${spec.max.toInt()}${spec.unit}',
                  style: GoogleFonts.inter(fontSize: 9, color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- 10. BANNER DE AMBIENTE & FIM DE SECAGEM ----------

  Widget _ambienteBanner(BuildContext context, AutomacaoController controller) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final tExt = controller.extTemp.value;
      final uExt = controller.extUmid.value;
      final co2Ext = controller.extCo2.value;
      final co2Int = controller.intCo2.value;
      final intern = controller.interiorAtual.value;
      final delta = controller.deltaT;
      final draft = controller.parametros.value;

      final width = MediaQuery.of(context).size.width;
      final isDesktop = width >= 1100;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 22 : 16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.wb_sunny_rounded, size: 20, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BALANÇO PSICOMÉTRICO (EXTERNO × INTERNO)',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: cs.primary,
                        ),
                      ),
                      Text(
                        'Compensação do esforço da fornalha baseada no microclima da unidade.',
                        style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.tonalIcon(
                  onPressed: draft == null
                      ? null
                      : () => CenariosAutomacaoModal.show(
                            context,
                            controller: controller,
                            draft: draft,
                            onNavigateToStep: (step) => _goTo(step),
                          ),
                  icon: const Icon(Icons.account_tree_rounded, size: 16),
                  label: const Text('Fluxos & Cenários', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Metric Cards
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: _deltaMetric(
                      cs,
                      'Estação Externa',
                      tExt == null ? '—' : '${tExt.toStringAsFixed(1)}°C',
                      uExt == null ? 'Sem umidade' : 'UR ${uExt.toStringAsFixed(0)}% • Fazenda',
                      Icons.cloud_queue_rounded,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _deltaMetric(
                      cs,
                      'Massa no Secador',
                      intern == null ? '—' : '${intern.temperature.toStringAsFixed(1)}°C',
                      'Sensor do interior',
                      Icons.thermostat_rounded,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _deltaMetric(
                      cs,
                      'Delta T de Ganho',
                      delta == null ? '—' : '${delta.toStringAsFixed(1)}°C',
                      controller.statusComparacao,
                      Icons.trending_up_rounded,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _deltaMetric(
                      cs,
                      'CO₂ Biológico',
                      co2Int == null ? '—' : '${co2Int.toStringAsFixed(0)} ppm',
                      co2Ext == null ? 'Monitoramento int.' : 'Ext: ${co2Ext.toStringAsFixed(0)} ppm',
                      Icons.grain_rounded,
                      Colors.teal,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _deltaMetric(
                    cs,
                    'Estação Externa',
                    tExt == null ? '—' : '${tExt.toStringAsFixed(1)}°C / ${uExt?.toStringAsFixed(0) ?? '—'}% UR',
                    'Microclima externo',
                    Icons.cloud_queue_rounded,
                    Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  _deltaMetric(
                    cs,
                    'Massa no Secador',
                    intern == null ? '—' : '${intern.temperature.toStringAsFixed(1)}°C',
                    'Última telemetria do secador',
                    Icons.thermostat_rounded,
                    Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  _deltaMetric(
                    cs,
                    'Delta T Térmico',
                    delta == null ? '—' : '${delta.toStringAsFixed(1)}°C',
                    controller.statusComparacao,
                    Icons.trending_up_rounded,
                    Colors.green,
                  ),
                ],
              ),
            const SizedBox(height: 14),
            _chungPfostBannerStrip(context, controller),
            const SizedBox(height: 16),
            _fimChecklist(context, controller),
          ],
        ),
      );
    });
  }

  Widget _deltaMetric(ColorScheme cs, String label, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10.5, color: cs.onSurfaceVariant)),
                Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chungPfostBannerStrip(BuildContext context, AutomacaoController controller) {
    final cs = Theme.of(context).colorScheme;
    final ue = controller.umidadeEquilibrio;
    final analise = controller.analiseSobSecagem;
    final bool isAlerta = analise['alerta'] as bool? ?? false;
    final Color stripeColor = isAlerta ? Colors.amber.shade700 : const Color(0xFF3B82F6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: stripeColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stripeColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: stripeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calculate_rounded, size: 18, color: stripeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'EQUAÇÃO DE CHUNG-PFOST (EQUILÍBRIO HIGROSCÓPICO)',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: stripeColor,
                      ),
                    ),
                    if (ue != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: stripeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Ue: ${ue.toStringAsFixed(1)}% b.u.',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: stripeColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  analise['mensagem'] as String? ?? 'Aguardando telemetria climática...',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isAlerta ? FontWeight.w600 : FontWeight.w400,
                    color: isAlerta ? Colors.amber.shade900 : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fimChecklist(BuildContext context, AutomacaoController controller) {
    final cs = Theme.of(context).colorScheme;
    final draft = controller.parametros.value;
    if (draft == null) return const SizedBox.shrink();

    final fim = controller.fimSecagem;
    final deltaEx = fim['deltaEx'] as double?;
    final acimaAmb = fim['acimaAmb'] as double?;
    final isDone = fim['fim'] as bool;

    final color = isDone ? const Color(0xFF10B981) : const Color(0xFF0EA5E9);

    Widget itemCheck(String label, String state, bool ok) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: ok ? const Color(0xFF10B981) : cs.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface))),
            Text(
              state,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ok ? const Color(0xFF10B981) : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                'CRITÉRIOS DE FIM DE SECAGEM',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDone ? 'PRONTO PARA DESCARGA' : 'EM PROCESSO',
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          itemCheck(
            'Delta Plenum–Exaustão < ${draft.deltaExaustaoFim.toStringAsFixed(0)}°C (parada de evaporação)',
            deltaEx == null ? 'Sem leitura' : '${deltaEx.toStringAsFixed(1)}°C',
            deltaEx != null && deltaEx < draft.deltaExaustaoFim,
          ),
          itemCheck(
            'Saída de grãos ≤ ${draft.saidaAcimaAmbienteMax.toStringAsFixed(0)}°C acima do ambiente',
            acimaAmb == null ? 'Sem leitura' : '+${acimaAmb.toStringAsFixed(1)}°C',
            acimaAmb != null && acimaAmb <= draft.saidaAcimaAmbienteMax,
          ),
          if (isDone) ...[
            const SizedBox(height: 6),
            Text(
              (fim['motivos'] as List<String>).join(' • '),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)),
            ),
          ],
        ],
      ),
    );
  }

  // ---------- 11. SAVE BAR COM DIFF COUNTER E DESCARTAR ----------

  Widget _saveBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant.withOpacity(0.35))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Obx(() {
          final dirty = controller.isDirty.value;
          final saving = controller.isSaving.value;
          final changes = controller.changedFieldsCount;

          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (dirty ? Colors.orange : const Color(0xFF10B981)).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  dirty ? Icons.edit_note_rounded : Icons.check_circle_rounded,
                  size: 18,
                  color: dirty ? Colors.orange : const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dirty ? 'Alterações não salvas' : 'Parâmetros sincronizados',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      dirty
                          ? '$changes campo(s) alterado(s) neste rascunho'
                          : 'Sincronizado com o gateway industrial',
                      style: GoogleFonts.inter(fontSize: 10.5, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (dirty) ...[
                TextButton(
                  onPressed: saving ? null : () => controller.revertDraft(),
                  child: Text('Descartar', style: GoogleFonts.inter(fontSize: 13, color: cs.error)),
                ),
                const SizedBox(width: 8),
              ],
              FilledButton.icon(
                onPressed: saving ? null : controller.save,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(
                  saving ? 'Gravando...' : 'Salvar',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
