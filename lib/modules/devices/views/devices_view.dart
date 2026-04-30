import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/telemetry_model.dart';
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

    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isDesktop) ...[
                          IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: const Icon(Icons.menu_rounded),
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Gestão de Dispositivos',
                                  style: (isDesktop
                                          ? theme.textTheme.headlineSmall
                                          : theme.textTheme.titleLarge)
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Controle e monitore seus sensores de campo.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Obx(() => _buildSensorsList(context)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSensorForm(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.sensors_rounded),
        label: Text(
          'Configurar Novo',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }


  Widget _buildSensorsList(BuildContext context) {
    if (controller.sensors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors_off_rounded, size: 64, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            const Text('Nenhum sensor configurado'),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: controller.sensors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sensor = controller.sensors[index];
        return _buildSensorItem(context, sensor);
      },
    );
  }

  Widget _buildSensorItem(BuildContext context, SensorModel sensor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Mapeamento de status para cores
    Color statusColor;
    switch (sensor.status.toLowerCase()) {
      case 'ativo': statusColor = Colors.green; break;
      case 'manutencao': statusColor = Colors.orange; break;
      case 'falha': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => TelemetryHistoryDialog.show(context, sensor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
          ),
        ),
        child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.sensors_rounded,
                    color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sensor.description,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Gateway ID: ${sensor.sensorId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.5),
                          fontSize: 11)),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warehouse_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(sensor.siloName ?? 'Silo #${sensor.siloId}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(sensor.status.toUpperCase(),
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ],
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showSensorForm(context, sensor: sensor);
                  } else if (value == 'delete') {
                    _confirmDeleteSensor(context, sensor);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}


extension DevicesViewExtension on DevicesView {
  void _showSensorForm(BuildContext context, {SensorModel? sensor}) {
    final isEditing = sensor != null;
    final gatewayIdController = TextEditingController(text: sensor?.sensorId ?? '');
    final descriptionController = TextEditingController(text: sensor?.description ?? '');
    final selectedSiloId = (sensor?.siloId ?? (controller.silos.isNotEmpty ? controller.silos[0].id : null)).obs;
    final status = (sensor?.status ?? 'ativo').obs;
    final formKey = GlobalKey<FormState>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Editar Sensor' : 'Novo Sensor',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              isEditing ? 'Atualize as informações do sensor.' : 'Cadastre um novo sensor de campo.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildFieldLabel('ID DO DISPOSITIVO (GATEWAY)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: gatewayIdController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: _buildInputDecoration('Ex: SENSOR-001', Icons.fingerprint_rounded, isDark),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('DESCRIÇÃO / LOCALIZAÇÃO'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: _buildInputDecoration('Ex: Setor A - Nível 1', Icons.location_on_rounded, isDark),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('SILO VINCULADO'),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<int>(
                        value: selectedSiloId.value,
                        style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        items: controller.silos.map((silo) => DropdownMenuItem(
                          value: silo.id,
                          child: Text(silo.name),
                        )).toList(),
                        onChanged: (v) => selectedSiloId.value = v!,
                        decoration: _buildInputDecoration('', Icons.warehouse_rounded, isDark),
                      )),
                  const SizedBox(height: 24),
                  _buildFieldLabel('STATUS OPERACIONAL'),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<String>(
                        value: status.value,
                        style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        items: const [
                          DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                          DropdownMenuItem(value: 'manutencao', child: Text('Manutenção')),
                          DropdownMenuItem(value: 'falha', child: Text('Falha')),
                          DropdownMenuItem(value: 'desativado', child: Text('Desativado')),
                        ],
                        onChanged: (v) => status.value = v!,
                        decoration: _buildInputDecoration('', Icons.info_outline_rounded, isDark),
                      )),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final newSensor = SensorModel(
                                id: sensor?.id,
                                sensorId: gatewayIdController.text,
                                description: descriptionController.text,
                                siloId: selectedSiloId.value!,
                                status: status.value,
                              );
                              if (isEditing) {
                                controller.updateSensor(newSensor);
                              } else {
                                controller.createSensor(newSensor);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            isEditing ? 'Atualizar Sensor' : 'Cadastrar Sensor',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        letterSpacing: 1.1,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.5)),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  void _confirmDeleteSensor(BuildContext context, SensorModel sensor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Excluir Sensor',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Deseja realmente remover o sensor ${sensor.sensorId}? Esta ação não poderá ser desfeita.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        controller.deleteSensor(sensor.id!);
                        Get.back();
                      },
                      child: Text('Excluir', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
