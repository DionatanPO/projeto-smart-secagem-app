import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/unidade_armazenadora_model.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/unidade_armazenadora_management_controller.dart';

class UnidadeArmazenadoraManagementView extends GetView<UnidadeArmazenadoraManagementController> {
  const UnidadeArmazenadoraManagementView({super.key});

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
                          'Unidades de Beneficiamento de Grãos',
                          style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ),
                      if (isDesktop)
                        Text('Gerencie as unidades de armazenamento', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 20),
              child: SearchBar(
                hintText: 'Buscar unidade...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(color: cs.onSurfaceVariant)),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHighest.withOpacity(0.5)),
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                onChanged: controller.filterUnidades,
              ),
            ),
            Expanded(
              child: Obx(() {
                final unidades = controller.filteredUnidades;
                if (controller.isLoading.value && unidades.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (unidades.isEmpty) {
                  return _buildEmptyState(context, controller.searchQuery.value.isNotEmpty);
                }
                if (isDesktop) {
                  return SingleChildScrollView(
                    child: _buildUnidadesTable(context, cs, unidades),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(4),
                  itemCount: unidades.length,
                  itemBuilder: (_, i) => _buildUnidadeCompactCard(context, unidades[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUnidadeForm(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: Text('Nova Unidade', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildUnidadesTable(BuildContext context, ColorScheme cs, List<UnidadeArmazenadoraModel> list) {
    const flex = [7, 18, 14, 16, 9];
    const gap = 6.0;

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
            _header('Nome'),
            _header('Localização'),
            _header('Descrição'),
            _header('Ações'),
          ])),
        ),
        ...list.map((u) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.2))),
            ),
            child: Row(children: _rowCells([
              Text('${list.indexOf(u) + 1}', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
              _cell(u.name, bold: true),
              _cell(u.location ?? '---'),
              _cell(u.description ?? '---'),
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                color: cs.surfaceContainerLow,
                onSelected: (value) {
                  if (value == 0) _showUnidadeForm(context, unidade: u);
                  if (value == 1 && Get.find<HomeController>().isAdmin) controller.deleteUnidade(u.id!);
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

  Widget _buildUnidadeCompactCard(BuildContext context, UnidadeArmazenadoraModel unidade) {
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
                  child: Icon(Icons.agriculture_rounded, color: cs.onPrimary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(unidade.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  color: cs.surfaceContainerLow,
                  onSelected: (value) {
                    if (value == 0) _showUnidadeForm(context, unidade: unidade);
                    if (value == 1 && Get.find<HomeController>().isAdmin) controller.deleteUnidade(unidade.id!);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                    if (Get.find<HomeController>().isAdmin)
                    PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                  ],
                ),
              ],
            ),
            if (unidade.location != null || unidade.description != null) ...[
              const SizedBox(height: 8),
              if (unidade.location != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _compactInfo(cs, Icons.location_on_rounded, unidade.location!),
                ),
              if (unidade.description != null)
                _compactInfo(cs, Icons.notes_rounded, unidade.description!),
            ],
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
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurface))),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasSearch) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(hasSearch ? Icons.search_off_rounded : Icons.location_off_rounded, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(
            hasSearch ? 'Nenhum resultado encontrado' : 'Nenhuma unidade cadastrada',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch ? 'Tente buscar por outro nome ou localização.' : 'Adicione uma unidade armazenadora para organizar seus silos.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  void _showUnidadeForm(BuildContext context, {UnidadeArmazenadoraModel? unidade}) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = unidade != null;
    final nameCtl = TextEditingController(text: unidade?.name ?? '');
    final locationCtl = TextEditingController(text: unidade?.location ?? '');
    final descCtl = TextEditingController(text: unidade?.description ?? '');

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEditing ? 'Editar Unidade' : 'Nova Unidade', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text(isEditing ? 'Atualize as informações da unidade.' : 'Cadastre uma nova localidade.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
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
                      _buildFieldLabel(cs, 'NOME'),
                      const SizedBox(height: 8),
                      _buildField(cs, nameCtl, 'Ex: Unidade Santa Fé', Icons.business_rounded),
                      const SizedBox(height: 20),
                      _buildFieldLabel(cs, 'LOCALIZAÇÃO'),
                      const SizedBox(height: 8),
                      _buildField(cs, locationCtl, 'Ex: Rio Verde - GO', Icons.location_on_rounded),
                      const SizedBox(height: 20),
                      _buildFieldLabel(cs, 'DESCRIÇÃO'),
                      const SizedBox(height: 8),
                      _buildField(cs, descCtl, 'Notas técnicas da unidade...', Icons.notes_rounded, maxLines: 3),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Get.back(),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () {
                                final f = UnidadeArmazenadoraModel(id: unidade?.id, name: nameCtl.text, location: locationCtl.text, description: descCtl.text);
                                if (isEditing) { controller.updateUnidade(f); } else { controller.createUnidade(f); }
                              },
                              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: Text(isEditing ? 'Atualizar' : 'Cadastrar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
      ),
    );
  }

  Widget _buildFieldLabel(ColorScheme cs, String label) {
    return Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.8));
  }

  Widget _buildField(ColorScheme cs, TextEditingController ctl, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctl,
      maxLines: maxLines,
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
}
