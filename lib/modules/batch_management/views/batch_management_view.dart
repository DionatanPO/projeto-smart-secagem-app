import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/batch_model.dart';
import '../../unidade_armazenadora_management/controllers/unidade_armazenadora_management_controller.dart';
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
                if (isDesktop) {
                  return SingleChildScrollView(
                    child: _buildBatchTable(context, cs, list),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(4),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _buildBatchCompactCard(context, list[i]),
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

  Widget _buildBatchTable(BuildContext context, ColorScheme cs, List<BatchModel> list) {
    const flex = [7, 12, 12, 10, 9, 9, 9, 9, 10];
    const gap = 6.0;
    final df = DateFormat('dd/MM/yyyy');

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(children: _rowCells([
            _header('#'),
            _header('Lote'),
            _header('Cultura / Safra'),
            _header('Entrada'),
            _header('Peso'),
            _header('Umidade'),
            _header('Unidade'),
            _header('Status'),
            _header('Ações'),
          ])),
        ),
        ...list.map((b) {
          final statusColor = _getStatusColor(b.status);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.2))),
            ),
            child: Row(children: _rowCells([
              Text('${list.indexOf(b) + 1}', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
              _cell(b.numeroLote ?? '---', bold: true),
              _cell('${b.cultura} (${b.safra})'),
              _cell(b.dataEntrada != null ? df.format(b.dataEntrada!.toLocal()) : '---'),
              _cell('${b.pesoInicial.toStringAsFixed(0)} kg'),
              _cell('${b.umidadeInicial}%'),
              _cell(b.unidadeArmazenadoraNome ?? '---'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(_getStatusText(b.status).toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.3)),
              ),
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                color: cs.surfaceContainerLow,
                onSelected: (value) {
                  if (value == 0) _showBatchForm(context, batch: b);
                  if (value == 1) _confirmDelete(context, b);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                  if (Get.find<HomeController>().isAdmin)
                  PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                ],
              ),
            ])),
          );
        }),
      ],
    );
  }

  Widget _buildBatchCompactCard(BuildContext context, BatchModel batch) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(batch.status);
    final df = DateFormat('dd/MM/yyyy');

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
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.inventory_2_rounded, color: statusColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lote ${batch.numeroLote ?? '---'}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      Text('${batch.cultura} (${batch.safra})', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            const SizedBox(height: 10),
            Row(
              children: [
                _compactInfo(cs, Icons.calendar_today_outlined, batch.dataEntrada != null ? df.format(batch.dataEntrada!.toLocal()) : '---'),
                const SizedBox(width: 12),
                _compactInfo(cs, Icons.monitor_weight_rounded, '${batch.pesoInicial.toStringAsFixed(0)} kg'),
                const SizedBox(width: 12),
                _compactInfo(cs, Icons.water_drop_rounded, '${batch.umidadeInicial}%'),
              ],
            ),
            if (batch.placaCaminhao != null || batch.motoristaNome != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  if (batch.placaCaminhao != null && batch.placaCaminhao!.isNotEmpty)
                    _compactInfo(cs, Icons.local_shipping_rounded, batch.placaCaminhao!),
                  if (batch.motoristaNome != null && batch.motoristaNome!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    _compactInfo(cs, Icons.person_outline_rounded, batch.motoristaNome!),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(_getStatusText(batch.status).toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.3)),
                ),
                const Spacer(),
                Text(batch.unidadeArmazenadoraNome ?? '', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactInfo(ColorScheme cs, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurface)),
      ],
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
    showBatchFormDialog(context, controller: controller, batch: batch);
  }
}

void showBatchFormDialog(BuildContext context, {required BatchManagementController controller, BatchModel? batch, String? title}) {
  final cs = Theme.of(context).colorScheme;
  final isEditing = batch != null;
  final unidadeController = Get.find<UnidadeArmazenadoraManagementController>();

  final numeroCtl = TextEditingController(text: batch?.numeroLote ?? '');
  final safraCtl = TextEditingController(text: batch?.safra ?? '2023/2024');
  final pesoCtl = TextEditingController(text: batch?.pesoInicial.toString() ?? '');
  final umidadeCtl = TextEditingController(text: batch?.umidadeInicial.toString() ?? '');
  final obsCtl = TextEditingController(text: batch?.observacoes ?? '');
  final placaCtl = TextEditingController(text: batch?.placaCaminhao ?? '');
  final motoristaCtl = TextEditingController(text: batch?.motoristaNome ?? '');
  final pesoCaminhaoCtl = TextEditingController(text: batch?.pesoCaminhao?.toString() ?? '');

  final grainTypes = ['Milho', 'Soja', 'Arroz', 'Trigo', 'Sorgo', 'Café', 'Feijão', 'Outros'];
  final initialCultura = batch?.cultura ?? 'Milho';
  final selectedCultura = (grainTypes.contains(initialCultura) ? initialCultura : 'Outros').obs;
  final selectedFarmId = Rx<int?>(batch?.unidadeArmazenadora ?? (unidadeController.unidades.isNotEmpty ? unidadeController.unidades.first.id : null));
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
                          Text(isEditing ? 'Editar Lote' : (title ?? 'Novo Lote'), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text(isEditing ? 'Atualize as informações do lote.' : (title != null ? 'Cadastre um novo lote para $title.' : 'Cadastre um novo lote de grãos.'), style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
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
                              fieldLabel(cs, 'NÚMERO DO LOTE'),
                              const SizedBox(height: 8),
                              fieldInput(cs, numeroCtl, '', Icons.tag, readOnly: true),
                            ]),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            fieldLabel(cs, 'SAFRA'),
                            const SizedBox(height: 8),
                            fieldInput(cs, safraCtl, 'Ex: 2023/24', Icons.calendar_today),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    fieldLabel(cs, 'CLIENTE / PRODUTOR'),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButtonFormField<int>(
                      value: selectedClientId.value,
                      isExpanded: true,
                      decoration: dropDeco(cs, Icons.person_outlined),
                      items: controller.clients.map((c) => DropdownMenuItem(value: c['id'] as int, child: Text(c['nome'] ?? '', style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                      onChanged: (val) => selectedClientId.value = val,
                      style: GoogleFonts.inter(color: cs.onSurface),
                    )),
                    const SizedBox(height: 20),
                    fieldLabel(cs, 'CULTURA / GRÃO'),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButtonFormField<String>(
                      value: selectedCultura.value,
                      decoration: dropDeco(cs, Icons.grass),
                      items: grainTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                      onChanged: (val) => selectedCultura.value = val!,
                      style: GoogleFonts.inter(color: cs.onSurface),
                    )),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          fieldLabel(cs, 'PESO INICIAL (KG)'),
                          const SizedBox(height: 8),
                          fieldInput(cs, pesoCtl, '0.0', Icons.scale, keyboardType: TextInputType.number),
                        ])),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          fieldLabel(cs, 'UMIDADE INICIAL (%)'),
                          const SizedBox(height: 8),
                          fieldInput(cs, umidadeCtl, '0.0', Icons.water_drop, keyboardType: TextInputType.number),
                        ])),
                      ],
                    ),
                    const SizedBox(height: 20),
                    fieldLabel(cs, 'UNIDADE ARMAZENADORA'),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButtonFormField<int>(
                      value: selectedFarmId.value,
                      decoration: dropDeco(cs, Icons.agriculture),
                      items: unidadeController.unidades.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                      onChanged: (val) => selectedFarmId.value = val,
                      style: GoogleFonts.inter(color: cs.onSurface),
                    )),
                    const SizedBox(height: 20),
                    fieldLabel(cs, 'PLACA DO CAMINHÃO'),
                    const SizedBox(height: 8),
                    fieldInput(cs, placaCtl, 'Ex: ABC-1234', Icons.local_shipping_rounded),
                    const SizedBox(height: 20),
                    fieldLabel(cs, 'MOTORISTA'),
                    const SizedBox(height: 8),
                    fieldInput(cs, motoristaCtl, 'Nome do motorista', Icons.person_outline_rounded),
                    const SizedBox(height: 20),
                    fieldLabel(cs, 'PESO DO CAMINHÃO (KG)'),
                    const SizedBox(height: 8),
                    fieldInput(cs, pesoCaminhaoCtl, '0.0', Icons.scale, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    fieldLabel(cs, 'NOTAS E DIAGNÓSTICOS'),
                    const SizedBox(height: 8),
                    fieldInput(cs, obsCtl, 'Detalhes adicionais sobre o lote...', Icons.notes_rounded, maxLines: 3),
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
                              id: batch?.id, numeroLote: numeroCtl.text, unidadeArmazenadora: selectedFarmId.value!,
                              cultura: selectedCultura.value, safra: safraCtl.text,
                              pesoInicial: double.tryParse(pesoCtl.text) ?? 0,
                              umidadeInicial: double.tryParse(umidadeCtl.text) ?? 0,
                              status: batch?.status ?? 'aguardando', silo: batch?.silo,
                              cliente: selectedClientId.value, observacoes: obsCtl.text,
                              placaCaminhao: placaCtl.text, motoristaNome: motoristaCtl.text,
                              pesoCaminhao: double.tryParse(pesoCaminhaoCtl.text),
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

Widget fieldLabel(ColorScheme cs, String label) {
  return Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.8));
}

Widget fieldInput(ColorScheme cs, TextEditingController ctl, String hint, IconData icon, {bool readOnly = false, TextInputType? keyboardType, int maxLines = 1}) {
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

InputDecoration dropDeco(ColorScheme cs, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.6)),
    filled: true,
    fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  );
}
