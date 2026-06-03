import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/secador_model.dart';
import '../../../core/models/sensor_model.dart';
import '../../../core/models/telemetry_model.dart';
import '../controllers/secagem_controller.dart';

class SecadorDetalhesView extends StatefulWidget {
  final SecadorModel secador;
  const SecadorDetalhesView({super.key, required this.secador});

  @override
  State<SecadorDetalhesView> createState() => _SecadorDetalhesViewState();
}

class _SecadorDetalhesViewState extends State<SecadorDetalhesView> {
  final controller = Get.find<SecagemController>();
  final sensors = <SensorModel>[].obs;
  final telemetriaMap = <int, List<TelemetryModel>>{}.obs;
  final isLoadingSensors = true.obs;
  final isLoadingTelemetry = false.obs;
  final selectedDate = DateTime.now().obs;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadTelemetry() async {
    isLoadingTelemetry.value = true;
    telemetriaMap.clear();
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    for (final s in sensors.where((s) => s.id != null)) {
      final t = await controller.getTelemetria(s.id!, data: dateStr);
      telemetriaMap[s.id!] = t;
    }
    isLoadingTelemetry.value = false;
  }

  Future<void> loadData() async {
    isLoadingSensors.value = true;
    final list = await controller.getSensores(widget.secador.id!);
    sensors.assignAll(list);
    isLoadingSensors.value = false;
    loadTelemetry();
  }

  List<TelemetryModel> get _allTelemetry {
    final all = <TelemetryModel>[];
    for (final list in telemetriaMap.values) {
      all.addAll(list);
    }
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  List<FlSpot> get _tempSpots {
    final all = _allTelemetry;
    if (all.isEmpty) return [];
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final start = all.first.timestamp;
    return all.asMap().entries.map((e) {
      final minutes = e.value.timestamp.difference(start).inMinutes.toDouble();
      return FlSpot(minutes, e.value.temperature);
    }).toList();
  }

  List<FlSpot> get _humSpots {
    final all = _allTelemetry;
    if (all.isEmpty) return [];
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final start = all.first.timestamp;
    return all.asMap().entries.map((e) {
      final minutes = e.value.timestamp.difference(start).inMinutes.toDouble();
      return FlSpot(minutes, e.value.humidity);
    }).toList();
  }

  List<String> get _chartLabels {
    final all = _allTelemetry;
    if (all.isEmpty) return [];
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final tf = DateFormat('HH:mm');
    return all.map((t) => tf.format(t.timestamp.toLocal())).toList();
  }

  double get _avgTemp {
    final all = _allTelemetry;
    if (all.isEmpty) return 0;
    return all.map((t) => t.temperature).reduce((a, b) => a + b) / all.length;
  }

  double get _maxTemp {
    final all = _allTelemetry;
    if (all.isEmpty) return 0;
    return all.map((t) => t.temperature).reduce((a, b) => a > b ? a : b);
  }

  double get _minTemp {
    final all = _allTelemetry;
    if (all.isEmpty) return 0;
    return all.map((t) => t.temperature).reduce((a, b) => a < b ? a : b);
  }

  double get _avgHum {
    final all = _allTelemetry;
    if (all.isEmpty) return 0;
    return all.map((t) => t.humidity).reduce((a, b) => a + b) / all.length;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.secador.nome, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
            Text('${widget.secador.tipo} • ${widget.secador.capacidade} t/h', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
          ],
        ),
        actions: [
          Obx(() => TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate.value,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                selectedDate.value = picked;
                loadTelemetry();
              }
            },
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: Text(DateFormat('dd/MM/yyyy').format(selectedDate.value)),
            style: TextButton.styleFrom(foregroundColor: cs.primary),
          )),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadData,
            tooltip: 'Atualizar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (isLoadingSensors.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final allTelemetry = _allTelemetry;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildLeftPanel(cs, allTelemetry)),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: _buildRightPanel(cs)),
                  ],
                )
              : Column(
                  children: [
                    _buildOverviewCards(cs, allTelemetry),
                    const SizedBox(height: 24),
                    _buildChart(cs),
                    const SizedBox(height: 24),
                    _buildSensorList(cs),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildLeftPanel(ColorScheme cs, List<TelemetryModel> allTelemetry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverviewCards(cs, allTelemetry),
        const SizedBox(height: 24),
        _buildChart(cs),
      ],
    );
  }

  Widget _buildRightPanel(ColorScheme cs) {
    return _buildSensorList(cs);
  }

  Widget _buildOverviewCards(ColorScheme cs, List<TelemetryModel> allTelemetry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VISÃO GERAL'.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: cs.primary)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _overviewCard(cs, Icons.thermostat_rounded, 'Temperatura Média', '${_avgTemp.toStringAsFixed(1)}°C', 'Mín ${_minTemp.toStringAsFixed(1)}°C • Máx ${_maxTemp.toStringAsFixed(1)}°C', Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard(cs, Icons.water_drop_rounded, 'Umidade Média', '${_avgHum.toStringAsFixed(1)}%', '${allTelemetry.length} leituras', Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard(cs, Icons.sensors_rounded, 'Sensores Ativos', '${sensors.length}', '${sensors.where((s) => s.status == 'ativo').length} operacionais', Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _overviewCard(ColorScheme cs, IconData icon, String label, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildChart(ColorScheme cs) {
    final all = _allTelemetry;
    if (all.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.show_chart_rounded, size: 48, color: cs.onSurfaceVariant.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text('Nenhum dado para ${DateFormat('dd/MM/yyyy').format(selectedDate.value)}', style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    final tempSpots = _tempSpots;
    final humSpots = _humSpots;
    final labels = _chartLabels;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text('Temperatura (°C)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange)),
              const SizedBox(width: 20),
              _legendDash(cs, Colors.blue, 'Umidade (%)'),
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
                  getDrawingHorizontalLine: (value) => FlLine(color: cs.outlineVariant.withOpacity(0.3), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 42, getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: GoogleFonts.inter(fontSize: 10, color: Colors.blue.withOpacity(0.7)))),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (labels.length / 6).clamp(1, 100).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[index], style: GoogleFonts.inter(fontSize: 9, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 42, getTitlesWidget: (value, meta) => Text('${value.toInt()}°', style: GoogleFonts.inter(fontSize: 10, color: Colors.orange.withOpacity(0.8)))),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: tempSpots,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: Colors.orange)),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.12), Colors.orange.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  ),
                  LineChartBarData(
                    spots: humSpots,
                    isCurved: true,
                    color: Colors.blue.withOpacity(0.85),
                    barWidth: 2.5,
                    dashArray: [6, 4],
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3, color: Colors.white, strokeWidth: 1.5, strokeColor: Colors.blue)),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.07), Colors.blue.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => cs.surface,
                    tooltipBorder: BorderSide(color: cs.outlineVariant),
                    tooltipPadding: const EdgeInsets.all(12),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isTemp = spot.barIndex == 0;
                        final index = spot.x.toInt();
                        final label = (index >= 0 && index < labels.length) ? labels[index] : '';
                        return LineTooltipItem(
                          isTemp ? 'TEMPERATURA' : 'UMIDADE',
                          GoogleFonts.inter(color: isTemp ? Colors.orange : Colors.blue, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5),
                          children: [
                            const TextSpan(text: '\n'),
                            TextSpan(text: '${spot.y.toStringAsFixed(1)}${isTemp ? '°C' : '%'}', style: GoogleFonts.outfit(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
                            const TextSpan(text: '\n'),
                            TextSpan(text: label, style: GoogleFonts.inter(color: cs.onSurfaceVariant, fontWeight: FontWeight.normal, fontSize: 10)),
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
  }

  Widget _legendDash(ColorScheme cs, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(3, (i) => Container(width: 5, height: 2, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)))),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _buildSensorList(ColorScheme cs) {
    if (sensors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.sensors_off_rounded, size: 48, color: cs.onSurfaceVariant.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Nenhum sensor vinculado', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SENSORES'.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: cs.primary)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sensors.length,
          itemBuilder: (_, i) => _sensorTile(cs, sensors[i]),
        ),
      ],
    );
  }

  Widget _sensorTile(ColorScheme cs, SensorModel sensor) {
    final statusColor = sensor.status == 'ativo' ? Colors.green : (sensor.status == 'manutencao' ? Colors.orange : Colors.red);
    final telemetrias = telemetriaMap[sensor.id] ?? [];
    final latestTemp = telemetrias.isNotEmpty ? telemetrias.first.temperature : null;
    final latestHum = telemetrias.isNotEmpty ? telemetrias.first.humidity : null;

    return _SensorCard(
      key: ValueKey(sensor.sensorId),
      cs: cs,
      sensor: sensor,
      statusColor: statusColor,
      telemetrias: telemetrias,
      latestTemp: latestTemp,
      latestHum: latestHum,
    );
  }
}

class _SensorCard extends StatefulWidget {
  final ColorScheme cs;
  final SensorModel sensor;
  final Color statusColor;
  final List<TelemetryModel> telemetrias;
  final double? latestTemp;
  final double? latestHum;

  const _SensorCard({
    super.key,
    required this.cs,
    required this.sensor,
    required this.statusColor,
    required this.telemetrias,
    required this.latestTemp,
    required this.latestHum,
  });

  @override
  State<_SensorCard> createState() => _SensorCardState();
}

class _SensorCardState extends State<_SensorCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final sensor = widget.sensor;
    final statusColor = widget.statusColor;
    final telemetrias = widget.telemetrias;
    final latestTemp = widget.latestTemp;
    final latestHum = widget.latestHum;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.sensors_rounded, size: 18, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sensor.sensorId, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(sensor.description.isNotEmpty ? sensor.description : sensor.tipo, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                              child: Text(sensor.status, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (latestTemp != null)
                    Text('${latestTemp.toStringAsFixed(1)}°C', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded, size: 20, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildContent(cs, telemetrias, latestTemp, latestHum),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme cs, List<TelemetryModel> telemetrias, double? latestTemp, double? latestHum) {
    if (telemetrias.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: cs.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(width: 6),
          Text('Nenhum dado para esta data.', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant.withOpacity(0.6))),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            _miniStat(cs, Icons.thermostat_rounded, 'Temperatura', '${latestTemp!.toStringAsFixed(1)}°C', Colors.orange),
            const SizedBox(width: 12),
            _miniStat(cs, Icons.water_drop_rounded, 'Umidade', '${latestHum!.toStringAsFixed(1)}%', Colors.blue),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: telemetrias.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, j) {
              final t = telemetrias[j];
              final time = DateFormat('HH:mm').format(t.timestamp.toLocal());
              return Container(
                width: 68,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(time, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${t.temperature.toStringAsFixed(1)}°', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.orange)),
                    Text('${t.humidity.toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 11, color: Colors.blue)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
}

  Widget _miniStat(ColorScheme cs, IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant)),
                Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
