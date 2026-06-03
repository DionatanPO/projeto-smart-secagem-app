import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/secador_model.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/secagem_controller.dart';
import 'secador_detalhes_view.dart';

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
                          'Secadores',
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
                if (isDesktop) {
                  return SingleChildScrollView(
                    child: _buildSecadorTable(context, cs, list),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => _buildSecadorCompactCard(context, list[i]),
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

  Widget _buildSecadorTable(BuildContext context, ColorScheme cs, List<SecadorModel> list) {
    const flex = [6, 14, 10, 10, 10, 8, 8, 8];
    const gap = 8.0;

    Widget _header(String text) => Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 0.5), overflow: TextOverflow.ellipsis);

    Widget _cell(String text, {bool bold = false}) => Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: cs.onSurface), overflow: TextOverflow.ellipsis, maxLines: 1);

    List<Widget> _rowCells(List<Widget> cells) {
      final items = <Widget>[];
      for (int i = 0; i < cells.length; i++) {
        if (i > 0) items.add(const SizedBox(width: gap));
        if (i < flex.length) {
          items.add(Expanded(flex: flex[i], child: cells[i]));
        } else {
          items.add(cells[i]);
        }
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
            _header('Unidade'),
            _header('Tipo'),
            _header('Calor'),
            _header('Capacidade'),
            _header('Status'),
            _header('Ações'),
          ])),
        ),
        ...list.map((s) {
          final statusColor = _statusColor(s.status);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.2))),
            ),
            child: Row(children: _rowCells([
              Text('${list.indexOf(s) + 1}', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
              _cell(s.nome, bold: true),
              _cell(s.unidadeArmazenadoraNome ?? '---'),
              _cell(s.tipo),
              _cell(s.fonteCalor),
              _cell('${s.capacidade} t/h'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(s.status, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.3)),
              ),
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                color: cs.surfaceContainerLow,
                onSelected: (value) {
                  if (value == 0) _showSecadorForm(context, secador: s);
                  if (value == 1) Get.to(() => SecadorDetalhesView(secador: s));
                  if (value == 2) _confirmDelete(context, s);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                  PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.sensors_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Sensores e Telemetria', style: GoogleFonts.inter(color: cs.onSurface))])),
                  if (Get.find<HomeController>().isAdmin)
                  PopupMenuItem(value: 2, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                ],
              ),
            ])),
          );
        }),
      ],
    );
  }

  Widget _buildSecadorCompactCard(BuildContext context, SecadorModel secador) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(secador.status);

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
                  child: Icon(Icons.heat_pump_rounded, color: cs.onPrimary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(secador.nome, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(secador.unidadeArmazenadoraNome ?? 'Sem unidade', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  color: cs.surfaceContainerLow,
                  onSelected: (value) {
                    if (value == 0) _showSecadorForm(context, secador: secador);
                    if (value == 1) Get.to(() => SecadorDetalhesView(secador: secador));
                    if (value == 2) _confirmDelete(context, secador);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                    PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.sensors_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Sensores e Telemetria', style: GoogleFonts.inter(color: cs.onSurface))])),
                    if (Get.find<HomeController>().isAdmin)
                    PopupMenuItem(value: 2, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _compactMetric(cs, Icons.settings_input_component_rounded, secador.tipo),
                const SizedBox(width: 12),
                _compactMetric(cs, Icons.speed_rounded, '${secador.capacidade} t/h'),
                const SizedBox(width: 12),
                _compactMetric(cs, Icons.local_fire_department_rounded, secador.fonteCalor),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(secador.status, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.3)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactMetric(ColorScheme cs, IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurface)),
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

    // Cost controllers
    final custoAquisicaoCtl = TextEditingController(text: secador?.custoAquisicao?.toStringAsFixed(2));
    final valorResidualCtl = TextEditingController(text: secador?.valorResidual?.toStringAsFixed(2));
    final vidaUtilCtl = TextEditingController(text: secador?.vidaUtilAnos?.toString());
    final custoInstalacaoCtl = TextEditingController(text: secador?.custoInstalacao?.toStringAsFixed(2));
    final custoManutencaoCtl = TextEditingController(text: secador?.custoManutencaoAnual?.toStringAsFixed(2));
    final consumoCombustivelCtl = TextEditingController(text: secador?.consumoCombustivelHora?.toStringAsFixed(2));
    final precoCombustivelCtl = TextEditingController(text: secador?.precoCombustivel?.toStringAsFixed(2));
    final consumoEnergiaCtl = TextEditingController(text: secador?.consumoEnergiaKwh?.toStringAsFixed(2));
    final precoKwhCtl = TextEditingController(text: secador?.precoKwh?.toStringAsFixed(4));
    final maoObraCtl = TextEditingController(text: secador?.custoMaoObraHora?.toStringAsFixed(2));

    final selectedFarmId = Rx<int?>(secador?.unidadeArmazenadoraId ?? (controller.availableUnidades.isNotEmpty ? controller.availableUnidades.first.id : null));
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
                      _fieldLabel(cs, 'UNIDADE ARMAZENADORA'),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<int>(
                        value: selectedFarmId.value,
                        decoration: _dropDeco(cs, Icons.agriculture),
                        items: controller.availableUnidades.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name, style: GoogleFonts.inter(color: cs.onSurface)))).toList(),
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
                      const SizedBox(height: 28),
                      _sectionDivider(cs, 'Custos de Capital'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'CUSTO DE AQUISIÇÃO (R\$)'),
                            const SizedBox(height: 8),
                            _field(cs, custoAquisicaoCtl, '0,00', Icons.monetization_on_outlined, keyboardType: TextInputType.number),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'VALOR RESIDUAL (R\$)'),
                            const SizedBox(height: 8),
                            _field(cs, valorResidualCtl, '0,00', Icons.attach_money_rounded, keyboardType: TextInputType.number),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'VIDA ÚTIL (ANOS)'),
                            const SizedBox(height: 8),
                            _field(cs, vidaUtilCtl, 'Ex: 15', Icons.calendar_today_rounded, keyboardType: TextInputType.number),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'CUSTO DE INSTALAÇÃO (R\$)'),
                            const SizedBox(height: 8),
                            _field(cs, custoInstalacaoCtl, '0,00', Icons.construction_rounded, keyboardType: TextInputType.number),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _sectionDivider(cs, 'Custos Operacionais'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'CONSUMO DE COMBUSTÍVEL (L/h)'),
                            const SizedBox(height: 8),
                            _field(cs, consumoCombustivelCtl, '0,0', Icons.local_gas_station_rounded, keyboardType: TextInputType.number),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'PREÇO DO COMBUSTÍVEL (R\$)'),
                            const SizedBox(height: 8),
                            _field(cs, precoCombustivelCtl, '0,00', Icons.trending_up_rounded, keyboardType: TextInputType.number),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'CONSUMO DE ENERGIA (kWh)'),
                            const SizedBox(height: 8),
                            _field(cs, consumoEnergiaCtl, '0,0', Icons.bolt_rounded, keyboardType: TextInputType.number),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'PREÇO DA ENERGIA (R\$/kWh)'),
                            const SizedBox(height: 8),
                            _field(cs, precoKwhCtl, '0,0000', Icons.electric_bolt_rounded, keyboardType: TextInputType.number),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'MANUTENÇÃO ANUAL (R\$)'),
                            const SizedBox(height: 8),
                            _field(cs, custoManutencaoCtl, '0,00', Icons.build_rounded, keyboardType: TextInputType.number),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fieldLabel(cs, 'MÃO DE OBRA (R\$/h)'),
                            const SizedBox(height: 8),
                            _field(cs, maoObraCtl, '0,00', Icons.handyman_rounded, keyboardType: TextInputType.number),
                          ])),
                        ],
                      ),
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
                                id: secador?.id, unidadeArmazenadoraId: selectedFarmId.value!, nome: nameCtl.text,
                                tipo: selectedType.value, capacidade: double.tryParse(capacityCtl.text) ?? 0,
                                fonteCalor: selectedFuel.value, status: selectedStatus.value, observacoes: obsCtl.text,
                                custoAquisicao: _parseDoubleOrNull(custoAquisicaoCtl.text),
                                valorResidual: _parseDoubleOrNull(valorResidualCtl.text),
                                vidaUtilAnos: int.tryParse(vidaUtilCtl.text),
                                custoInstalacao: _parseDoubleOrNull(custoInstalacaoCtl.text),
                                custoManutencaoAnual: _parseDoubleOrNull(custoManutencaoCtl.text),
                                consumoCombustivelHora: _parseDoubleOrNull(consumoCombustivelCtl.text),
                                precoCombustivel: _parseDoubleOrNull(precoCombustivelCtl.text),
                                consumoEnergiaKwh: _parseDoubleOrNull(consumoEnergiaCtl.text),
                                precoKwh: _parseDoubleOrNull(precoKwhCtl.text),
                                custoMaoObraHora: _parseDoubleOrNull(maoObraCtl.text),
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

  Widget _sectionDivider(ColorScheme cs, String title) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: cs.outlineVariant.withOpacity(0.3))),
      ],
    );
  }

  double? _parseDoubleOrNull(String text) {
    final v = double.tryParse(text);
    return (v != null && v == 0) ? null : v;
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
