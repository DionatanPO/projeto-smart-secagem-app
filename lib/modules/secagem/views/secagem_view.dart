import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/secador_model.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/secagem_controller.dart';

class SecagemView extends GetView<SecagemController> {
  const SecagemView({super.key});

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
                          'Controle de Secagem',
                          style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ),
                      if (isDesktop)
                        Text('Gerencie sua frota de secadores industriais.', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 20),
              child: SearchBar(
                hintText: 'Buscar secador...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(color: cs.onSurfaceVariant)),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHighest.withOpacity(0.5)),
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                onChanged: controller.filterSecadores,
              ),
            ),
            Expanded(
              child: Obx(() {
                final list = controller.filteredSecadores;
                if (controller.isLoading.value && list.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (list.isEmpty) {
                  return _buildEmptyState(context, controller.searchQuery.value.isNotEmpty);
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 480,
                    mainAxisExtent: 210,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _buildSecadorCard(context, list[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSecadorForm(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: Text('Novo Secador', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSecadorCard(BuildContext context, SecadorModel secador) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(secador.status);

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showSecadorForm(context, secador: secador),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [cs.primary, cs.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.heat_pump_rounded, color: cs.onPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(secador.nome, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(secador.farmName ?? 'Sem fazenda', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(secador.status, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.3)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.4), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricItem(cs, Icons.settings_input_component_rounded, 'Tipo', secador.tipo),
                      _metricItem(cs, Icons.speed_rounded, 'Capacidade', '${secador.capacidade} t/h'),
                      _metricItem(cs, Icons.local_fire_department_rounded, 'Calor', secador.fonteCalor),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    color: cs.surfaceContainerLow,
                    onSelected: (value) {
                      if (value == 0) _showSecadorForm(context, secador: secador);
                      if (value == 1) _confirmDelete(context, secador);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                      if (Get.find<HomeController>().isAdmin)
                      PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricItem(ColorScheme cs, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Disponível': return Colors.green;
      case 'Em Uso': return Colors.blue;
      case 'Em Manutenção': return Colors.orange;
      default: return Colors.grey;
    }
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
            child: Icon(hasSearch ? Icons.search_off_rounded : Icons.waves_rounded, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(hasSearch ? 'Nenhum resultado encontrado' : 'Nenhum secador cadastrado', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(hasSearch ? 'Tente buscar por nome, tipo ou status.' : 'Adicione um secador para monitorar a capacidade de secagem.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SecadorModel secador) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.delete_outline_rounded, color: cs.error, size: 22)),
            const SizedBox(width: 12),
            Text('Remover Secador?', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
        content: Text('Deseja excluir o equipamento "${secador.nome}"?', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Cancelar', style: GoogleFonts.inter(color: cs.onSurfaceVariant))),
          FilledButton(onPressed: () { controller.deleteSecador(secador.id!); Get.back(); }, style: FilledButton.styleFrom(backgroundColor: cs.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Remover', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showSecadorForm(BuildContext context, {SecadorModel? secador}) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = secador != null;
    final nameCtl = TextEditingController(text: secador?.nome);
    final capacityCtl = TextEditingController(text: secador?.capacidade.toString());
    final obsCtl = TextEditingController(text: secador?.observacoes);

    final selectedFarmId = Rx<int?>(secador?.farmId ?? (controller.availableFarms.isNotEmpty ? controller.availableFarms.first.id : null));
    final selectedType = (secador?.tipo ?? 'Coluna').obs;
    final selectedFuel = (secador?.fonteCalor ?? 'Lenha').obs;
    final selectedStatus = (secador?.status ?? 'Disponível').obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 560,
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
                          Text(isEditing ? 'Editar Secador' : 'Novo Secador', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text(isEditing ? 'Atualize os dados do equipamento.' : 'Cadastre um novo secador.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
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
                      _fieldLabel(cs, 'FAZENDA / UNIDADE'),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<int>(
                        value: selectedFarmId.value,
                        decoration: _dropDeco(cs, Icons.agriculture),
                        items: controller.availableFarms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                        onChanged: (v) => selectedFarmId.value = v,
                        style: GoogleFonts.inter(color: cs.onSurface),
                      )),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'NOME DO EQUIPAMENTO'),
                      const SizedBox(height: 8),
                      _field(cs, nameCtl, 'Ex: Secador 01', Icons.badge_outlined),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'TIPO'),
                            const SizedBox(height: 8),
                            Obx(() => DropdownButtonFormField<String>(
                              value: selectedType.value,
                              decoration: _dropDeco(cs, Icons.settings_input_component_rounded),
                              items: ['Coluna', 'Cascata', 'Fluxo Contínuo', 'Batelada'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                              onChanged: (v) => selectedType.value = v!,
                              style: GoogleFonts.inter(color: cs.onSurface),
                            )),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'CAPACIDADE (T/H)'),
                            const SizedBox(height: 8),
                            _field(cs, capacityCtl, '0.0', Icons.speed_rounded, keyboardType: TextInputType.number),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'FONTE DE CALOR'),
                            const SizedBox(height: 8),
                            Obx(() => DropdownButtonFormField<String>(
                              value: selectedFuel.value,
                              decoration: _dropDeco(cs, Icons.local_fire_department_rounded),
                              items: ['Lenha', 'Gás GLP', 'Biomassa', 'Elétrico'].map((f) => DropdownMenuItem(value: f, child: Text(f, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                              onChanged: (v) => selectedFuel.value = v!,
                              style: GoogleFonts.inter(color: cs.onSurface),
                            )),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'STATUS'),
                            const SizedBox(height: 8),
                            Obx(() => DropdownButtonFormField<String>(
                              value: selectedStatus.value,
                              decoration: _dropDeco(cs, Icons.toggle_on_outlined),
                              items: ['Disponível', 'Em Uso', 'Em Manutenção', 'Desativado'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
                              onChanged: (v) => selectedStatus.value = v!,
                              style: GoogleFonts.inter(color: cs.onSurface),
                            )),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'OBSERVAÇÕES TÉCNICAS'),
                      const SizedBox(height: 8),
                      _field(cs, obsCtl, 'Detalhes do equipamento...', Icons.note_alt_outlined, maxLines: 3),
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
                              final s = SecadorModel(
                                id: secador?.id, farmId: selectedFarmId.value!, nome: nameCtl.text,
                                tipo: selectedType.value, capacidade: double.tryParse(capacityCtl.text) ?? 0,
                                fonteCalor: selectedFuel.value, status: selectedStatus.value, observacoes: obsCtl.text,
                              );
                              if (isEditing) { controller.updateSecador(s); } else { controller.createSecador(s); }
                            },
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: Text(isEditing ? 'Atualizar' : 'Cadastrar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

  Widget _field(ColorScheme cs, TextEditingController ctl, String hint, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: ctl, maxLines: maxLines, keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant.withOpacity(0.5)),
        prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.6)),
        filled: true, fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
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
      filled: true, fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
