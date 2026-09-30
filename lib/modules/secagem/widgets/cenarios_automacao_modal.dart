import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/parametro_automacao_model.dart';
import '../controllers/automacao_controller.dart';

class CenariosAutomacaoModal extends StatefulWidget {
  final AutomacaoController controller;
  final ParametroAutomacaoModel draft;
  final void Function(int stepIndex)? onNavigateToStep;

  const CenariosAutomacaoModal({
    super.key,
    required this.controller,
    required this.draft,
    this.onNavigateToStep,
  });

  static Future<void> show(
    BuildContext context, {
    required AutomacaoController controller,
    required ParametroAutomacaoModel draft,
    void Function(int stepIndex)? onNavigateToStep,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CenariosAutomacaoModal(
        controller: controller,
        draft: draft,
        onNavigateToStep: onNavigateToStep,
      ),
    );
  }

  @override
  State<CenariosAutomacaoModal> createState() => _CenariosAutomacaoModalState();
}

class _CenariosAutomacaoModalState extends State<CenariosAutomacaoModal> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 12,
        vertical: isWide ? 32 : 16,
      ),
      child: Container(
        width: isWide ? 1000 : double.infinity,
        height: isWide ? 760 : size.height * 0.9,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.45 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.primary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_tree_rounded, size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ARQUITETURA & FLUXOS DA AUTOMAÇÃO',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          'Entenda de forma visual como o gateway gerencia a fornalha, a descarga e as salvaguardas em campo.',
                          style: GoogleFonts.inter(fontSize: 11.5, color: cs.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Fechar',
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: cs.surfaceContainerLow.withOpacity(0.5),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _tabButton(0, 'Ciclo de Secagem', Icons.sync_rounded, const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    _tabButton(1, 'Salvaguardas & Segurança', Icons.shield_rounded, const Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    _tabButton(2, 'Clima & Chung-Pfost', Icons.thermostat_auto_rounded, const Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    _tabButton(3, 'Níveis de Autonomia', Icons.tune_rounded, const Color(0xFF8B5CF6)),
                  ],
                ),
              ),
            ),

            // Body content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(_activeTab),
                    child: _buildTabContent(context),
                  ),
                ),
              ),
            ),

            // Modal Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                border: Border(top: BorderSide(color: cs.outlineVariant.withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Os fluxos operam com base nas leituras dos sensores instalados e nos parâmetros ajustados neste secador.',
                      style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(int index, String title, IconData icon, Color color) {
    final isSelected = _activeTab == index;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : cs.outlineVariant.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_activeTab) {
      case 0:
        return _buildCicloSecagemTab(context);
      case 1:
        return _buildSalvaguardasTab(context);
      case 2:
        return _buildClimaChungPfostTab(context);
      case 3:
      default:
        return _buildNiveisAutonomiaTab(context);
    }
  }

  // ---------- TAB 1: CICLO DE SECAGEM ----------

  Widget _buildCicloSecagemTab(BuildContext context) {
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabIntroBanner(
          title: 'Fluxo Contínuo vs. Intermitente Inteligente',
          sub: 'Como a massa de grãos transita pelo secador, recebe o ar quente do plenum e equaliza a umidade no repouso.',
          icon: Icons.sync_rounded,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 20),
        _flowStepCard(
          stepNumber: 1,
          title: 'Partida Forçada de Ventilação',
          sub: 'O ventilador axial/centrífugo é acionado na potência configurada (${draft.ventilacaoPct.toStringAsFixed(0)}%). O sensor confirma fluxo positivo antes de liberar o combustível.',
          detail: 'Salvaguarda NR-12: Fornalha não acende sem pressão comprovada no plenum.',
          icon: Icons.air_rounded,
          color: Colors.cyan,
        ),
        _connectorLine(Colors.cyan),
        _flowStepCard(
          stepNumber: 2,
          title: 'Modulação Térmica do Plenum (Alvo: ${draft.tempArAlvo.toStringAsFixed(0)}°C)',
          sub: 'A fornalha regula a chama para atingir ${draft.tempArAlvo.toStringAsFixed(0)}°C com histerese de ±${draft.histerese.toStringAsFixed(1)}°C, garantindo que a massa de grãos não ultrapasse ${draft.tempMassaMax.toStringAsFixed(0)}°C.',
          detail: 'Proteção biológica: Massa acima de 50°C trinca milho e anula vigor de sementes.',
          icon: Icons.local_fire_department_rounded,
          color: Colors.orange,
        ),
        _connectorLine(Colors.orange),
        _flowStepCard(
          stepNumber: 3,
          title: 'Descarga Ativa ON (${draft.descargaOnMin.toStringAsFixed(0)} min)',
          sub: 'Os rolos basculantes giram a ${draft.velocidadeRoloPct.toStringAsFixed(0)}% da velocidade. A camada inferior de grãos secos desce pela coluna para dar espaço aos grãos úmidos da câmara superior.',
          detail: 'Regra dos 18%: Se a umidade de entrada for > 18%, a descarga opera obrigatoriamente em ciclos intermitentes.',
          icon: Icons.arrow_downward_rounded,
          color: const Color(0xFF10B981),
        ),
        _connectorLine(const Color(0xFF10B981)),
        _flowStepCard(
          stepNumber: 4,
          title: 'Repouso & Têmpera OFF (${draft.descargaOffMin.toStringAsFixed(0)} min - Lei de Fick)',
          sub: 'Os rolos pausam. A água migra do centro para a periferia do grão por difusão natural sem queima de lenha.',
          detail: 'Economia e qualidade: Reduz em até 20% o consumo térmico e previne fissuras térmicas no endosperma.',
          icon: Icons.pause_circle_filled_rounded,
          color: Colors.indigo,
        ),
        _connectorLine(Colors.indigo),
        _flowStepCard(
          stepNumber: 5,
          title: 'Detecção de Fim de Secagem (ΔT Plenum–Exaustão < ${draft.deltaExaustaoFim.toStringAsFixed(0)}°C)',
          sub: 'Conforme a massa seca, o ar de exaustão sai mais quente porque não perde mais calor latente evaporando água. Ao cruzar o limiar, o lote é considerado pronto.',
          detail: 'Meta comercial: Atinge ${draft.umidadeAlvo.toStringAsFixed(1)}% b.u. com precisão psicrométrica.',
          icon: Icons.flag_rounded,
          color: Colors.green,
        ),
        _connectorLine(Colors.green),
        _flowStepCard(
          stepNumber: 6,
          title: 'Resfriamento Final & Descarga Segura',
          sub: 'A fornalha é desligada e os ventiladores continuam até que o grão saia no máximo a ${draft.saidaAcimaAmbienteMax.toStringAsFixed(0)}°C acima do ambiente.',
          detail: 'Armazenagem segura: Impede choque térmico e condensação de umidade (sweating) no silo pulmão.',
          icon: Icons.ac_unit_rounded,
          color: Colors.blue,
        ),
      ],
    );
  }

  // ---------- TAB 2: SALVAGUARDAS ----------

  Widget _buildSalvaguardasTab(BuildContext context) {
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabIntroBanner(
          title: 'Matriz de Intertravamentos e Emergências Críticas',
          sub: 'O gateway atua como controlador de segurança ativo: se qualquer limite for violado, o secador entra em modo defensivo na mesma fração de segundo.',
          icon: Icons.shield_rounded,
          color: const Color(0xFFEF4444),
        ),
        const SizedBox(height: 20),
        _matrixCard(
          title: 'Queda de Energia ou Falha do Ventilador',
          status: draft.intertravamentoFornalha ? 'INTERTRAVADO ATIVO' : 'DESPROTEGIDO',
          statusOk: draft.intertravamentoFornalha,
          causa: 'Pressostato do plenum ou feedback do inversor acusa vazão de ar zero.',
          reacaoGateway: 'Corta imediatamente a alimentação de biomassa/gás da fornalha. Impede acúmulo de monóxido e risco de explosão no túnel.',
          criticidade: 'CRÍTICA (NR-12)',
          icon: Icons.power_off_rounded,
        ),
        const SizedBox(height: 14),
        _matrixCard(
          title: 'Pico Térmico Acima de ${draft.tempArMax.toStringAsFixed(0)}°C (Corte Máximo)',
          status: 'CORTE AUTOMÁTICO ARMADO',
          statusOk: true,
          causa: 'Fornalha superaquecida ou duto obstruído ultrapassando a temperatura de corte.',
          reacaoGateway: 'Abre damper de ar frio de alívio e desliga a alimentação de combustível. Dispara alarme visual e notificação imediata aos operadores.',
          criticidade: 'PROTEÇÃO DO PATRIMÔNIO',
          icon: Icons.whatshot_rounded,
        ),
        const SizedBox(height: 14),
        _matrixCard(
          title: 'Risco de Fogo / Fumaça no Secador',
          status: draft.corteEmergenciaIncendio ? 'SISTEMA CONTRA INCÊNDIO ATIVO' : 'DESATIVADO',
          statusOk: draft.corteEmergenciaIncendio,
          causa: 'Sensor óptico/térmico acusa início de combustão na câmara de secagem.',
          reacaoGateway: 'Extingue o soprador da fornalha, fecha dampers de oxigênio para sufocar o foco e aciona válvula de dilúvio/exaustores de emergência.',
          criticidade: 'SEGURANÇA DE VIDAS (NR-13)',
          icon: Icons.fire_extinguisher_rounded,
        ),
        const SizedBox(height: 14),
        _matrixCard(
          title: 'Sobreaquecimento da Massa (> ${draft.tempMassaMax.toStringAsFixed(0)}°C)',
          status: 'LIMITADOR FISIOLÓGICO ATIVO',
          statusOk: true,
          causa: 'Grãos estagnados em canaletas internas acumulando calor excessivo.',
          reacaoGateway: 'Aumenta a velocidade de descarga dos rolos para promover recirculação e abaixa o setpoint de ar para resfriar a massa.',
          criticidade: 'QUALIDADE BIOLÓGICA',
          icon: Icons.grain_rounded,
        ),
      ],
    );
  }

  // ---------- TAB 3: CLIMA & CHUNG-PFOST ----------

  Widget _buildClimaChungPfostTab(BuildContext context) {
    final ue = widget.controller.umidadeEquilibrio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabIntroBanner(
          title: 'Balanço Psicométrico & Equação de Chung-Pfost (ASAE D245.5)',
          sub: 'O secador não opera isolado: o clima externo define se o ar está ajudando a secar ou se exigirá compensação térmica.',
          icon: Icons.thermostat_auto_rounded,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology_alt_rounded, size: 28, color: Color(0xFF3B82F6)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O que é a Umidade de Equilíbrio (Ue)?',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3B82F6)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'É o limite físico da natureza: para a Temperatura e Umidade Relativa do dia, o grão nunca secará abaixo de Ue sem gastar calor artificial. A equação de Chung-Pfost calcula esse ponto continuamente.',
                      style: GoogleFonts.inter(fontSize: 11.5, height: 1.45),
                    ),
                  ],
                ),
              ),
              if (ue != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('Ue Hoje', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600)),
                      Text('${ue.toStringAsFixed(1)}%',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF3B82F6))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _climaScenarioCard(
          title: 'Cenário A: Dia Frio e Chuvoso (UR > 85%)',
          impacto: 'Baixo potencial evaporativo natural',
          acao: 'O controlador detecta risco de condensação e estende o tempo de repouso OFF para permitir que o grão dissipe umidade antes de avançar.',
          beneficio: 'Impede formação de crostas e grãos colados nas paredes da coluna.',
          icon: Icons.water_rounded,
          color: Colors.blueGrey,
        ),
        const SizedBox(height: 12),
        _climaScenarioCard(
          title: 'Cenário B: Dia Seco e Ensolarado (UR < 45%)',
          impacto: 'Alto potencial secante natural',
          acao: 'O gateway aproveita o ar seco da estação e reduz a modulação de combustível da fornalha em até 15%, mantendo a mesma curva de saída.',
          beneficio: 'Economia direta de lenha/gás aproveitando a termodinâmica ambiente.',
          icon: Icons.wb_sunny_rounded,
          color: Colors.amber,
        ),
        const SizedBox(height: 12),
        _climaScenarioCard(
          title: 'Cenário C: Prevenção de Sob-Secagem (Overdrying Protection)',
          impacto: 'Proteção financeira contra perda de peso',
          acao: 'Se o operador definir meta de 11.5% quando o contrato comercial paga por 14.0%, o sistema alerta: cada 1% de água retirada a mais são 10 kg a menos por tonelada na balança.',
          beneficio: 'Evita perder toneladas faturáveis e protege o grão contra trincas mecânicas.',
          icon: Icons.price_check_rounded,
          color: const Color(0xFF10B981),
        ),
      ],
    );
  }

  // ---------- TAB 4: NÍVEIS DE AUTONOMIA ----------

  Widget _buildNiveisAutonomiaTab(BuildContext context) {
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabIntroBanner(
          title: 'Comparativo dos Modos de Operação',
          sub: 'Você escolhe o quanto o sistema intervém: desde um painel de instrumentos passivo até controle autônomo com inteligência de ponta.',
          icon: Icons.tune_rounded,
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 20),
        _modoDetailCard(
          title: 'Modo Manual',
          badge: 'SUPERVISÓRIO AUDITOR',
          selected: draft.modoOperacao == 'manual',
          sub: 'O operador comanda as botoeiras e inversores físicos no painel elétrico da fazenda.',
          oQueOGatewayFaz: 'Monitora todos os sensores, plota telemetria em tempo real e dispara alarmes sonoros/push se as faixas forem violadas.',
          quandoUsar: 'Ideal para testes de comissionamento, queima inicial de fornalha ou manutenção periódica.',
          icon: Icons.handyman_rounded,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(height: 14),
        _modoDetailCard(
          title: 'Modo Semi-Automático',
          badge: 'COPILOTO COM VALIDAÇÃO',
          selected: draft.modoOperacao == 'semi',
          sub: 'O sistema calcula as curvas ótimas e sugere os ajustes de descarga e chama.',
          oQueOGatewayFaz: 'Envia avisos no app: "Sugerido aumentar repouso em 3 min para equalizar lote". O operador confirma com um toque antes da ação.',
          quandoUsar: 'Ideal para operadores experientes que desejam validação humana de cada manobra operacional.',
          icon: Icons.touch_app_rounded,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 14),
        _modoDetailCard(
          title: 'Modo Automático (100% Autônomo)',
          badge: 'GATEWAY EM CONTROLE TOTAL',
          selected: draft.modoOperacao == 'auto',
          sub: 'O algoritmo em malha fechada atua diretamente sobre os inversores e válvulas de modulação.',
          oQueOGatewayFaz: 'Mantém a temperatura do plenum na meta, executa os ciclos de descarga/têmpera e desliga o fogo automaticamente no fim de secagem.',
          quandoUsar: 'Operação padrão de safra para maximizar economia de energia, rendimento e uniformidade de umidade.',
          icon: Icons.smart_toy_rounded,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 14),
        _modoDetailCard(
          title: 'Modo IA (Controle Preditivo Neural - P&D Futuro)',
          badge: 'EM ESTUDOS FUTUROS (ROADMAP)',
          selected: draft.modoOperacao == 'ai',
          sub: 'Redes neurais e controle preditivo MPC para prever frentes térmicas antes dos sensores reagirem.',
          oQueOGatewayFaz: 'Em estudos: antecipa oscilações climáticas das próximas 3 horas, modela a cinética interna do grão via gêmeo digital e modula biomassa com aprendizado por reforço para consumo zero de energia excedente.',
          quandoUsar: 'Reservado para versões futuras da plataforma Smart Secagem (linha de pesquisa avançada). Atualmente atua como simulação conceitual.',
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  // ---------- WIDGETS AUXILIARES DE RENDERIZAÇÃO ----------

  Widget _tabIntroBanner({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 2),
                Text(sub, style: GoogleFonts.inter(fontSize: 11.5, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _flowStepCard({
    required int stepNumber,
    required String title,
    required String sub,
    required String detail,
    required IconData icon,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(sub, style: GoogleFonts.inter(fontSize: 11.5, height: 1.4, color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    detail,
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectorLine(Color color) {
    return Center(
      child: Container(
        width: 2,
        height: 22,
        color: color.withOpacity(0.4),
      ),
    );
  }

  Widget _matrixCard({
    required String title,
    required String status,
    required bool statusOk,
    required String causa,
    required String reacaoGateway,
    required String criticidade,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final color = statusOk ? const Color(0xFFEF4444) : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
                    Text(criticidade, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (statusOk ? const Color(0xFF10B981) : Colors.red).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: statusOk ? const Color(0xFF10B981) : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Gatilho de detecção: $causa', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bolt_rounded, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ação imediata do Gateway: $reacaoGateway',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _climaScenarioCard({
    required String title,
    required String impacto,
    required String acao,
    required String beneficio,
    required IconData icon,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Impacto ambiental: $impacto', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('Ação inteligente: $acao', style: GoogleFonts.inter(fontSize: 11.5, color: cs.onSurface)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(6)),
            child: Text('Ganho operacional: $beneficio',
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _modoDetailCard({
    required String title,
    required String badge,
    required bool selected,
    required String sub,
    required String oQueOGatewayFaz,
    required String quandoUsar,
    required IconData icon,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.08) : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : cs.outlineVariant.withOpacity(0.35),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(title, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.onSurface)),
                    Text(badge, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
                  ],
                ),
              ),
              if (selected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                  child: Text('EM USO NESTE SECADOR',
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(sub, style: GoogleFonts.inter(fontSize: 11.5, color: cs.onSurface)),
          const SizedBox(height: 6),
          Text('Papel da automação: $oQueOGatewayFaz',
              style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('Indicação: $quandoUsar',
              style: GoogleFonts.inter(fontSize: 10.5, fontStyle: FontStyle.italic, color: color)),
        ],
      ),
    );
  }
}
