import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/custos_controller.dart';

class CustosView extends GetView<CustosController> {
  const CustosView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, cs, isDesktop),
            const SizedBox(height: 20),
            _buildFilterBar(context, cs, isDesktop),
            const SizedBox(height: 20),
            _buildSummaryCards(context, cs, isDesktop),
            const SizedBox(height: 20),
            Expanded(child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = controller.filtered;
              if (list.isEmpty) {
                return _buildEmptyState(context);
              }
              if (isDesktop) {
                return SingleChildScrollView(
                  child: _buildTable(context, cs, list),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: list.length,
                itemBuilder: (_, i) => _buildMobileCard(context, list[i]),
              );
            })),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ColorScheme cs, bool isDesktop) {
    return Row(
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
                child: Row(
                  children: [
                    Text(
                      'Custos de Secagem',
                      style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                    const SizedBox(width: 10),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showCalculoInfoDialog(context),
                        child: Icon(Icons.info_outline_rounded, size: isDesktop ? 22 : 20, color: cs.primary.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop)
                Text('Acompanhe os custos operacionais dos processos de secagem finalizados.',
                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── FILTER BAR ──────────────────────────────────────────
  Widget _buildFilterBar(BuildContext context, ColorScheme cs, bool isDesktop) {
    return Obx(() {
      final secadores = controller.secadores;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<int?>(
              value: controller.selectedSecadorId.value,
              decoration: _dropDeco(cs, Icons.heat_pump_rounded),
              items: [
                DropdownMenuItem(value: null, child: Text('Todos os secadores', style: GoogleFonts.inter(color: cs.onSurface))),
                ...secadores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nome, style: GoogleFonts.inter(color: cs.onSurface)))),
              ],
              onChanged: controller.setSecador,
              style: GoogleFonts.inter(color: cs.onSurface, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 180,
            child: _dateField(context, cs, 'Data início', controller.dataInicio.value, (d) => controller.setDataInicio(d)),
          ),
          SizedBox(
            width: 180,
            child: _dateField(context, cs, 'Data fim', controller.dataFim.value, (d) => controller.setDataFim(d)),
          ),
          if (controller.selectedSecadorId.value != null || controller.dataInicio.value != null || controller.dataFim.value != null)
            TextButton.icon(
              onPressed: controller.limparFiltros,
              icon: const Icon(Icons.clear_rounded, size: 18),
              label: Text('Limpar', style: GoogleFonts.inter(fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
            ),
        ],
      );
    });
  }

  Widget _dateField(BuildContext context, ColorScheme cs, String hint, DateTime? value, ValueChanged<DateTime?> onChanged) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) onChanged(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: cs.primary.withOpacity(0.6)),
            const SizedBox(width: 8),
            Text(
              value != null ? DateFormat('dd/MM/yyyy').format(value) : hint,
              style: GoogleFonts.inter(fontSize: 13, color: value != null ? cs.onSurface : cs.onSurfaceVariant.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropDeco(ColorScheme cs, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 18, color: cs.primary.withOpacity(0.6)),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // ─── SUMMARY CARDS ───────────────────────────────────────
  Widget _buildSummaryCards(BuildContext context, ColorScheme cs, bool isDesktop) {
    return Obx(() {
      if (controller.filtered.isEmpty) return const SizedBox.shrink();

      final items = [
        _summaryCard(cs, 'Custo Total', 'R\$ ${_fmt(controller.totalGeral)}', Icons.monetization_on_rounded, cs.primary),
        _summaryCard(cs, 'Total Horas', '${_fmt(controller.totalHoras)} h', Icons.timer_rounded, Colors.blue),
        _summaryCard(cs, 'Processos', '${controller.totalProcessos}', Icons.receipt_long_rounded, Colors.teal),
        _summaryCard(cs, 'Custo Médio/h', 'R\$ ${_fmt(controller.totalHoras > 0 ? controller.totalGeral / controller.totalHoras : 0)}', Icons.speed_rounded, Colors.orange),
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((w) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(width: isDesktop ? 200 : 170, child: w),
          )).toList(),
        ),
      );
    });
  }

  Widget _summaryCard(ColorScheme cs, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── DESKTOP TABLE ───────────────────────────────────────
  Widget _buildTable(BuildContext context, ColorScheme cs, List list) {
    const flex = [5, 16, 14, 9, 11, 12, 12, 9];
    const gap = 6.0;

    Widget _header(String text) => Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.4), overflow: TextOverflow.ellipsis);

    List<Widget> _rowCells(List<Widget> cells) {
      final items = <Widget>[];
      for (int i = 0; i < cells.length; i++) {
        if (i > 0) items.add(const SizedBox(width: gap));
        items.add(Expanded(flex: flex[i], child: cells[i]));
      }
      return items;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(children: _rowCells([
            _header('#'),
            _header('Lote'),
            _header('Secador'),
            _header('Duração'),
            _header('Combustível'),
            _header('Energia'),
            _header('Mão de Obra'),
            _header('Total'),
          ])),
        ),
        ...list.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value as dynamic;
          final isEven = i % 2 == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isEven ? cs.surfaceContainerHighest.withOpacity(0.15) : null,
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.15))),
            ),
            child: Row(children: _rowCells([
              Text('${i + 1}', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.loteNumero ?? '---', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (p.loteCultura != null)
                    Text(p.loteCultura, style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.secadorNome ?? '---', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (p.secadorFonteCalor != null)
                    Text(p.secadorFonteCalor, style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant)),
                ],
              ),
              Text('${_fmt(p.duracaoHoras)} h', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface)),
              Text('R\$ ${_fmt(p.custoCombustivel)}', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface)),
              Text('R\$ ${_fmt(p.custoEnergia)}', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface)),
              Text('R\$ ${_fmt(p.custoMaoObra)}', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface)),
              Text('R\$ ${_fmt(p.custoTotal)}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary)),
            ])),
          );
        }),
      ],
    );
  }

  // ─── MOBILE CARD ─────────────────────────────────────────
  Widget _buildMobileCard(BuildContext context, dynamic p) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [cs.primary, cs.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.monetization_on_rounded, color: cs.onPrimary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.loteNumero ?? 'Processo #${p.processoId}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${p.secadorNome ?? '---'} • ${_fmt(p.duracaoHoras)} h', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                _statusBadge(cs, p.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _chip(cs, Icons.local_fire_department_rounded, 'Comb.', 'R\$ ${_fmt(p.custoCombustivel)}', Colors.orange),
                const SizedBox(width: 6),
                _chip(cs, Icons.bolt_rounded, 'Energia', 'R\$ ${_fmt(p.custoEnergia)}', Colors.amber),
                const SizedBox(width: 6),
                _chip(cs, Icons.handyman_rounded, 'MO', 'R\$ ${_fmt(p.custoMaoObra)}', Colors.blue),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip(cs, Icons.build_rounded, 'Manut.', 'R\$ ${_fmt(p.custoManutencao)}', Colors.purple),
                const SizedBox(width: 6),
                _chip(cs, Icons.trending_down_rounded, 'Deprec.', 'R\$ ${_fmt(p.custoDepreciacao)}', Colors.grey),
                const Spacer(),
                Text('R\$ ${_fmt(p.custoTotal)}',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: cs.primary)),
              ],
            ),
            if (p.custoPorTonAgua != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.water_drop_rounded, size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('R\$ ${_fmt(p.custoPorTonAgua)}/ton água removida', style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(ColorScheme cs, IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text('$label $value', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  void _showCalculoInfoDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 640,
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.primary, cs.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Como os custos são calculados?',
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text('Entenda a metodologia de cada componente.',
                              style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(backgroundColor: cs.onPrimary.withOpacity(0.15)),
                      color: cs.onPrimary,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoSection(cs, Icons.local_fire_department_rounded, Colors.orange, 'Combustível',
                        'Custo do combustível consumido durante todo o processo.',
                        'consumo_combustivel_hora × preco_combustivel × duracao_horas'),
                      const SizedBox(height: 20),
                      _infoSection(cs, Icons.bolt_rounded, Colors.amber, 'Energia Elétrica',
                        'Custo da energia elétrica gasta pelos motores e ventiladores.',
                        'consumo_energia_kwh × preco_kwh × duracao_horas'),
                      const SizedBox(height: 20),
                      _infoSection(cs, Icons.handyman_rounded, Colors.blue, 'Mão de Obra',
                        'Custo do operador responsável pelo monitoramento do secador.',
                        'custo_mao_obra_hora × duracao_horas'),
                      const SizedBox(height: 20),
                      _infoSection(cs, Icons.build_rounded, Colors.purple, 'Manutenção',
                        'Custo rateado de manutenção preventiva e corretiva do equipamento.',
                        'custo_manutencao_anual ÷ 365 × duracao_dias'),
                      const SizedBox(height: 20),
                      _infoSection(cs, Icons.trending_down_rounded, Colors.grey, 'Depreciação',
                        'Desgaste do equipamento rateado pela vida útil, considerando valor residual.',
                        '(custo_aquisicao − valor_residual) ÷ vida_util_anos ÷ 365 × duracao_dias'),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.functions_rounded, size: 24, color: cs.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Custo Total = Combustível + Energia + Mão de Obra + Manutenção + Depreciação',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Métricas de Eficiência', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                            const SizedBox(height: 12),
                            _metricRow(cs, 'Custo por hora', 'custo_total ÷ duracao_horas'),
                            const SizedBox(height: 8),
                            _metricRow(cs, 'Custo por tonelada de água removida', 'custo_total ÷ ((peso_inicial − peso_final) ÷ 1000)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Os cálculos utilizam os parâmetros de custo cadastrados no secador e os dados reais do processo (duração, peso do lote). Processos sem data de fim ou sem secador vinculado não são considerados.',
                        style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoSection(ColorScheme cs, IconData icon, Color color, String title, String description, String formula) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const SizedBox(height: 2),
              Text(description, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calculate_rounded, size: 14, color: color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(formula, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricRow(ColorScheme cs, String label, String formula) {
    return Row(
      children: [
        Icon(Icons.arrow_right_rounded, size: 18, color: cs.onSurfaceVariant),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
        Expanded(child: Text(formula, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: cs.onSurfaceVariant))),
      ],
    );
  }

  String _fmt(double v) => NumberFormat('#,##0.00', 'pt_BR').format(v);

  Widget _statusBadge(ColorScheme cs, String status) {
    final color = switch (status) {
      'Finalizada' => Colors.green,
      'Cancelada' => Colors.red,
      'Pausada' => Colors.orange,
      'Iniciada' => Colors.blue,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.5), borderRadius: BorderRadius.circular(28)),
            child: Icon(Icons.monetization_on_outlined, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text('Nenhum custo encontrado', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Finalize processos de secagem para ver os custos calculados aqui.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }
}
