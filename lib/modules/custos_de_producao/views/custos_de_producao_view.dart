import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/custos_de_producao_controller.dart';

class CustosDeProducaoView extends GetView<CustosDeProducaoController> {
  const CustosDeProducaoView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!isDesktop) ...[
                  IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                    color: cs.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Custos de Produção',
                          style: GoogleFonts.outfit(
                            fontSize: isDesktop ? 28 : 22,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (isDesktop)
                        Text(
                          'Secador de Fluxo Misto (Cavalete/Coluna) — Cálculo do custo real de secagem.',
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                children: [
                  _buildStepIndicator(context),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Obx(() {
                      switch (controller.currentStep.value) {
                        case 0: return _buildInfraestrutura(context);
                        case 1: return _buildLote(context);
                        case 2: return _buildInsumos(context);
                        case 3: return _buildResultados(context);
                        default: return const SizedBox.shrink();
                      }
                    }),
                  ),
                  const SizedBox(height: 24),
                  _buildStepNavigation(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final steps = [
      ('CAPEX', Icons.account_balance_rounded),
      ('Grão', Icons.grass_rounded),
      ('OPEX', Icons.local_fire_department_rounded),
      ('Resultado', Icons.bar_chart_rounded),
    ];

    return Obx(() => Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: controller.currentStep.value > i ~/ 2
                  ? cs.primary
                  : cs.surfaceContainerHighest,
            ),
          );
        }
        final idx = i ~/ 2;
        final isActive = controller.currentStep.value >= idx;
        final isCurrent = controller.currentStep.value == idx;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [cs.primary, cs.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isCurrent
                ? Border.all(color: cs.primary, width: 2)
                : null,
          ),
          child: Icon(
            steps[idx].$2,
            size: 18,
            color: isActive ? cs.onPrimary : cs.onSurfaceVariant.withOpacity(0.4),
          ),
        );
      }),
    ));
  }

  Widget _buildStepNavigation(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() => Row(
      children: [
        if (controller.currentStep.value > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.previousStep,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text('Anterior', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        if (controller.currentStep.value > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () {
              if (controller.currentStep.value < 3) {
                controller.nextStep();
              }
            },
            icon: Icon(
              controller.currentStep.value < 3
                  ? Icons.arrow_forward_rounded
                  : Icons.check_rounded,
              size: 18,
            ),
            label: Text(
              controller.currentStep.value < 3 ? 'Próximo' : 'Calcular',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    ));
  }

  // ──────────────────────────────────────────────
  // STAGE 1 — INFRAESTRUTURA (CAPEX / Custos Fixos)
  // ──────────────────────────────────────────────

  Widget _buildInfraestrutura(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Configuração de Infraestrutura', 'CAPEX / Custos Fixos — preenchimento único ou anual.'),
          const SizedBox(height: 24),
          _formCard(context, [
            _fieldLabel(cs, 'VALOR DE AQUISIÇÃO (R\$)'),
            const SizedBox(height: 8),
            _field(cs, TextEditingController(), 'Ex: 450.000,00', Icons.monetization_on_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'VIDA ÚTIL (ANOS)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(text: '20'), '20 anos', Icons.calendar_month_outlined, keyboardType: TextInputType.number),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'TAXA MANUTENÇÃO ANUAL (%)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(text: '3'), '3%', Icons.build_outlined, keyboardType: TextInputType.number),
                ])),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'ENCARGOS E IMPOSTOS (%)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(text: '10'), '10%', Icons.receipt_long_outlined, keyboardType: TextInputType.number),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'CICLOS ANUAIS'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(text: '5'), 'Mín. 5 ciclos', Icons.loop_rounded, keyboardType: TextInputType.number),
                ])),
              ],
            ),
          ]),
          const SizedBox(height: 20),
          _resultCard(context, [
            _resultRow(cs, 'Depreciação Anual', 'R\$ 22.500,00'),
            _resultRow(cs, 'Manutenção Anual', 'R\$ 13.500,00'),
            _resultRow(cs, 'Seguros + Impostos', 'R\$ 45.000,00'),
            _resultRow(cs, 'Custo Fixo Anual Total', 'R\$ 81.000,00', isTotal: true),
            _resultRow(cs, 'Custo Fixo por Ciclo', 'R\$ 16.200,00', isHighlight: true),
          ]),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STAGE 2 — LOTE / PARÂMETROS DO GRÃO
  // ──────────────────────────────────────────────

  Widget _buildLote(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Entrada do Lote e Parâmetros do Grão', 'Registre os dados do produto que chega da lavoura.'),
          const SizedBox(height: 24),
          _formCard(context, [
            _fieldLabel(cs, 'TIPO DE GRÃO'),
            const SizedBox(height: 8),
            _dropdown(cs, 'Soja', ['Soja', 'Milho', 'Trigo', 'Arroz', 'Café', 'Feijão'], Icons.grass_rounded),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'MASSA INICIAL (t)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(), 'Ex: 120', Icons.monitor_weight_outlined, keyboardType: TextInputType.number),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'UMIDADE INICIAL (%)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(), 'Ex: 18', Icons.water_drop_outlined, keyboardType: TextInputType.number),
                ])),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'UMIDADE FINAL ALVO (%)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(text: '13'), '13%', Icons.checklist_outlined, keyboardType: TextInputType.number),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'QUEBRA TÉCNICA (%)'),
                  const SizedBox(height: 8),
                  _readOnlyField(cs, '0,5%'),
                ])),
              ],
            ),
            const SizedBox(height: 20),
            _fieldLabel(cs, 'ÁGUA A REMOVER (kg)'),
            const SizedBox(height: 8),
            _readOnlyField(cs, '7.241 kg'),
          ]),
          const SizedBox(height: 20),
          _infoCard(context, Icons.info_outline_rounded,
            'A quebra técnica de 0,5% é aplicada automaticamente sobre a matéria seca do lote. '
            'A água a remover é calculada pela fórmula: Q(H₂O) = M × (Uᵢ - Uf) / (100 - Uf).'),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STAGE 3 — INSUMOS OPERACIONAIS (OPEX / Variáveis)
  // ──────────────────────────────────────────────

  Widget _buildInsumos(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Insumos Operacionais', 'OPEX / Custos Variáveis — gastos durante o funcionamento do secador.'),
          const SizedBox(height: 24),
          _formCard(context, [
            Text('Combustível', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 16),
            _fieldLabel(cs, 'FONTE DE COMBUSTÍVEL'),
            const SizedBox(height: 8),
            _dropdown(cs, 'Cavaco de Eucalipto', ['Lenha', 'Cavaco de Eucalipto', 'Biomassa'], Icons.local_fire_department_rounded),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'CONSUMO (kg / m³)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(), 'Ex: 2.500', Icons.tune_rounded, keyboardType: TextInputType.number),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'PREÇO UNITÁRIO (R\$/kg)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(), 'Ex: 0,35', Icons.attach_money_rounded, keyboardType: TextInputType.number),
                ])),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          _formCard(context, [
            Text('Energia Elétrica', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'POTÊNCIA TOTAL (cv / kW)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(), 'Ex: 75', Icons.bolt_rounded, keyboardType: TextInputType.number),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'TEMPO DE OPERAÇÃO (h)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(), 'Ex: 180', Icons.schedule_rounded, keyboardType: TextInputType.number),
                ])),
              ],
            ),
            const SizedBox(height: 20),
            _fieldLabel(cs, 'TARIFA DA CONCESSIONÁRIA (R\$/kWh)'),
            const SizedBox(height: 8),
            _field(cs, TextEditingController(), 'Ex: 0,75', Icons.electric_bolt_rounded, keyboardType: TextInputType.number),
          ]),
          const SizedBox(height: 16),
          _formCard(context, [
            Text('Mão de Obra', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'NÚMERO DE OPERADORES'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(text: '2'), 'Ex: 2', Icons.people_outlined, keyboardType: TextInputType.number),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'VALOR DA DIÁRIA (R\$)'),
                  const SizedBox(height: 8),
                  _field(cs, TextEditingController(), 'Ex: 180,00', Icons.payments_outlined, keyboardType: TextInputType.number),
                ])),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'ENCARGOS SOCIAIS (%)'),
                  const SizedBox(height: 8),
                  _readOnlyField(cs, '68%'),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel(cs, 'TOTAL MÃO DE OBRA / CICLO'),
                  const SizedBox(height: 8),
                  _readOnlyField(cs, 'R\$ 604,80'),
                ])),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // STAGE 4 — RESULTADOS / CONSOLIDAÇÃO
  // ──────────────────────────────────────────────

  Widget _buildResultados(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Processamento e Consolidação do Custo', 'Resultado final do custo real da operação de secagem.'),
          const SizedBox(height: 24),
          _resultCard(context, [
            Text('Custos Variáveis (OPEX)', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            _resultRow(cs, 'Combustível por Tonelada', 'R\$ 7,29'),
            const SizedBox(height: 4),
            _resultRow(cs, 'Energia Elétrica por Tonelada', 'R\$ 4,22'),
            const SizedBox(height: 4),
            _resultRow(cs, 'Mão de Obra por Tonelada', 'R\$ 5,04'),
            const SizedBox(height: 4),
            _resultRow(cs, 'Total OPEX por Tonelada', 'R\$ 16,55', isTotal: true),
          ]),
          const SizedBox(height: 16),
          _resultCard(context, [
            Text('Custos Fixos (CAPEX)', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            _resultRow(cs, 'Custo Fixo Diluído por Tonelada', 'R\$ 6,48'),
            const SizedBox(height: 4),
            _resultRow(cs, 'Depreciação no Ciclo', 'R\$ 4.500,00'),
            const SizedBox(height: 4),
            _resultRow(cs, 'Manutenção no Ciclo', 'R\$ 2.700,00'),
          ]),
          const SizedBox(height: 16),
          _resultCard(context, [
            Text('Indicadores de Eficiência', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            _resultRow(cs, 'Consumo Específico (kcal/kg água)', '785 kcal/kg'),
            _metricIndicator(cs, 785, 750, 'Ideal: 750 kcal/kg'),
            const SizedBox(height: 8),
            _resultRow(cs, 'Volume Processado no Ciclo', '120 t'),
            _resultRow(cs, 'Custo por kg de Água Removida', 'R\$ 0,032'),
          ]),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('CUSTO TOTAL DE SECAGEM', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onPrimary.withOpacity(0.8), letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text('R\$ 23,03 / t', style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: cs.onPrimary)),
                const SizedBox(height: 4),
                Text('por tonelada processada', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.7))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _infoCard(context, Icons.lightbulb_outline_rounded,
            'Com automação da fornalha (cavacos), este custo pode reduzir em até 40,92% '
            'no combustível. Utilize o secador intensamente para diluir os custos fixos.'),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // REUSABLE WIDGETS
  // ──────────────────────────────────────────────

  Widget _sectionHeader(BuildContext context, String title, String subtitle) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ETAPA ${controller.currentStep.value + 1} / 4',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        )),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _formCard(BuildContext context, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _resultCard(BuildContext context, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, IconData icon, String message) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.tertiary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: cs.tertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(ColorScheme cs, String label, String value, {bool isTotal = false, bool isHighlight = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 12 : 8),
      decoration: BoxDecoration(
        border: isTotal ? Border(top: BorderSide(color: cs.primary.withOpacity(0.2)), bottom: BorderSide(color: cs.primary.withOpacity(0.2))) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(
            fontSize: isTotal ? 13 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isHighlight ? cs.primary : cs.onSurfaceVariant,
          )),
          Text(value, style: GoogleFonts.inter(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal || isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight ? cs.primary : cs.onSurface,
          )),
        ],
      ),
    );
  }

  Widget _metricIndicator(ColorScheme cs, double current, double target, String label) {
    final ratio = (current / target).clamp(0, 1.5).toDouble();
    final barColor = ratio <= 1.0 ? Colors.green : ratio <= 1.2 ? Colors.orange : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio > 1 ? 1.0 : ratio,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _fieldLabel(ColorScheme cs, String label) {
    return Text(label, style: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: cs.primary,
      letterSpacing: 0.8,
    ));
  }

  Widget _field(ColorScheme cs, TextEditingController ctl, String hint, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: ctl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant.withOpacity(0.5)),
        prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.6)),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.primary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _readOnlyField(ColorScheme cs, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.surfaceContainerHighest),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: cs.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(width: 10),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _dropdown(ColorScheme cs, String initialValue, List<String> items, IconData icon) {
    final selected = initialValue.obs;
    return Obx(() => DropdownButtonFormField<String>(
      value: selected.value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.6)),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
      dropdownColor: cs.surfaceContainerLow,
      items: items.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
      onChanged: (v) => selected.value = v!,
    ));
  }
}
