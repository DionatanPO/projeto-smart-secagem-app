import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/sensor_model.dart';
import '../../devices/widgets/telemetry_history_dialog.dart';
import '../controllers/devices_controller.dart';

class DevicesView extends GetView<DevicesController> {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DevicesController>()) {
      Get.put(DevicesController());
    }

    final cs = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
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
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestão de Dispositivos',
                        style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Controle e monitore seus sensores de campo.',
                        style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: SearchBar(
                hintText: 'Buscar por ID, descrição, status ou local...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant.withOpacity(0.6))),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerLow),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                elevation: WidgetStatePropertyAll(0),
                padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(horizontal: 16)),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                onChanged: controller.filterSensors,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                // Observa as listas de lookup para reconstruir quando carregarem
                controller.silos.length;
                controller.secadores.length;
                controller.farms.length;
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = controller.filteredSensors;
                if (list.isEmpty) {
                  return _buildEmptyState(context, controller.searchQuery.value.isNotEmpty);
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = isDesktop ? (constraints.maxWidth ~/ 360).clamp(2, 4) : 1;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent: 240,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) => _buildSensorCard(context, list[index]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSensorForm(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.sensors_rounded),
        label: Text(
          'Configurar Novo',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearch) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(isSearch ? Icons.search_off_rounded : Icons.sensors_off_rounded, size: 36, color: cs.onSurfaceVariant.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            isSearch ? 'Nenhum sensor encontrado' : 'Nenhum sensor configurado',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch ? 'Tente ajustar sua busca.' : 'Clique em "Configurar Novo" para adicionar.',
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(BuildContext context, SensorModel sensor) {
    final cs = Theme.of(context).colorScheme;

    Color statusColor;
    switch (sensor.status.toLowerCase()) {
      case 'ativo': statusColor = Colors.green; break;
      case 'manutencao': statusColor = Colors.orange; break;
      case 'falha': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    String locationName;
    IconData locationIcon;
    if (sensor.siloId != null) {
      final silo = controller.silos.firstWhereOrNull((s) => s.id == sensor.siloId);
      locationName = sensor.siloName ?? silo?.name ?? 'Silo #${sensor.siloId}';
      locationIcon = Icons.warehouse_rounded;
    } else if (sensor.secadorId != null) {
      final secador = controller.secadores.firstWhereOrNull((s) => s.id == sensor.secadorId);
      locationName = sensor.secadorName ?? secador?.nome ?? 'Secador #${sensor.secadorId}';
      locationIcon = Icons.settings_input_component_rounded;
    } else if (sensor.farmId != null) {
      final farm = controller.farms.firstWhereOrNull((f) => f.id == sensor.farmId);
      locationName = sensor.farmName ?? farm?.name ?? 'Fazenda #${sensor.farmId}';
      locationIcon = Icons.agriculture_rounded;
    } else {
      locationName = 'Não vinculado';
      locationIcon = Icons.link_off_rounded;
    }

    return Card(
      color: cs.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => TelemetryHistoryDialog.show(context, sensor),
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
                    child: Icon(Icons.sensors_rounded, color: cs.onPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sensor.sensorId, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(sensor.description, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(sensor.status, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.3)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoRow(cs, Icons.category_rounded, 'Tipo', sensor.tipo.replaceAll('_', ' ')),
              const SizedBox(height: 8),
              _infoRow(cs, locationIcon, 'Vinculado a', locationName),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert_rounded, size: 18, color: cs.onSurfaceVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    color: cs.surfaceContainerLow,
                    onSelected: (value) {
                      if (value == 0) _showSensorForm(context, sensor: sensor);
                      if (value == 1) _confirmDeleteSensor(context, sensor);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
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

  Widget _infoRow(ColorScheme cs, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  void _showSensorForm(BuildContext context, {SensorModel? sensor}) {
    final isEditing = sensor != null;
    final cs = Theme.of(context).colorScheme;
    final gatewayIdController = TextEditingController(text: sensor?.sensorId ?? '');
    final descriptionController = TextEditingController(text: sensor?.description ?? '');
    final selectedFarmId = (sensor?.farmId).obs;
    final selectedSiloId = (sensor?.siloId).obs;
    final selectedSecadorId = (sensor?.secadorId).obs;
    final validStatuses = ['ativo', 'manutencao', 'falha', 'desativado'];
    final rawStatus = sensor?.status.toLowerCase() ?? 'ativo';
    final status = (validStatuses.contains(rawStatus) ? rawStatus : 'ativo').obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
          ),
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
                          Text(
                            isEditing ? 'Editar Sensor' : 'Novo Sensor',
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing ? 'Atualize as informações do sensor.' : 'Cadastre um novo sensor de campo.',
                            style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8)),
                          ),
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
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(cs, 'ID DO DISPOSITIVO (GATEWAY)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: gatewayIdController,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          decoration: _fieldDeco(cs, 'Ex: SENSOR-001', Icons.fingerprint_rounded),
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel(cs, 'DESCRIÇÃO / LOCALIZAÇÃO'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: descriptionController,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          decoration: _fieldDeco(cs, 'Ex: Setor A - Nível 1', Icons.location_on_rounded),
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel(cs, 'VINCULAR A'),
                        const SizedBox(height: 8),
                        Obx(() {
                          final hasFarm = controller.farms.any((f) => f.id == selectedFarmId.value);
                          return DropdownButtonFormField<int>(
                            value: hasFarm ? selectedFarmId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Fazenda', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...controller.farms.map((f) => DropdownMenuItem(
                                value: f.id,
                                child: Text('Fazenda: ${f.name}'),
                              )),
                            ],
                            onChanged: (v) {
                              selectedFarmId.value = v;
                              if (v != null) { selectedSiloId.value = null; selectedSecadorId.value = null; }
                            },
                            decoration: _fieldDeco(cs, '', Icons.agriculture_rounded),
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() {
                          final hasSilo = controller.silos.any((s) => s.id == selectedSiloId.value);
                          return DropdownButtonFormField<int>(
                            value: hasSilo ? selectedSiloId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Silo', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...controller.silos.map((silo) => DropdownMenuItem(
                                value: silo.id,
                                child: Text('Silo: ${silo.name}'),
                              )),
                            ],
                            onChanged: (v) {
                              selectedSiloId.value = v;
                              if (v != null) { selectedFarmId.value = null; selectedSecadorId.value = null; }
                            },
                            decoration: _fieldDeco(cs, '', Icons.warehouse_rounded),
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() {
                          final hasSec = controller.secadores.any((s) => s.id == selectedSecadorId.value);
                          return DropdownButtonFormField<int>(
                            value: hasSec ? selectedSecadorId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Secador', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...controller.secadores.map((sec) => DropdownMenuItem(
                                value: sec.id,
                                child: Text('Secador: ${sec.nome}'),
                              )),
                            ],
                            onChanged: (v) {
                              selectedSecadorId.value = v;
                              if (v != null) { selectedFarmId.value = null; selectedSiloId.value = null; }
                            },
                            decoration: _fieldDeco(cs, '', Icons.settings_input_component_rounded),
                          );
                        }),
                        const SizedBox(height: 24),
                        _fieldLabel(cs, 'STATUS OPERACIONAL'),
                        const SizedBox(height: 8),
                        Obx(() => DropdownButtonFormField<String>(
                          value: status.value,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          dropdownColor: cs.surface,
                          items: const [
                            DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                            DropdownMenuItem(value: 'manutencao', child: Text('Em Manutenção')),
                            DropdownMenuItem(value: 'falha', child: Text('Falha de Leitura')),
                            DropdownMenuItem(value: 'desativado', child: Text('Desativado')),
                          ],
                          onChanged: (v) => status.value = v!,
                          decoration: _fieldDeco(cs, '', Icons.info_outline_rounded),
                        )),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Get.back(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    final newSensor = SensorModel(
                                      id: sensor?.id,
                                      sensorId: gatewayIdController.text,
                                      description: descriptionController.text,
                                      farmId: selectedFarmId.value,
                                      siloId: selectedSiloId.value,
                                      secadorId: selectedSecadorId.value,
                                      status: status.value,
                                    );
                                    if (isEditing) {
                                      controller.updateSensor(newSensor);
                                    } else {
                                      controller.createSensor(newSensor);
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(
                                  isEditing ? 'Atualizar Sensor' : 'Cadastrar Sensor',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
    return Text(
      label,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: cs.primary, letterSpacing: 1.1),
    );
  }

  InputDecoration _fieldDeco(ColorScheme cs, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant.withOpacity(0.5)),
      prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.5)),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  void _confirmDeleteSensor(BuildContext context, SensorModel sensor) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cs.error.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.delete_forever_rounded, color: cs.error, size: 40),
            ),
            const SizedBox(height: 24),
            Text('Excluir Sensor', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 12),
            Text('Deseja realmente remover o sensor ${sensor.sensorId}? Esta ação não poderá ser desfeita.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      controller.deleteSensor(sensor.id!);
                      Get.back();
                    },
                    child: Text('Excluir', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
