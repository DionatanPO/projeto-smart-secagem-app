import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/sensor_model.dart';
import '../../../core/models/motor_aeracao_model.dart';
import '../../devices/widgets/telemetry_history_dialog.dart';
import '../../devices/widgets/motor_control_card.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/devices_controller.dart';
import '../controllers/aeration_motor_controller.dart';

class DevicesView extends StatefulWidget {
  const DevicesView({super.key});

  @override
  State<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DevicesController sensorCtrl;
  late AerationMotorController motorCtrl;
  final _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
        _searchCtl.clear();
        sensorCtrl.filterSensors('');
        motorCtrl.filterMotors('');
      }
    });
    sensorCtrl = Get.put(DevicesController(), permanent: true);
    motorCtrl = Get.put(AerationMotorController(), permanent: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  bool get _isOnMotorsTab => _tabController.index == 1;

  @override
  Widget build(BuildContext context) {
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
                        _isOnMotorsTab
                            ? 'Controle e monitore seus motores de aeração.'
                            : 'Controle e monitore seus sensores de campo.',
                        style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurfaceVariant,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sensors_rounded, size: 18),
                        const SizedBox(width: 8),
                        Obx(() => Text('Sensores (${sensorCtrl.sensors.length})')),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 18),
                        const SizedBox(width: 8),
                        Obx(() => Text('Motores (${motorCtrl.motors.length})')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SearchBar(
                hintText: _isOnMotorsTab
                    ? 'Buscar motor por ID, descrição, status ou local...'
                    : 'Buscar sensor por ID, descrição, status ou local...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant.withOpacity(0.6))),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerLow),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                elevation: WidgetStatePropertyAll(0),
                padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(horizontal: 16)),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                controller: _searchCtl,
                onChanged: (v) {
                  if (_isOnMotorsTab) {
                    motorCtrl.filterMotors(v);
                  } else {
                    sensorCtrl.filterSensors(v);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSensorsTab(context, cs, isDesktop),
                  _buildMotorsTab(context, cs, isDesktop),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context, cs),
    );
  }

  Widget _buildSensorsTab(BuildContext context, ColorScheme cs, bool isDesktop) {
    return Obx(() {
      sensorCtrl.silos.length;
      sensorCtrl.secadores.length;
      sensorCtrl.unidades.length;
      if (sensorCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = sensorCtrl.filteredSensors;
      if (list.isEmpty) {
        return _buildEmptyState(
          icon: Icons.sensors_off_rounded,
          title: sensorCtrl.searchQuery.value.isNotEmpty ? 'Nenhum sensor encontrado' : 'Nenhum sensor configurado',
          subtitle: sensorCtrl.searchQuery.value.isNotEmpty ? 'Tente ajustar sua busca.' : 'Clique em "Configurar Novo" para adicionar.',
        );
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
    });
  }

  Widget _buildMotorsTab(BuildContext context, ColorScheme cs, bool isDesktop) {
    return Obx(() {
      motorCtrl.silos.length;
      motorCtrl.secadores.length;
      if (motorCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = motorCtrl.filteredMotors;
      if (list.isEmpty) {
        return _buildEmptyState(
          icon: Icons.electrical_services_rounded,
          title: motorCtrl.searchQuery.value.isNotEmpty ? 'Nenhum motor encontrado' : 'Nenhum motor configurado',
          subtitle: motorCtrl.searchQuery.value.isNotEmpty ? 'Tente ajustar sua busca.' : 'Clique em "Configurar Novo" para adicionar.',
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isDesktop ? (constraints.maxWidth ~/ 360).clamp(2, 4) : 1;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 280,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) => MotorControlCard(motor: list[index]),
          );
        },
      );
    });
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
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
            child: Icon(icon, size: 36, color: cs.onSurfaceVariant.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context, ColorScheme cs) {
    return FloatingActionButton(
      onPressed: () => _showFabMenu(context),
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const Icon(Icons.add_rounded),
    );
  }

  void _showFabMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final renderBox = context.findRenderObject() as RenderBox;
    final fabPos = renderBox.localToGlobal(Offset(
      renderBox.size.width - 56,
      renderBox.size.height - 56,
    ));

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        fabPos.dx - 120,
        fabPos.dy - 120,
        fabPos.dx + 56,
        fabPos.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cs.surface,
      elevation: 4,
      items: [
        PopupMenuItem(
          value: 'sensor',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.sensors_rounded, size: 20, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cadastrar Sensor', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                    Text('Monitoramento de temperatura/umidade', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'motor',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.bolt_rounded, size: 20, color: Colors.orange.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cadastrar Motor', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
                    Text('Motor de aeração de silos', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'sensor') {
        _showSensorForm(context);
      } else if (value == 'motor') {
        _showMotorForm(context);
      }
    });
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
      final silo = sensorCtrl.silos.firstWhereOrNull((s) => s.id == sensor.siloId);
      locationName = sensor.siloName ?? silo?.name ?? 'Silo #${sensor.siloId}';
      locationIcon = Icons.warehouse_rounded;
    } else if (sensor.secadorId != null) {
      final secador = sensorCtrl.secadores.firstWhereOrNull((s) => s.id == sensor.secadorId);
      locationName = sensor.secadorName ?? secador?.nome ?? 'Secador #${sensor.secadorId}';
      locationIcon = Icons.settings_input_component_rounded;
    } else if (sensor.unidadeArmazenadoraId != null) {
      final unidade = sensorCtrl.unidades.firstWhereOrNull((u) => u.id == sensor.unidadeArmazenadoraId);
      locationName = sensor.unidadeArmazenadoraNome ?? unidade?.name ?? 'Unidade #${sensor.unidadeArmazenadoraId}';
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
    final selectedFarmId = (sensor?.unidadeArmazenadoraId).obs;
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
                          Text(isEditing ? 'Editar Sensor' : 'Novo Sensor', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text(isEditing ? 'Atualize as informações do sensor.' : 'Cadastre um novo sensor de campo.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
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
                          final hasFarm = sensorCtrl.unidades.any((u) => u.id == selectedFarmId.value);
                          return DropdownButtonFormField<int>(
                            value: hasFarm ? selectedFarmId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Unidade Armazenadora', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...sensorCtrl.unidades.map((u) => DropdownMenuItem(value: u.id, child: Text('Unidade: ${u.name}'))),
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
                          final hasSilo = sensorCtrl.silos.any((s) => s.id == selectedSiloId.value);
                          return DropdownButtonFormField<int>(
                            value: hasSilo ? selectedSiloId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Silo', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...sensorCtrl.silos.map((silo) => DropdownMenuItem(value: silo.id, child: Text('Silo: ${silo.name}'))),
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
                          final hasSec = sensorCtrl.secadores.any((s) => s.id == selectedSecadorId.value);
                          return DropdownButtonFormField<int>(
                            value: hasSec ? selectedSecadorId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Secador', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...sensorCtrl.secadores.map((sec) => DropdownMenuItem(value: sec.id, child: Text('Secador: ${sec.nome}'))),
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
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
                                      unidadeArmazenadoraId: selectedFarmId.value,
                                      siloId: selectedSiloId.value,
                                      secadorId: selectedSecadorId.value,
                                      status: status.value,
                                    );
                                    if (isEditing) {
                                      sensorCtrl.updateSensor(newSensor);
                                    } else {
                                      sensorCtrl.createSensor(newSensor);
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                child: Text(isEditing ? 'Atualizar Sensor' : 'Cadastrar Sensor', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

  void _showMotorForm(BuildContext context, {MotorAeracaoModel? motor}) {
    final isEditing = motor != null;
    final cs = Theme.of(context).colorScheme;

    final motorIdCtl = TextEditingController(text: motor?.motorId ?? '');
    final descriptionCtl = TextEditingController(text: motor?.description ?? '');
    final potenciaCtl = TextEditingController(text: motor?.potenciaKW?.toString() ?? '');
    final rpmCtl = TextEditingController(text: motor?.rpm?.toString() ?? '');
    final vazaoCtl = TextEditingController(text: motor?.vazaoAr?.toString() ?? '');
    final horimetroCtl = TextEditingController(text: motor?.horimetro?.toString() ?? '');

    final selectedSiloId = (motor?.siloId).obs;
    final selectedSecadorId = (motor?.secadorId).obs;

    final validStatuses = ['ativo', 'manutencao', 'falha', 'desativado'];
    final rawStatus = motor?.status.toLowerCase() ?? 'ativo';
    final status = (validStatuses.contains(rawStatus) ? rawStatus : 'ativo').obs;

    final formKey = GlobalKey<FormState>();

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
                          Text(isEditing ? 'Editar Motor' : 'Novo Motor de Aeração', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text(isEditing ? 'Atualize as informações do motor.' : 'Cadastre um novo motor de aeração.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
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
                        _fieldLabel(cs, 'IDENTIFICAÇÃO DO MOTOR'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: motorIdCtl,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          decoration: _fieldDeco(cs, 'Ex: MOTOR-AER-001', Icons.fingerprint_rounded),
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel(cs, 'DESCRIÇÃO / LOCALIZAÇÃO'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: descriptionCtl,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          decoration: _fieldDeco(cs, 'Ex: Aeração Sul - Silo 3', Icons.location_on_rounded),
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel(cs, 'PARÂMETROS TÉCNICOS'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: potenciaCtl,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: _fieldDeco(cs, 'kW', Icons.electric_bolt_rounded),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: rpmCtl,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: _fieldDeco(cs, 'RPM', Icons.speed_rounded),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: vazaoCtl,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: _fieldDeco(cs, 'm³/h', Icons.air_rounded),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: horimetroCtl,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: _fieldDeco(cs, 'Horas', Icons.timer_rounded),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel(cs, 'VINCULAR A'),
                        const SizedBox(height: 8),
                        Obx(() {
                          final hasSilo = motorCtrl.silos.any((s) => s.id == selectedSiloId.value);
                          return DropdownButtonFormField<int>(
                            value: hasSilo ? selectedSiloId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Silo', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...motorCtrl.silos.map((silo) => DropdownMenuItem(value: silo.id, child: Text('Silo: ${silo.name}'))),
                            ],
                            onChanged: (v) {
                              selectedSiloId.value = v;
                              if (v != null) { selectedSecadorId.value = null; }
                            },
                            decoration: _fieldDeco(cs, '', Icons.warehouse_rounded),
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() {
                          final hasSec = motorCtrl.secadores.any((s) => s.id == selectedSecadorId.value);
                          return DropdownButtonFormField<int>(
                            value: hasSec ? selectedSecadorId.value : null,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            dropdownColor: cs.surface,
                            hint: Text('Secador', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Nenhum')),
                              ...motorCtrl.secadores.map((sec) => DropdownMenuItem(value: sec.id, child: Text('Secador: ${sec.nome}'))),
                            ],
                            onChanged: (v) {
                              selectedSecadorId.value = v;
                              if (v != null) { selectedSiloId.value = null; }
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
                            DropdownMenuItem(value: 'falha', child: Text('Falha')),
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
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    final newMotor = MotorAeracaoModel(
                                      id: motor?.id,
                                      motorId: motorIdCtl.text,
                                      description: descriptionCtl.text,
                                      potenciaKW: double.tryParse(potenciaCtl.text),
                                      rpm: double.tryParse(rpmCtl.text),
                                      vazaoAr: double.tryParse(vazaoCtl.text),
                                      horimetro: double.tryParse(horimetroCtl.text),
                                      siloId: selectedSiloId.value,
                                      secadorId: selectedSecadorId.value,
                                      status: status.value,
                                    );
                                    if (isEditing) {
                                      motorCtrl.updateMotor(newMotor);
                                    } else {
                                      motorCtrl.createMotor(newMotor);
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                child: Text(isEditing ? 'Atualizar Motor' : 'Cadastrar Motor', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
    return Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: cs.primary, letterSpacing: 1.1));
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
            Text('Deseja realmente remover o sensor ${sensor.sensorId}? Esta ação não poderá ser desfeita.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: cs.onSurfaceVariant, fontSize: 14)),
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
                    style: FilledButton.styleFrom(backgroundColor: cs.error, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () { sensorCtrl.deleteSensor(sensor.id!); Get.back(); },
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
