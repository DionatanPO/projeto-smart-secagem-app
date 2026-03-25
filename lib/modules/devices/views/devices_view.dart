import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/telemetry_model.dart';
import '../../../core/models/sensor_model.dart';
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

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
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
                          Text(
                            'Gestão de Dispositivos',
                            style: (isDesktop
                                    ? theme.textTheme.headlineSmall
                                    : theme.textTheme.titleLarge)
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Controle e monitore seus hubs de comunicação e sensores.',
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
                ElevatedButton.icon(
                  onPressed: () => _showSensorForm(context),
                  icon: const Icon(Icons.hub_rounded, size: 20),
                  label: const Text('Configurar Novo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTabBar(context),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildHubsList(context);
              } else {
                return _buildSensorsList(context);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTabItem(context, 0, 'Controladores (HUBS)',
                  Icons.router_rounded, controller.selectedTab.value == 0),
              _buildTabItem(context, 1, 'Sensores', Icons.sensors_rounded,
                  controller.selectedTab.value == 1),
            ],
          )),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, String label,
      IconData icon, bool isSelected) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? theme.primaryColor
                  : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.primaryColor
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubsList(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        mainAxisExtent: 220, // Increased height to prevent overflow
      ),
      itemCount: controller.hubs.length,
      itemBuilder: (context, index) {
        final hub = controller.hubs[index];
        return _buildHubCard(context, hub);
      },
    );
  }

  Widget _buildHubCard(BuildContext context, Map<String, dynamic> hub) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOnline = hub['status'] == 'Online';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isOnline ? theme.primaryColor : Colors.grey)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.router_rounded,
                    color: isOnline ? theme.primaryColor : Colors.grey,
                    size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hub['name'] as String,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      hub['id'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (isOnline ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hub['status'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOnline ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 90,
                child: _buildStatusBar(
                  context,
                  'Sinal',
                  hub['signal'] as double,
                  Icons.wifi_rounded,
                  isOnline ? theme.primaryColor : Colors.grey,
                ),
              ),
              SizedBox(
                width: 90,
                child: _buildStatusBar(
                  context,
                  'Bateria',
                  hub['battery'] as double,
                  hub['battery'] == 1.0
                      ? Icons.power_rounded
                      : Icons.battery_charging_full_rounded,
                  isOnline ? Colors.green : Colors.grey,
                ),
              ),
              SizedBox(
                width: 90,
                child: _buildStatusBar(
                  context,
                  'Sensores',
                  (hub['connectedDevices'] as int) / 20,
                  Icons.sensors_rounded,
                  isOnline ? Colors.blue : Colors.grey,
                  customText: '${hub['connectedDevices']}',
                ),
              ),
            ],
          ),
        ],
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
      onTap: () => _showTelemetryHistory(context, sensor),
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

  void _showTelemetryHistory(BuildContext context, SensorModel sensor) {
    controller.getTelemetry(sensor, resetDate: true);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalhamento do Sensor',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Sensor: ${sensor.sensorId}',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => controller.selectDate(context),
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Obx(() => Text(
                  DateFormat('dd/MM/yyyy').format(controller.rxSelectedDate.value),
                )),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
              IconButton(
                onPressed: () => controller.getTelemetry(sensor, resetDate: false),
                icon: const Icon(Icons.sync_rounded),
                tooltip: 'Atualizar',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Obx(() {
            if (controller.isLoadingTelemetry.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3),
                    SizedBox(height: 16),
                    Text('Sincronizando dados históricos...'),
                  ],
                ),
              );
            }

            final data = controller.filteredTelemetryList;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1100;
                  
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coluna da Esquerda: Gráficos e Stats
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDashboardHeader('VISÃO GERAL DO PERÍODO'),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildSummaryCard(
                                      context,
                                      'Temperatura',
                                      '${controller.reativeAvgTemp.value.toStringAsFixed(1)}°C',
                                      '${controller.reativeMaxTemp.value.toStringAsFixed(1)}°C',
                                      '${controller.reativeMinTemp.value.toStringAsFixed(1)}°C',
                                      Icons.thermostat_auto_rounded,
                                      Colors.orange,
                                    ),
                                    const SizedBox(width: 24),
                                    _buildSummaryCard(
                                      context,
                                      'Umidade',
                                      '${controller.reativeAvgHum.value.toStringAsFixed(1)}%',
                                      '${controller.reativeMaxHum.value.toStringAsFixed(1)}%',
                                      '${controller.reativeMinHum.value.toStringAsFixed(1)}%',
                                      Icons.water_drop_rounded,
                                      Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildDashboardHeader('TENDÊNCIA TEMPORAL'),
                              const SizedBox(height: 16),
                              _buildTrendChart(context),
                              const SizedBox(height: 100), // Espaço extra bottom
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Coluna da Direita: Histórico de Leituras
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDashboardHeader('HISTÓRICO DE LEITURAS (${data.length})'),
                              const SizedBox(height: 16),
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: 400,
                                  maxHeight: MediaQuery.of(context).size.height - 200,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark.withOpacity(0.5) : Colors.black.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
                                ),
                                child: data.isEmpty 
                                  ? _buildEmptyHistory()
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(), // Melhor para nested scroll
                                      itemCount: data.length,
                                      itemBuilder: (context, index) => _buildTelemetryRow(context, data[index], index == 0),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Layout Mobile (Coluna Única)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDashboardHeader('VISÃO GERAL'),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSummaryCard(
                              context,
                              'Temperatura',
                              '${controller.reativeAvgTemp.value.toStringAsFixed(1)}°C',
                              '${controller.reativeMaxTemp.value.toStringAsFixed(1)}°C',
                              '${controller.reativeMinTemp.value.toStringAsFixed(1)}°C',
                              Icons.thermostat_auto_rounded,
                              Colors.orange,
                            ),
                            const SizedBox(width: 16),
                            _buildSummaryCard(
                              context,
                              'Umidade',
                              '${controller.reativeAvgHum.value.toStringAsFixed(1)}%',
                              '${controller.reativeMaxHum.value.toStringAsFixed(1)}%',
                              '${controller.reativeMinHum.value.toStringAsFixed(1)}%',
                              Icons.water_drop_rounded,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildDashboardHeader('TENDÊNCIA TEMPORAL'),
                      const SizedBox(height: 16),
                      _buildTrendChart(context),
                      const SizedBox(height: 32),
                      _buildDashboardHeader('ÚLTIMAS LEITURAS'),
                      const SizedBox(height: 16),
                      if (data.isEmpty) 
                        _buildEmptyHistory()
                      else
                        ...data.take(20).map((item) => _buildTelemetryRow(context, item, data.indexOf(item) == 0)),
                    ],
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded,
              size: 48, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Nenhum registro encontrado',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String avg, String max, String min, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetricCard('MÉDIA', avg, color, isDark),
              _buildMetricDivider(isDark),
              _buildMiniMetricCard('MÁXIMA', max, Colors.redAccent, isDark),
              _buildMetricDivider(isDark),
              _buildMiniMetricCard('MÍNIMA', min, Colors.blueAccent, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricCard(String label, String value, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }



  Widget _buildTelemetryRow(BuildContext context, TelemetryModel item, bool isFirst) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst ? AppColors.primary.withOpacity(0.3) : (isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                   DateFormat('dd/MM/yyyy HH:mm:ss').format(item.timestamp),
                   style: GoogleFonts.inter(fontSize: 13, fontWeight: isFirst ? FontWeight.bold : FontWeight.w500),
                ),
                Text('Sincronizado via Gateway Hub', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          _buildMiniStats('TEMP', '${item.temperature.toStringAsFixed(1)}°C', Colors.orange),
          const SizedBox(width: 24),
          _buildMiniStats('UMID', '${item.humidity.toStringAsFixed(1)}%', Colors.blue),
          if (isFirst) ...[
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'ÚLTIMA',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStats(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w900)),
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMiniMetric(BuildContext context, IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildTrendChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.tempSpots.isEmpty && controller.humSpots.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.show_chart_rounded, size: 48, color: Colors.grey.withOpacity(0.25)),
                const SizedBox(height: 12),
                Obx(() => Text(
                  'Sem dados para o dia ${DateFormat('dd/MM/yyyy').format(controller.rxSelectedDate.value)}',
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                )),
                const SizedBox(height: 4),
                Text(
                  'As leituras do dia selecionado aparecerão aqui',
                  style: GoogleFonts.inter(color: Colors.grey.withOpacity(0.6), fontSize: 11),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legenda do gráfico
            Row(
              children: [
                _buildLegendDot(Colors.orange, 'Temperatura (°C)'),
                const SizedBox(width: 20),
                _buildLegendDash(Colors.blue, 'Umidade (%)'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.blue.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (controller.chartLabels.length / 6).clamp(1, 100).toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < controller.chartLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                controller.chartLabels[index],
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}°',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.orange.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Temperatura
                    LineChartBarData(
                      spots: controller.tempSpots,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.orange,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.12),
                            Colors.orange.withOpacity(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Umidade
                    LineChartBarData(
                      spots: controller.humSpots,
                      isCurved: true,
                      color: Colors.blue.withOpacity(0.85),
                      barWidth: 2.5,
                      dashArray: [6, 4],
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 1.5,
                          strokeColor: Colors.blue,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.07),
                            Colors.blue.withOpacity(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) =>
                          isDark ? AppColors.surfaceDark : Colors.white,
                      tooltipBorder: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isTemp = spot.barIndex == 0;
                          final index = spot.x.toInt();
                          final label = (index >= 0 &&
                                  index < controller.chartLabels.length)
                              ? controller.chartLabels[index]
                              : '';
                          return LineTooltipItem(
                            isTemp ? 'TEMPERATURA' : 'UMIDADE',
                            GoogleFonts.inter(
                              color: isTemp ? Colors.orange : Colors.blue,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                            children: [
                              TextSpan(text: '\n'),
                              TextSpan(
                                text:
                                    '${spot.y.toStringAsFixed(1)}${isTemp ? '°C' : '%'}',
                                style: GoogleFonts.outfit(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(text: '\n'),
                              TextSpan(
                                text: label,
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDash(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(
            3,
            (i) => Container(
              width: 5,
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
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

    Get.dialog(
      AlertDialog(
        title: Text(isEditing ? 'Editar Sensor' : 'Novo Sensor'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: gatewayIdController,
                  decoration: const InputDecoration(labelText: 'ID do Dispositivo (Gateway)'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição/Localização'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<int>(
                      value: selectedSiloId.value,
                      items: controller.silos.map((silo) => DropdownMenuItem(
                        value: silo.id,
                        child: Text(silo.name),
                      )).toList(),
                      onChanged: (v) => selectedSiloId.value = v!,
                      decoration: const InputDecoration(labelText: 'Silo Vinculado'),
                    )),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<String>(
                      value: status.value,
                      items: const [
                        DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                        DropdownMenuItem(value: 'manutencao', child: Text('Manutenção')),
                        DropdownMenuItem(value: 'falha', child: Text('Falha')),
                        DropdownMenuItem(value: 'desativado', child: Text('Desativado')),
                      ],
                      onChanged: (v) => status.value = v!,
                      decoration: const InputDecoration(labelText: 'Status'),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
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
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSensor(BuildContext context, SensorModel sensor) {
    Get.dialog(
      AlertDialog(
        title: const Text('Excluir Sensor'),
        content: Text('Deseja excluir o sensor ${sensor.sensorId}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              controller.deleteSensor(sensor.id!);
              Get.back();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, String label, double value,
      IconData icon, Color color,
      {String? customText}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Expanded(
                child: Text(label,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          width: constraints.maxWidth * value,
                          height: 6,
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              customText ?? '${(value * 100).toInt()}%',
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }
}
