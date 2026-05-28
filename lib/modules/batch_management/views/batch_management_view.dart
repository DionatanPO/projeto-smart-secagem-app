import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/batch_model.dart';
import '../../farm_management/controllers/farm_management_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/batch_management_controller.dart';

class BatchManagementView extends GetView<BatchManagementController> {
  const BatchManagementView({super.key});

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
                          'Lotes',
                          style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ),
                      if (isDesktop)
                        Text('Monitore os ciclos de secagem de cada lote.', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 20),
              child: SearchBar(
                hintText: 'Buscar lote...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(color: cs.onSurfaceVariant)),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHighest.withOpacity(0.5)),
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                onChanged: controller.filterBatches,
              ),
            ),
            Expanded(
              child: Obx(() {
                final list = controller.filteredBatches;
                if (controller.isLoading.value && list.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (list.isEmpty) {
                  return _buildEmptyState(context, controller.searchQuery.value.isNotEmpty);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(4),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildBatchCard(context, list[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBatchForm(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: Text('Novo Lote', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildBatchCard(BuildContext context, BatchModel batch) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final compact = w < 700;
    final statusColor = _getStatusColor(batch.status);

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showBatchForm(context, batch: batch),
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 44 : 52,
                    height: compact ? 44 : 52,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_getStatusIcon(batch.status), color: statusColor, size: compact ? 22 : 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text('Lote ${batch.numeroLote ?? '---'}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface), overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(batch.status, statusColor),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (!compact)
                          Wrap(
                            spacing: 14, runSpacing: 4,
                            children: [
                              _infoRow(cs, Icons.calendar_today_outlined, batch.dataEntrada != null ? DateFormat('dd/MM/yyyy').format(batch.dataEntrada!.toLocal()) : '---'),
                              _infoRow(cs, Icons.inventory_2_outlined, '${batch.cultura} (${batch.safra})'),
                              _infoRow(cs, Icons.location_on_outlined, batch.farmName ?? 'N/A'),
                              if (batch.clienteNome != null) _infoRow(cs, Icons.person_outline_rounded, batch.clienteNome!),
                              if (batch.siloName != null) _infoRow(cs, Icons.warehouse_outlined, batch.siloName!),
                            ],
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert_rounded, size: 20, color: cs.onSurfaceVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    color: cs.surfaceContainerLow,
                    onSelected: (value) {
                      if (value == 0) _showBatchForm(context, batch: batch);
                      if (value == 1) _confirmDelete(context, batch);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                      if (Get.find<HomeController>().isAdmin)
                      PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                    ],
                  ),
                ],
              ),
              if (compact) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 6, children: [
                  _infoRow(cs, Icons.calendar_today_outlined, batch.dataEntrada != null ? DateFormat('dd/MM/yyyy').format(batch.dataEntrada!.toLocal()) : '---'),
                  _infoRow(cs, Icons.inventory_2_outlined, '${batch.cultura} (${batch.safra})'),
                ]),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _metricItem(cs, 'Peso Inicial', '${batch.pesoInicial.toStringAsFixed(0)} kg'),
                    const Spacer(),
                    _metricItem(cs, 'Umidade', '${batch.umidadeInicial}%', alignEnd: true),
                  ],
                ),
              ),
              if (batch.observacoes != null && batch.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.assignment_outlined, size: 14, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(batch.observacoes!, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(ColorScheme cs, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _metricItem(ColorScheme cs, String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 0.5)),
        Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
      ],
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(status).toUpperCase(),
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('Pausado')) return Colors.orangeAccent;
    if (status.contains('Secagem')) return const Color(0xFF518C52);
    if (status.contains('Aeração')) return Colors.blue;
    if (status.contains('Transilagem')) return Colors.purple;
    if (status.contains('Expurgo')) return Colors.red;
    if (status.contains('Expedição')) return Colors.green;
    if (status == 'finalizado') return Colors.teal;
    if (status == 'despachado') return Colors.grey;
    return Colors.orange;
  }

  String _getStatusText(String status) {
    if (status == 'aguardando') return 'Aguardando';
    if (status == 'finalizado') return 'Finalizado';
    if (status == 'despachado') return 'Despachado';
    return status;
  }

  IconData _getStatusIcon(String status) {
    if (status.contains('Pausado')) return Icons.pause_circle_outline_rounded;
    if (status.contains('Secagem')) return Icons.waves_rounded;
    if (status.contains('Aeração')) return Icons.air_rounded;
    if (status.contains('Transilagem')) return Icons.swap_horiz_rounded;
    if (status.contains('Expurgo')) return Icons.biotech_rounded;
    if (status.contains('Expedição')) return Icons.local_shipping_rounded;
    if (status == 'finalizado') return Icons.check_circle_outline;
    if (status == 'despachado') return Icons.done_all_rounded;
    return Icons.timer_outlined;
  }

  Widget _buildEmptyState(BuildContext context, bool hasSearch) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.5), borderRadius: BorderRadius.circular(28)),
            child: Icon(hasSearch ? Icons.search_off_rounded : Icons.inventory_2_outlined, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(hasSearch ? 'Nenhum resultado encontrado' : 'Nenhum lote cadastrado', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(hasSearch ? 'Tente buscar por número, cultura, safra ou cliente.' : 'Adicione um lote para iniciar o monitoramento.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, BatchModel batch) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.delete_outline_rounded, color: cs.error, size: 22)),
            const SizedBox(width: 12),
            Text('Remover Lote?', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
        content: Text('Tem certeza que deseja remover o lote ${batch.numeroLote ?? ''}?', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Cancelar', style: GoogleFonts.inter(color: cs.onSurfaceVariant))),
          FilledButton(onPressed: () { Get.back(); controller.deleteBatch(batch.id!); }, style: FilledButton.styleFrom(backgroundColor: cs.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Remover', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showBatchForm(BuildContext context, {BatchModel? batch}) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = batch != null;
    final farmController = Get.find<FarmManagementController>();

    final numeroCtl = TextEditingController(text: batch?.numeroLote ?? '');
    final safraCtl = TextEditingController(text: batch?.safra ?? '2023/2024');
    final pesoCtl = TextEditingController(text: batch?.pesoInicial.toString() ?? '');
    final umidadeCtl = TextEditingController(text: batch?.umidadeInicial.toString() ?? '');
    final obsCtl = TextEditingController(text: batch?.observacoes ?? '');

    final grainTypes = ['Milho', 'Soja', 'Arroz', 'Trigo', 'Sorgo', 'Café', 'Feijão', 'Outros'];
    final initialCultura = batch?.cultura ?? 'Milho';
    final selectedCultura = (grainTypes.contains(initialCultura) ? initialCultura : 'Outros').obs;
    final selectedFarmId = Rx<int?>(batch?.farm ?? (farmController.farms.isNotEmpty ? farmController.farms.first.id : null));
    final selectedClientId = Rx<int?>(batch?.cliente ?? (controller.clients.isNotEmpty ? controller.clients.first['id'] as int : null));

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 600,
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
                          Text(isEditing ? 'Editar Lote' : 'Novo Lote', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text(isEditing ? 'Atualize as informações do lote.' : 'Cadastre um novo lote de grãos.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
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
                      Row(
                        children: [
                          if (isEditing) ...[
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _fieldLabel(cs, 'NÚMERO DO LOTE'),
                                const SizedBox(height: 8),
                                _field(cs, numeroCtl, '', Icons.tag, readOnly: true),
                              ]),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _fieldLabel(cs, 'SAFRA'),
                              const SizedBox(height: 8),
                              _field(cs, safraCtl, 'Ex: 2023/24', Icons.calendar_today),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'CLIENTE / PRODUTOR'),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<int>(
                        value: selectedClientId.value,
                        isExpanded: true,
                        decoration: _dropDeco(cs, Icons.person_outlined),
                        items: controller.clients.map((c) => DropdownMenuItem(value: c['id'] as int, child: Text(c['nome'] ?? '', style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                        onChanged: (val) => selectedClientId.value = val,
                        style: GoogleFonts.inter(color: cs.onSurface),
                      )),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'CULTURA / GRÃO'),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<String>(
                        value: selectedCultura.value,
                        decoration: _dropDeco(cs, Icons.grass),
                        items: grainTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                        onChanged: (val) => selectedCultura.value = val!,
                        style: GoogleFonts.inter(color: cs.onSurface),
                      )),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'PESO INICIAL (KG)'),
                            const SizedBox(height: 8),
                            _field(cs, pesoCtl, '0.0', Icons.scale, keyboardType: TextInputType.number),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'UMIDADE INICIAL (%)'),
                            const SizedBox(height: 8),
                            _field(cs, umidadeCtl, '0.0', Icons.water_drop, keyboardType: TextInputType.number),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'FAZENDA / UNIDADE'),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<int>(
                        value: selectedFarmId.value,
                        decoration: _dropDeco(cs, Icons.agriculture),
                        items: farmController.farms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                        onChanged: (val) => selectedFarmId.value = val,
                        style: GoogleFonts.inter(color: cs.onSurface),
                      )),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'NOTAS E DIAGNÓSTICOS'),
                      const SizedBox(height: 8),
                      _field(cs, obsCtl, 'Detalhes adicionais sobre o lote...', Icons.notes_rounded, maxLines: 3),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                          )),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: FilledButton(
                            onPressed: () {
                              final b = BatchModel(
                                id: batch?.id, numeroLote: numeroCtl.text, farm: selectedFarmId.value!,
                                cultura: selectedCultura.value, safra: safraCtl.text,
                                pesoInicial: double.tryParse(pesoCtl.text) ?? 0,
                                umidadeInicial: double.tryParse(umidadeCtl.text) ?? 0,
                                status: batch?.status ?? 'aguardando', silo: batch?.silo,
                                cliente: selectedClientId.value, observacoes: obsCtl.text,
                              );
                              if (isEditing) { controller.updateBatch(b); } else { controller.createBatch(b); }
                            },
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: Text(isEditing ? 'Atualizar' : 'Criar Lote', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          )),
                        ],
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

  Widget _fieldLabel(ColorScheme cs, String label) {
    return Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.8));
  }

  Widget _field(ColorScheme cs, TextEditingController ctl, String hint, IconData icon, {bool readOnly = false, TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: ctl, readOnly: readOnly, maxLines: maxLines, keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: readOnly ? cs.onSurfaceVariant : cs.onSurface),
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

  InputDecoration _dropDeco(ColorScheme cs, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.6)),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
