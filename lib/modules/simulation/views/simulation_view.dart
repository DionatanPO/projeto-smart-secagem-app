import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/simulation_controller.dart';

class SimulationView extends GetView<SimulationController> {
  const SimulationView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SimulationController>()) {
      Get.put(SimulationController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Simulador Interativo',
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
                            'Entenda como a IA reage ao clima.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Obx(() => Text(
                      'Hora: ${controller.simulationTime.value.toString().padLeft(2, '0')}:00',
                      style: GoogleFonts.outfit(
                        fontSize: isDesktop ? 28 : 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1100;
              final childWidgets = [
                Expanded(
                  flex: isDesktop ? 5 : 0,
                  child: _buildVisualSilo(context, isDark),
                ),
                SizedBox(width: isDesktop ? 32 : 0, height: isDesktop ? 0 : 32),
                Expanded(
                  flex: isDesktop ? 4 : 0,
                  child: Column(
                    children: [
                      _buildWeatherControls(context, isDark),
                      const SizedBox(height: 24),
                      _buildSimulationLogs(context, isDark),
                    ],
                  ),
                ),
              ];

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: childWidgets,
                );
              } else {
                return Column(
                  children: [
                    _buildVisualSilo(context, isDark),
                    const SizedBox(height: 32),
                    _buildWeatherControls(context, isDark),
                    const SizedBox(height: 32),
                    _buildSimulationLogs(context, isDark),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 40),
          _buildSimulationChart(context, isDark),
          const SizedBox(height: 40),
          _buildEducationalInfo(context, isDark),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildVisualSilo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Silo 01 (Massa de Grãos)',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              // Desenho Base do Silo
              Container(
                width: 250,
                height: 350,
                decoration: BoxDecoration(
                  color: (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05)),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(125), bottom: Radius.circular(12)),
                  border:
                      Border.all(color: Colors.grey.withOpacity(0.3), width: 3),
                ),
              ),
              // Nível de Grãos (Simbolico)
              Positioned(
                bottom: 3,
                child: Obx(() => Container(
                      width: 244,
                      height: 200,
                      decoration: BoxDecoration(
                        color: controller.siloColor.value,
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                controller.siloStatusMessage.value
                                    .toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${controller.internalTemp.value.toStringAsFixed(1)}°C',
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'Temperatura Interna',
                              style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${controller.internalHum.value.toStringAsFixed(1)}%',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'Umidade do Grão',
                              style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Atuador (Motor)
          Obx(() => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: controller.isAerationOn.value
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: controller.isAerationOn.value
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.error.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedExhaustFan(
                      isOn: controller.isAerationOn.value,
                      color: controller.isAerationOn.value
                          ? AppColors.primary
                          : AppColors.error,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS DOS EXAUSTORES',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: controller.isAerationOn.value
                                  ? AppColors.primary
                                  : AppColors.error,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            controller.isAerationOn.value
                                ? 'LIGADOS'
                                : 'DESLIGADOS',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          // Explicação da IA
          Obx(() => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: controller.isAerationOn.value
                            ? AppColors.primary
                            : Colors.grey,
                        size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Decisão da Inteligência:',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.actionReason.value,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.4,
                                color:
                                    isDark ? Colors.white70 : Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWeatherControls(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_rounded, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Text(
                'Clima Externo (Estação)',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildClimateStat(
                    'Temperatura Ext.',
                    '${controller.externalTemp.value.toStringAsFixed(1)}°C',
                    Icons.thermostat_rounded,
                    Colors.orange)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => _buildClimateStat(
                    'Umidade Ext.',
                    '${controller.externalHum.value.toStringAsFixed(1)}%',
                    Icons.water_drop_rounded,
                    Colors.blueAccent)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Controles do Simulador',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.toggleSimulation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isPlaying.value
                            ? AppColors.error
                            : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(
                          controller.isPlaying.value
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white),
                      label: Text(
                        controller.isPlaying.value
                            ? 'Pausar'
                            : 'Play Automático',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.advanceOneHour(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.fast_forward_rounded,
                      color: AppColors.primary),
                  label: Text(
                    '+1 Hora',
                    style: GoogleFonts.inter(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: controller.resetSimulation,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              icon: Icon(Icons.refresh_rounded,
                  color:
                      isDark ? AppColors.textMuted : AppColors.textSecondary),
              label: Text(
                'Resetar Simulador',
                style: GoogleFonts.inter(
                    color:
                        isDark ? AppColors.textMuted : AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationLogs(BuildContext context, bool isDark) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Log de Ações da Inteligência',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.logs.length,
                itemBuilder: (context, index) {
                  final log = controller.logs[index];
                  bool isAlert = log.contains('🔴');
                  bool isSuccess = log.contains('🟢');

                  Color textColor = isDark ? Colors.white70 : Colors.black87;
                  if (isAlert) textColor = AppColors.error;
                  if (isSuccess) textColor = AppColors.primary;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      log,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: (isAlert || isSuccess)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationChart(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.show_chart_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Visão Analítica',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildChartLegend(color: Colors.orange, text: 'T. Interna'),
                  _buildChartLegend(
                      color: Colors.blueAccent, text: 'T. Externa'),
                  _buildChartLegend(
                      color: AppColors.primary,
                      text: 'Aeração ON (Bolinhas)',
                      isCircle: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 300,
            child: Obx(() {
              final logs = controller.historyLogs;
              if (logs.isEmpty) {
                return Center(
                  child: Text(
                    'Pressione "Play Automático" ou avence horas para gerar o gráfico histórico.',
                    style: GoogleFonts.inter(
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }

              final intTempSpots = <FlSpot>[];
              final extTempSpots = <FlSpot>[];
              final aerationOnIndexes = <int>[];

              for (int i = 0; i < logs.length; i++) {
                final log = logs[i];
                final double intTemp = log['intTemp'];
                final double extTemp = log['extTemp'];
                final bool isAeration = log['aerationOn'];

                intTempSpots.add(FlSpot(i.toDouble(), intTemp));
                extTempSpots.add(FlSpot(i.toDouble(), extTemp));

                if (isAeration) aerationOnIndexes.add(i);
              }

              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withOpacity(0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}°C',
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i >= 0 && i < logs.length) {
                            if (i % 3 == 0) {
                              // Otimização: não mostrava todos os eixos horizontais pra despoluir
                              final t = logs[i]['time'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                    '${t.toString().padLeft(2, '0')}:00',
                                    style: GoogleFonts.inter(
                                        fontSize: 10, color: Colors.grey)),
                              );
                            }
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (logs.length - 1).toDouble() < 24
                      ? 24.0
                      : (logs.length - 1).toDouble(),
                  minY: 10,
                  maxY: 50,
                  lineBarsData: [
                    // Linha da Temp Interna
                    LineChartBarData(
                      spots: intTempSpots,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) =>
                            aerationOnIndexes.contains(spot.x.toInt()),
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: AppColors
                                .primary, // Verde por cima do laranja pra representar que estava aerando nessa hora
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Linha da Temp Externa
                    LineChartBarData(
                      spots: extTempSpots,
                      isCurved: true,
                      color: Colors.blueAccent.withOpacity(0.5), // Mais suave
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(
      {required Color color, required String text, bool isCircle = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEducationalInfo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded,
                    color: Colors.amber, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Por trás da Inteligência (Cenários Reais)',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Entenda a física e a biologia de grãos aplicadas neste simulador',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildInfoTopic(
            isDark,
            title: '1. Resfriamento Seguro (T.Externa < T.Interna)',
            description:
                'Na vida real, a aeração só é eficiente quando a temperatura do ar injetado está mais fria do que o grão (com uma margem de segurança de ~3°C). Injetar ar quente causa aquecimento da massa e desperdício brutal de energia elétrica.',
            icon: Icons.ac_unit_rounded,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          _buildInfoTopic(
            isDark,
            title: '2. Equilíbrio Higroscópico (Umidade < 75%)',
            description:
                'Grãos são esponjas vivas. Se o sistema ligar durante a chuva (umidade relativa alta), o ar umedecerá os grãos secos. Isso incha os grãos, podendo estourar o silo e iniciar fermentação (perda de padrão de exportação).',
            icon: Icons.water_drop_outlined,
            color: Colors.teal,
          ),
          const SizedBox(height: 24),
          _buildInfoTopic(
            isDark,
            title: '3. Aquecimento Natural (Biologia Ativa)',
            description:
                'Note que, se o sistema ficar desligado, a temperatura do grão começa a subir lentamente. Isso ocorre porque o grão respira (gerando calor) e fungos microbiológicos também realizam termogênese. Daí o perigo dos "Hotspots".',
            icon: Icons.bug_report_outlined,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTopic(bool isDark,
      {required String title,
      required String description,
      required IconData icon,
      required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedExhaustFan extends StatefulWidget {
  final bool isOn;
  final Color color;
  final double size;

  const AnimatedExhaustFan({
    super.key,
    required this.isOn,
    required this.color,
    this.size = 24.0,
  });

  @override
  State<AnimatedExhaustFan> createState() => _AnimatedExhaustFanState();
}

class _AnimatedExhaustFanState extends State<AnimatedExhaustFan>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    if (widget.isOn) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedExhaustFan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOn && !oldWidget.isOn) {
      _controller.repeat();
    } else if (!widget.isOn && oldWidget.isOn) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOn) {
      return Icon(Icons.mode_fan_off_rounded,
          color: widget.color, size: widget.size);
    }
    return RotationTransition(
      turns: _controller,
      child:
          Icon(Icons.cyclone_rounded, color: widget.color, size: widget.size),
    );
  }
}
