import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/processo_model.dart';
import '../controllers/processos_controller.dart';
import '../../batch_management/controllers/batch_management_controller.dart';
import '../../batch_management/views/batch_management_view.dart';

class ProcessosView extends GetView<ProcessosController> {
  const ProcessosView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 32 : 16, isDesktop ? 32 : 16, 0),
            child: _buildHeader(context),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 0, isDesktop ? 32 : 16, 0),
            child: Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: () => controller.getProcessos(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Atualizar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _showEtapasModal(context, isDesktop),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Nova Atividade', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildProcessosSalvosTab(context, isDesktop, cs)),
        ],
      ),
    );
  }

  Widget _buildProcessosSalvosTab(BuildContext context, bool isDesktop, ColorScheme cs) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.processos.isEmpty) {
        return Center(child: _buildEmptyState(context));
      }
      final grouped = _groupByLote(controller.processos);
      return Padding(
        padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 0, isDesktop ? 32 : 16, 16),
        child: SingleChildScrollView(
          child: isDesktop
              ? _buildProcessosTable(context, cs, grouped)
              : _buildProcessosCompactList(context, cs, grouped),
        ),
      );
    });
  }

  Map<String, List<ProcessoModel>> _groupByLote(List<ProcessoModel> processos) {
    final map = <String, List<ProcessoModel>>{};
    for (final p in processos) {
      final key = p.loteNumero ?? 'Sem Lote';
      map.putIfAbsent(key, () => []);
      map[key]!.add(p);
    }
    return map;
  }

  Widget _buildProcessosTable(BuildContext context, ColorScheme cs, Map<String, List<ProcessoModel>> grouped) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    const flex = [11, 7, 8, 11, 11, 7, 8, 10, 9, 9, 10];
    const gap = 8.0;

    Widget _header(String text) => Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.5), overflow: TextOverflow.ellipsis);

    Widget _cell(String text, {bool bold = false}) => Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: cs.onSurface), overflow: TextOverflow.ellipsis, maxLines: 1);

    List<Widget> _rowCells(List<Widget> cells) {
      final items = <Widget>[];
      for (int i = 0; i < cells.length; i++) {
        if (i > 0) items.add(const SizedBox(width: gap));
        items.add(Expanded(flex: flex[i], child: cells[i]));
      }
      return items;
    }

    final entries = grouped.entries.toList();
    final sections = <Widget>[];

    sections.add(Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(children: _rowCells([
        _header('Lote'),
        _header('Tipo'),
        _header('Cultura'),
        _header('Início'),
        _header('Fim'),
        _header('Duração'),
        _header('Status'),
        _header('Responsável'),
        _header('Secador'),
        _header('Silo'),
        _header('Ações'),
      ])),
    ));

    for (int g = 0; g < entries.length; g++) {
      final loteKey = entries[g].key;
      final processos = entries[g].value;

      sections.add(Container(
        padding: EdgeInsets.fromLTRB(16, g > 0 ? 20 : 0, 16, 8),
        child: Row(
          children: [
            Icon(Icons.inventory_2_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(loteKey, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('${processos.length} ${processos.length == 1 ? 'atividade' : 'atividades'}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
            ),
          ],
        ),
      ));

      for (final p in processos) {
        final statusColor = _getStatusColor(p.status);
        final durationStr = _formatDuracao(_calcularDuracao(p));
        sections.add(InkWell(
          onTap: () => _showProcessoDetails(context, p),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: p.status == 'Iniciada' ? cs.primary.withOpacity(0.04) : Colors.transparent,
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.2))),
            ),
            child: Row(children: _rowCells([
              _cell(p.loteNumero ?? '---', bold: true),
              _tipoCell(cs, p.tipoProcesso),
              _cell(p.loteCultura ?? '---'),
              _cell(df.format(p.dataInicio.toLocal())),
              _cell(p.dataFim != null ? df.format(p.dataFim!.toLocal()) : '---'),
              _cell(durationStr),
              _statusBadge(cs, p.status, statusColor),
              _cell(p.responsavelNome ?? '---'),
              _cell(p.secadorNome ?? '---'),
              _cell(p.siloNome ?? '---'),
              _actionButtons(p),
            ])),
          ),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections);
  }

  Widget _buildProcessosCompactList(BuildContext context, ColorScheme cs, Map<String, List<ProcessoModel>> grouped) {
    final df = DateFormat('dd/MM HH:mm');
    final entries = grouped.entries.toList();
    final sections = <Widget>[];

    for (int g = 0; g < entries.length; g++) {
      final loteKey = entries[g].key;
      final processos = entries[g].value;

      sections.add(Padding(
        padding: EdgeInsets.fromLTRB(4, g > 0 ? 20 : 0, 4, 8),
        child: Row(
          children: [
            Icon(Icons.inventory_2_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(loteKey, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('${processos.length} ${processos.length == 1 ? 'atividade' : 'atividades'}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
            ),
          ],
        ),
      ));

      for (final p in processos) {
        final statusColor = _getStatusColor(p.status);
        final durationStr = _formatDuracao(_calcularDuracao(p));
        sections.add(Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: cs.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant.withOpacity(0.3)),
          ),
          child: InkWell(
            onTap: () => _showProcessoDetails(context, p),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _tipoIcon(p.tipoProcesso, 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.loteNumero != null ? 'Lote ${p.loteNumero}' : 'Avulso', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                          Text(p.tipoProcesso, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    _statusBadge(cs, p.status, statusColor),
                  ],
                ),
                const SizedBox(height: 12),
                _compactRow(cs, Icons.calendar_today_rounded, 'Início', df.format(p.dataInicio.toLocal()),
                    Icons.timer_rounded, 'Duração', durationStr),
                const SizedBox(height: 6),
                _compactRow(cs, Icons.person_outline_rounded, 'Resp.', p.responsavelNome ?? '---',
                    Icons.grass, 'Cultura', p.loteCultura ?? '---'),
                if (p.secadorNome != null || p.siloNome != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (p.secadorNome != null) ...[
                        Icon(Icons.settings_input_component_rounded, size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(child: Text(p.secadorNome!, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant))),
                      ],
                      if (p.siloNome != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.warehouse_rounded, size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(child: Text(p.siloNome!, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant))),
                      ],
                    ],
                  ),
                ],
                if (p.dataFim != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.check_circle_outline_rounded, size: 13, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Fim: ${df.format(p.dataFim!.toLocal())}', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
                  ]),
                ],
                const SizedBox(height: 10),
                _actionButtons(p),
              ],
            ),
          ),
          ),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections);
  }

  Widget _compactRow(ColorScheme cs, IconData icon1, String label1, String value1, IconData icon2, String label2, String value2) {
    return Row(
      children: [
        Icon(icon1, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text('$label1: ', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
        Expanded(child: Text(value1, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface))),
        const SizedBox(width: 8),
        Icon(icon2, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text('$label2: ', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
        Expanded(child: Text(value2, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface))),
      ],
    );
  }

  Widget _actionBtn(BuildContext context, IconData icon, String label, Color color, Future<void> Function() onPressed) {
    return SizedBox(
      height: 28,
      child: TextButton.icon(
        onPressed: () async {
          await onPressed();
          controller.getProcessos();
        },
        icon: Icon(icon, size: 14),
        label: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: color.withOpacity(0.3))),
          backgroundColor: color.withOpacity(0.08),
        ),
      ),
    );
  }

  Widget _actionButtons(ProcessoModel p) {
    Widget buttons;
    if (p.status == 'Iniciada') {
      buttons = Row(mainAxisSize: MainAxisSize.min, children: [
        _actionBtn(Get.context!, Icons.pause_rounded, 'Pausar', const Color(0xFF0288D1), () => controller.changeStatus(p, 'Pausada')),
        const SizedBox(width: 4),
        _actionBtn(Get.context!, Icons.stop_rounded, 'Parar', Colors.red, () => controller.changeStatus(p, 'Finalizada')),
      ]);
    } else if (p.status == 'Pausada') {
      buttons = Row(mainAxisSize: MainAxisSize.min, children: [
        _actionBtn(Get.context!, Icons.play_arrow_rounded, 'Iniciar', Colors.green, () => controller.changeStatus(p, 'Iniciada')),
        const SizedBox(width: 4),
        _actionBtn(Get.context!, Icons.cancel_outlined, 'Cancelar', Colors.red, () => controller.changeStatus(p, 'Cancelada')),
      ]);
    } else {
      return const SizedBox.shrink();
    }
    return FittedBox(fit: BoxFit.scaleDown, child: buttons);
  }

  Widget _tipoCell(ColorScheme cs, String tipo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tipoIcon(tipo, 20),
        const SizedBox(width: 6),
        Text(tipo, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface)),
      ],
    );
  }

  Widget _tipoIcon(String tipo, double size) {
    IconData icon;
    Color color;
    switch (tipo) {
      case 'Secagem': icon = Icons.waves_rounded; color = Colors.orange; break;
      case 'Triagem': icon = Icons.local_shipping_rounded; color = Colors.blue; break;
      case 'Resfriamento': icon = Icons.ac_unit_rounded; color = Colors.teal; break;
      case 'Armazenamento': icon = Icons.warehouse_rounded; color = Colors.green; break;
      default: icon = Icons.play_arrow_rounded; color = Colors.blue;
    }
    return Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size > 24 ? 10 : 6),
      ),
      child: Icon(icon, color: color, size: size * 0.6),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestão de Processos', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface)),
        Text('Acompanhe o status e performance das operações.', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
      ],
    );
  }

  void _showEtapasModal(BuildContext context, bool isDesktop) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isDesktop ? 800 : double.infinity,
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
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
                          Text('Nova Atividade', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text('Selecione a etapa desejada para iniciar.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: cs.onPrimary),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 32 : 16),
                  child: Obx(() => _StageCards(
                    controller: controller,
                    activeStage: controller.activeStage.value,
                    onNewProcesso: () { Get.back(); _showProcessoForm(Get.context!, tipo: 'Secagem'); },
                    onNewBatch: () { Get.back(); showBatchFormDialog(Get.context!, controller: Get.find<BatchManagementController>(), title: 'Chegada/Triagem'); },
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.5), borderRadius: BorderRadius.circular(28)),
            child: Icon(Icons.inventory_2_outlined, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text('Nenhum processo ativo', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Inicie uma nova atividade para começar.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _statusBadge(ColorScheme cs, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Iniciada': return Colors.blue;
      case 'Pausada': return Colors.orange;
      case 'Finalizada': return Colors.green;
      case 'Cancelada': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _confirmDelete(ProcessoModel p) {
    final cs = Theme.of(Get.context!).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.delete_outline_rounded, color: cs.error, size: 22)),
            const SizedBox(width: 12),
            Text('Excluir Atividade?', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
        content: Text('Esta ação não pode ser desfeita.', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Cancelar', style: GoogleFonts.inter(color: cs.onSurfaceVariant))),
          FilledButton(onPressed: () { Get.back(); if (p.id != null) controller.deleteProcesso(p.id!); }, style: FilledButton.styleFrom(backgroundColor: cs.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Excluir', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showProcessoDetails(BuildContext context, ProcessoModel p) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final duration = (p.dataFim ?? DateTime.now()).difference(p.dataInicio);
    final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 520,
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
                    _tipoIcon(p.tipoProcesso, 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.tipoProcesso, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 2),
                          Text(p.loteNumero != null ? 'Lote ${p.loteNumero}' : 'Avulso', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded), style: IconButton.styleFrom(backgroundColor: cs.onPrimary.withOpacity(0.15)), color: cs.onPrimary),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(cs, Icons.inventory_2_rounded, 'Lote', p.loteNumero ?? '---'),
                      const SizedBox(height: 16),
                      _detailRow(cs, Icons.grass, 'Cultura', p.loteCultura ?? '---'),
                      const SizedBox(height: 16),
                      _detailRow(cs, Icons.calendar_today_rounded, 'Data Início', df.format(p.dataInicio.toLocal())),
                      const SizedBox(height: 16),
                      _detailRow(cs, Icons.check_circle_outline_rounded, 'Data Fim', p.dataFim != null ? df.format(p.dataFim!.toLocal()) : '---'),
                      const SizedBox(height: 16),
                      _detailRow(cs, Icons.timer_rounded, 'Duração', durationStr),
                      const SizedBox(height: 16),
                      _detailRow(cs, Icons.person_outline_rounded, 'Responsável', p.responsavelNome ?? '---'),
                      const SizedBox(height: 16),
                      _detailRow(cs, Icons.settings_input_component_rounded, 'Secador', p.secadorNome ?? '---'),
                      const SizedBox(height: 16),
                      _detailRow(cs, Icons.warehouse_rounded, 'Silo', p.siloNome ?? '---'),
                      const SizedBox(height: 16),
                      _detailRow(cs, Icons.info_outline_rounded, 'Status', p.status),
                      if (p.dadosExtras != null && p.dadosExtras!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Divider(color: cs.outlineVariant.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('DADOS EXTRAS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.8)),
                        const SizedBox(height: 12),
                        ...p.dadosExtras!.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${e.key}: ', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                              Expanded(child: Text('${e.value}', style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface))),
                            ],
                          ),
                        )),
                      ],
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

  Widget _detailRow(ColorScheme cs, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: cs.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: cs.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  void _showProcessoForm(BuildContext context, {ProcessoModel? processo, String? tipo}) {
    final isEditing = processo != null;
    String selectedTipo = tipo ?? processo?.tipoProcesso ?? 'Secagem';
    int? selectedLoteId = processo?.loteId ?? (controller.availableBatches.isNotEmpty ? controller.availableBatches.first.id : null);
    int? selectedSecadorId = processo?.secadorId;
    int? selectedSiloId = processo?.siloId;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final cs = Theme.of(context).colorScheme;

          void onSecadorChanged(int? val) {
            setState(() { selectedSecadorId = val; if (val != null) selectedSiloId = null; });
          }

          void onSiloChanged(int? val) {
            setState(() { selectedSiloId = val; if (val != null) selectedSecadorId = null; });
          }

          final secadorItems = controller.availableDryers
              .where((d) => d.status == 'Disponível')
              .map((d) => DropdownMenuItem<int>(value: d.id, child: Text('${d.nome} (${d.fonteCalor})', style: GoogleFonts.inter(color: cs.onSurface))))
              .toList();

          final siloItems = controller.availableSilos
              .where((s) => s.status == 'disponivel')
              .map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: cs.onSurface))))
              .toList();

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 500,
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
                              Text(isEditing ? 'Editar Atividade' : 'Iniciar $selectedTipo', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                              const SizedBox(height: 4),
                              Text(isEditing ? 'Atualize os dados da operação.' : 'Configure uma nova operação de $selectedTipo no sistema.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded), style: IconButton.styleFrom(backgroundColor: cs.onPrimary.withOpacity(0.15)), color: cs.onPrimary),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          _fieldLabel(cs, 'LOTE / GRÃOS'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: selectedLoteId,
                            isExpanded: true,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            decoration: _fieldDeco(cs, Icons.grass),
                            items: controller.availableBatches.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.numeroLote} - ${b.cultura} (${b.status})', style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                            onChanged: (val) => setState(() => selectedLoteId = val),
                          ),
                          const SizedBox(height: 20),
                          _fieldLabel(cs, 'SECADOR'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(value: selectedSecadorId, isExpanded: true, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface), dropdownColor: cs.surface, decoration: _fieldDeco(cs, Icons.settings_input_component_rounded), items: secadorItems, onChanged: onSecadorChanged),
                          const SizedBox(height: 20),
                          _fieldLabel(cs, 'SILO (OPCIONAL)'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(value: selectedSiloId, isExpanded: true, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface), dropdownColor: cs.surface, decoration: _fieldDeco(cs, Icons.warehouse_rounded), items: siloItems, onChanged: onSiloChanged),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(child: TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)))),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: FilledButton(
                                  onPressed: () {
                                    if (!isEditing && selectedLoteId != null) {
                                      final hasActive = controller.processos.any((p) =>
                                        p.loteId == selectedLoteId && (p.status == 'Iniciada' || p.status == 'Pausada'));
                                      if (hasActive) {
                                        Get.dialog(
                                          AlertDialog(
                                            backgroundColor: cs.surface,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            title: Row(
                                              children: [
                                                Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22)),
                                                const SizedBox(width: 12),
                                                Text('Lote já possui atividade', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: cs.onSurface)),
                                              ],
                                            ),
                                            content: Text('Este lote já possui uma atividade em andamento. Deseja iniciar outra mesmo assim?', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                                            actions: [
                                              TextButton(onPressed: () => Get.back(), child: Text('Cancelar', style: GoogleFonts.inter(color: cs.onSurfaceVariant))),
                                              FilledButton(
                                                onPressed: () {
                                                  Get.back();
                                                  final newProcesso = ProcessoModel(id: processo?.id, tipoProcesso: selectedTipo, loteId: selectedLoteId, secadorId: selectedSecadorId, siloId: selectedSiloId, dataInicio: processo?.dataInicio ?? DateTime.now(), status: processo?.status ?? 'Iniciada');
                                                  controller.createProcesso(newProcesso);
                                                },
                                                style: FilledButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                                child: Text('Iniciar Mesmo Assim', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }
                                    }
                                    final newProcesso = ProcessoModel(id: processo?.id, tipoProcesso: selectedTipo, loteId: selectedLoteId, secadorId: selectedSecadorId, siloId: selectedSiloId, dataInicio: processo?.dataInicio ?? DateTime.now(), status: processo?.status ?? 'Iniciada');
                                    if (isEditing) controller.updateProcesso(newProcesso);
                                    else controller.createProcesso(newProcesso);
                                  },
                                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                  child: Text(isEditing ? 'Salvar' : 'Iniciar Agora', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _fieldLabel(ColorScheme cs, String label) {
    return Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.8));
  }

  InputDecoration _fieldDeco(ColorScheme cs, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.6)),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Duration _calcularDuracao(ProcessoModel p) {
    final total = (p.dataFim ?? DateTime.now()).difference(p.dataInicio);
    final pausado = Duration(seconds: p.dadosExtras?['tempo_pausado_segundos'] as int? ?? 0);
    final segundos = total.inSeconds - pausado.inSeconds;
    return Duration(seconds: segundos < 0 ? 0 : segundos);
  }

  String _formatDuracao(Duration d) => '${d.inHours}h ${d.inMinutes % 60}m';
}

class _StageData {
  final IconData icon;
  final String title;
  final Color color;
  final String imagePath;
  final List<_Indicator> indicators;
  final List<_ActionData> actions;
  const _StageData(this.icon, this.title, this.color, this.imagePath, this.indicators, this.actions);
}

class _Indicator {
  final String label;
  final String value;
  const _Indicator(this.label, this.value);
}

class _ActionData {
  final String label;
  final IconData icon;
  const _ActionData(this.label, this.icon);
}

const _stages = [
  _StageData(Icons.local_shipping_rounded, 'Chegada/Triagem', Color(0xFF2196F3), 'assets/images/romaneios.png', [
    _Indicator('Caminhões na fila', '18'),
    _Indicator('Tempo médio de espera', '32 min'),
    _Indicator('Em atendimento', '3'),
  ], [
    _ActionData('Nova entrada', Icons.add_circle_outline),
    _ActionData('Consultar fila', Icons.list_alt_rounded),
  ]),
  _StageData(Icons.biotech_rounded, 'Classificação', Color(0xFF9C27B0), 'assets/images/amostras.png', [
    _Indicator('Aguardando análise', '12'),
    _Indicator('Classificados hoje', '146'),
    _Indicator('Umidade média', '13,8%'),
  ], [
    _ActionData('Registrar classificação', Icons.science_outlined),
    _ActionData('Emitir laudo', Icons.description_outlined),
  ]),
  _StageData(Icons.download_rounded, 'Moega/Recebimento', Color(0xFFFF9800), 'assets/images/produtores.png', [
    _Indicator('Descargas em andamento', '4'),
    _Indicator('Ton. recebidas hoje', '2.450 t'),
    _Indicator('Capacidade utilizada', '68%'),
  ], [
    _ActionData('Iniciar descarga', Icons.download_rounded),
    _ActionData('Visualizar moegas', Icons.visibility_rounded),
  ]),
  _StageData(Icons.waves_rounded, 'Pré-limpeza/Secagem', Color(0xFFF44336), 'assets/images/lotes.png', [
    _Indicator('Lotes em secagem', '6'),
    _Indicator('Umidade média atual', '15,2%'),
    _Indicator('Secadores ativos', '2/3'),
  ], [
    _ActionData('Monitorar secagem', Icons.monitor_heart_outlined),
    _ActionData('Ajustar parâmetros', Icons.tune_rounded),
  ]),
  _StageData(Icons.warehouse_rounded, 'Armazenamento', Color(0xFF4CAF50), 'assets/images/silos.png', [
    _Indicator('Estoque total', '32.540 t'),
    _Indicator('Ocupação dos silos', '78%'),
    _Indicator('Temperatura média', '24°C'),
  ], [
    _ActionData('Visualizar silos', Icons.warehouse_rounded),
    _ActionData('Mapa de armazenamento', Icons.map_rounded),
  ]),
  _StageData(Icons.local_shipping_rounded, 'Expedição', Color(0xFF607D8B), 'assets/images/trator.png', [
    _Indicator('Carregamentos hoje', '42'),
    _Indicator('Ton. expedidas', '1.860 t'),
    _Indicator('Caminhões aguardando', '5'),
  ], [
    _ActionData('Nova expedição', Icons.local_shipping_rounded),
    _ActionData('Emitir romaneio', Icons.receipt_long_rounded),
  ]),
];

class _StageCards extends StatelessWidget {
  final ProcessosController controller;
  final int activeStage;
  final VoidCallback? onNewProcesso;
  final VoidCallback? onNewBatch;
  const _StageCards({required this.controller, required this.activeStage, this.onNewProcesso, this.onNewBatch});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 1100 ? 3 : w >= 700 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisExtent: 140,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: _stages.length,
          itemBuilder: (_, i) => _buildCard(cs, i, onNewProcesso, onNewBatch: onNewBatch),
        );
      },
    );
  }

  Widget _buildCard(ColorScheme cs, int index, VoidCallback? onNewProcesso, {VoidCallback? onNewBatch}) {
    final stage = _stages[index];
    final isSecagem = index == 3;
    final isChegada = index == 0;

    return GestureDetector(
      onTap: () {
        controller.activeStage.value = index;
        if (isSecagem && onNewProcesso != null) {
          onNewProcesso();
        } else if (isChegada && onNewBatch != null) {
          onNewBatch();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: cs.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  stage.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient Overlay for text readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Content Overlay
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            stage.icon,
                            color: Colors.white.withOpacity(0.9),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      stage.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
