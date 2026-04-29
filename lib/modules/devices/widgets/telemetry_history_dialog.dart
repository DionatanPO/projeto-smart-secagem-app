import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/telemetry_model.dart';
import '../../../core/models/sensor_model.dart';
import '../controllers/devices_controller.dart';

class TelemetryHistoryDialog {
  static void show(BuildContext context, SensorModel sensor) {
    // Garante que o controller existe
    if (!Get.isRegistered<DevicesController>()) {
      Get.put(DevicesController());
    }
    final controller = Get.find<DevicesController>();
    controller.getTelemetry(sensor, resetDate: true);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                                      controller,
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
                                      controller,
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
                              _buildTrendChart(context, controller),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
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
                                      physics: const ClampingScrollPhysics(),
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
                              controller,
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
                              controller,
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
                      _buildTrendChart(context, controller),
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

  static Widget _buildDashboardHeader(String title) {
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

  static Widget _buildEmptyHistory() {
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

  static Widget _buildSummaryCard(BuildContext context, DevicesController controller, String title, String avg, String max, String min, IconData icon, Color color) {
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
              _buildMiniMetricCard(isDark, 'MÉDIA', avg, color),
              _buildMetricDivider(isDark),
              _buildMiniMetricCard(isDark, 'MÁXIMA', max, Colors.redAccent),
              _buildMetricDivider(isDark),
              _buildMiniMetricCard(isDark, 'MÍNIMA', min, Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildMiniMetricCard(bool isDark, String label, String value, Color color) {
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

  static Widget _buildMetricDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
    );
  }

  static Widget _buildTelemetryRow(BuildContext context, TelemetryModel item, bool isFirst) {
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
            child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
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
                Text('Sincronizado via Gateway', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
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

  static Widget _buildMiniStats(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w900)),
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  static Widget _buildTrendChart(BuildContext context, DevicesController controller) {
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
                Text(
                  'Sem dados para o dia ${DateFormat('dd/MM/yyyy').format(controller.rxSelectedDate.value)}',
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                ),
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
                              const TextSpan(text: '\n'),
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
                              const TextSpan(text: '\n'),
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

  static Widget _buildLegendDot(Color color, String label) {
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

  static Widget _buildLegendDash(Color color, String label) {
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
