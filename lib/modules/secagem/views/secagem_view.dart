import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/secador_model.dart';
import '../../../core/models/telemetry_model.dart';
import '../../../core/models/motor_aeracao_model.dart';
import '../../../core/values/app_colors.dart';
import '../../home/controllers/home_controller.dart';
import '../../devices/widgets/telemetry_history_dialog.dart';
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
            _buildHeader(context, isDesktop),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: SearchBar(
                hintText: 'Buscar secador por nome, tipo, status ou unidade...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant.withOpacity(0.6))),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerLow),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                elevation: WidgetStatePropertyAll(0),
                padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(horizontal: 16)),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                onChanged: controller.filterSecadores,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final list = controller.filteredSecadores;
                if (controller.isLoading.value && list.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (list.isEmpty) {
                  return _buildEmptyState(context, controller.searchQuery.value.isNotEmpty);
                }
                return LayoutBuilder(builder: (context, constraints) {
                  final isWideGrid = constraints.maxWidth > 900;
                  if (isWideGrid) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 0,
                        mainAxisExtent: 560,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final secador = list[index];
                        return Align(
                          alignment: Alignment.topCenter,
                          child: _buildSecadorCard(context, secador),
                        );
                      },
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final secador = list[index];
                      return _buildSecadorCard(context, secador);
                    },
                  );
                });
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSecadorForm(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    final cs = Theme.of(context).colorScheme;
    return Row(
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
              const SizedBox(height: 4),
              Text(
                'Gerencie sua frota de secadores industriais.',
                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        SizedBox(
          child: OutlinedButton.icon(
            onPressed: controller.refreshSecadores,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Sincronizar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              side: BorderSide(color: cs.primary),
              foregroundColor: cs.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecadorCard(BuildContext context, SecadorModel secador) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final statusColor = _statusColor(secador.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildInfoColumn(context, secador, statusColor, isDark),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDryerGraphic(context, secador, statusColor, isDark, true),
                              const SizedBox(height: 16),
                              _buildBatchSideCard(context, secador, isDark),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildInfoColumn(context, secador, statusColor, isDark),
                        const SizedBox(height: 16),
                        _buildDryerGraphic(context, secador, statusColor, isDark, false),
                        const SizedBox(height: 16),
                        _buildBatchSideCard(context, secador, isDark),
                      ],
                    );
              },
            ),
          ),
          if (secador.observacoes != null && secador.observacoes!.isNotEmpty)
            _buildFooter(context, secador, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, SecadorModel secador, Color statusColor, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                secador.nome,
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(secador.status, statusColor),
          ],
        ),
        if (secador.unidadeArmazenadoraNome != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  secador.unidadeArmazenadoraNome!,
                  style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.settings_input_component_rounded, size: 14, color: cs.primary.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                secador.tipo,
                style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.speed_rounded, size: 14, color: cs.primary.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                'Capacidade: ',
                style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              Text(
                '${secador.capacidade} t/h',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.orange.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                secador.fonteCalor,
                style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _buildMiniBadge(context, Icons.sensors_rounded, '${controller.getSecadorSensorCount(secador.id ?? 0)} Sensores', cs.primary),
                const SizedBox(width: 8),
                _buildMiniBadge(context, Icons.air_rounded, '${controller.getSecadorMotorCount(secador.id ?? 0)} Motores', Colors.orange),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        PopupMenuButton(
          icon: Icon(Icons.more_horiz_rounded, color: cs.onSurfaceVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          itemBuilder: (context) => <PopupMenuEntry>[
            PopupMenuItem(
              onTap: () {
                controller.getSensorsBySecador(secador.id!);
                _showSecadorSensors(context, secador);
              },
              child: Row(children: [Icon(Icons.sensors_rounded, size: 20, color: cs.primary), const SizedBox(width: 12), Text('Ver Sensores', style: GoogleFonts.inter(color: cs.onSurface))]),
            ),
            PopupMenuItem(
              onTap: () {
                controller.getMotorsBySecador(secador.id!);
                _showSecadorMotors(context, secador);
              },
              child: Row(children: [Icon(Icons.air_rounded, size: 20, color: Colors.orange), const SizedBox(width: 12), Text('Ver Motores', style: GoogleFonts.inter(color: cs.onSurface))]),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: () => Future.delayed(Duration.zero, () => _showSecadorForm(context, secador: secador)),
              child: Row(children: [Icon(Icons.edit_rounded, size: 20, color: cs.primary), const SizedBox(width: 12), Text('Editar Secador', style: GoogleFonts.inter(color: cs.onSurface))]),
            ),
            PopupMenuItem(
              onTap: () => Get.to(() => SecadorDetalhesView(secador: secador)),
              child: Row(children: [Icon(Icons.assessment_rounded, size: 20, color: cs.primary), const SizedBox(width: 12), Text('Sensores e Telemetria', style: GoogleFonts.inter(color: cs.onSurface))]),
            ),
            if (Get.find<HomeController>().isAdmin)
            PopupMenuItem(
              onTap: () => _confirmDelete(context, secador),
              child: Row(children: [Icon(Icons.delete_outline_rounded, size: 20, color: cs.error), const SizedBox(width: 12), Text('Remover', style: GoogleFonts.inter(color: cs.error))]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDryerGraphic(BuildContext context, SecadorModel secador, Color statusColor, bool isDark, bool isHorizontal) {
    final cs = Theme.of(context).colorScheme;
    final graphicWidth = isHorizontal ? 320.0 : 280.0;
    final graphicHeight = isHorizontal ? 240.0 : 220.0;

    return Obx(() {
      final readings = controller.getLatestReadings(secador.id ?? 0);
      final motors = controller.getMotorsForSecador(secador.id ?? 0);

      return Center(
        child: SizedBox(
          width: graphicWidth,
          height: graphicHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: (graphicWidth - 140) / 2,
                child: CustomPaint(
                  size: const Size(140, 200),
                  painter: DryerPainter(
                    statusColor: statusColor,
                    isDark: isDark,
                  ),
                ),
              ),
              // Sensores (callouts à direita)
              if (readings.isNotEmpty)
                ...List.generate(readings.length, (index) {
                  final r = readings[index];
                  final double topOffset = (graphicHeight * 0.2) + (index * 55.0);
                  return Positioned(
                    left: (graphicWidth / 2) + 10,
                    top: topOffset,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 1,
                          color: cs.primary.withOpacity(0.3),
                        ),
                        const SizedBox(width: 6),
                        _buildSensorLabel(r, isDark),
                      ],
                    ),
                  );
                }),
              if (readings.isEmpty)
                Positioned(
                  right: 20,
                  top: graphicHeight * 0.4,
                  child: Text(
                    'Sem sensores',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.withOpacity(0.5), fontStyle: FontStyle.italic),
                  ),
                ),
              // Motores (na parte inferior)
              if (motors.isNotEmpty)
                Positioned(
                  left: (graphicWidth - (motors.length * 150.0).clamp(100, 300)) / 2,
                  bottom: -5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: motors.map((m) {
                      final isLigado = m.estado == 'ligado';
                      return Padding(
                        padding: EdgeInsets.only(right: motors.indexOf(m) < motors.length - 1 ? 12 : 0),
                        child: _buildMotorLabel(m, isLigado, isDark),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSensorLabel(TelemetryModel reading, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reading.sensorPhysicalId.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 0.3),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.thermostat_rounded, size: 9, color: Colors.orange),
              const SizedBox(width: 2),
              Text('${reading.temperature}°C', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(width: 6),
              Icon(Icons.water_drop_rounded, size: 9, color: Colors.blue),
              const SizedBox(width: 2),
              Text('${reading.humidity}%', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotorLabel(MotorAeracaoModel motor, bool isLigado, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLigado ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isLigado ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.air_rounded, size: 10, color: isLigado ? Colors.green : Colors.grey),
          ),
          const SizedBox(width: 4),
          Text(
            motor.motorId,
            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.orange, letterSpacing: 0.2),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: isLigado ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              isLigado ? 'LIGADO' : 'DESLIGADO',
              style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w900, color: isLigado ? Colors.green : Colors.grey, letterSpacing: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchSideCard(BuildContext context, SecadorModel secador, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FONTE DE CALOR',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  secador.fonteCalor,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${secador.capacidade} t/h',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, SecadorModel secador, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.015),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 14, color: cs.primary.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                'OBSERVAÇÕES TÉCNICAS',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: cs.primary.withOpacity(0.6), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            secador.observacoes!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Disponível': return Colors.green;
      case 'Em Uso': return Colors.blue;
      case 'Em Manutenção': return Colors.orange;
      case 'Desativado': return Colors.grey;
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

  void _showSecadorSensors(BuildContext context, SecadorModel secador) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
          ),
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
                        Text('Sensores do Secador', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
                        Text(secador.nome, style: GoogleFonts.inter(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: Obx(() {
                  if (controller.isLoadingSecadorSensors.value) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }
                  if (controller.secadorSensors.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.sensors_off_rounded, size: 48, color: Colors.grey.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text('Nenhum sensor vinculado a este secador.', style: GoogleFonts.inter(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.secadorSensors.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sensor = controller.secadorSensors[index];
                      final sensorStatusColor = sensor.status.toLowerCase() == 'ativo' ? Colors.green : Colors.orange;
                      return InkWell(
                        onTap: () { Get.back(); TelemetryHistoryDialog.show(context, sensor); },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.settings_input_antenna_rounded, color: cs.primary, size: 18),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sensor.description, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                                    Text('ID: ${sensor.sensorId}', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: sensorStatusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text(sensor.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: sensorStatusColor)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Fechar', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecadorMotors(BuildContext context, SecadorModel secador) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
          ),
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
                        Text('Motores do Secador', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
                        Text(secador.nome, style: GoogleFonts.inter(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: Obx(() {
                  if (controller.isLoadingMotors.value) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }
                  if (controller.secadorMotors.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.electrical_services_rounded, size: 48, color: Colors.grey.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text('Nenhum motor vinculado a este secador.', style: GoogleFonts.inter(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.secadorMotors.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final motor = controller.secadorMotors[index];
                      final isLigado = motor.estado == 'ligado';
                      Color motorStatusColor;
                      switch (motor.status) {
                        case 'ativo': motorStatusColor = isLigado ? Colors.green : Colors.orange; break;
                        case 'manutencao': motorStatusColor = Colors.orange; break;
                        case 'falha': motorStatusColor = Colors.red; break;
                        default: motorStatusColor = Colors.grey;
                      }
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.air_rounded, color: Colors.orange.shade700, size: 18),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(motor.motorId, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                                  if (motor.description.isNotEmpty)
                                    Text(motor.description, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(isLigado ? 'LIGADO' : 'DESLIGADO', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isLigado ? Colors.green : Colors.grey)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: motorStatusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(motor.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: motorStatusColor)),
                                ),
                                if (motor.potenciaKW != null) ...[
                                  const SizedBox(height: 4),
                                  Text('${motor.potenciaKW!.toStringAsFixed(1)} kW', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Fechar', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecadorForm(BuildContext context, {SecadorModel? secador}) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = secador != null;
    final nameCtl = TextEditingController(text: secador?.nome);
    final capacityCtl = TextEditingController(text: secador?.capacidade.toString());
    final obsCtl = TextEditingController(text: secador?.observacoes);

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

  void _confirmDelete(BuildContext context, SecadorModel secador) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
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
}

class DryerPainter extends CustomPainter {
  final Color statusColor;
  final bool isDark;

  DryerPainter({required this.statusColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final width = size.width;
    final height = size.height;

    // Dimensões do secador
    final bodyLeft = width * 0.15;
    final bodyTop = height * 0.15;
    final bodyWidth = width * 0.7;
    final bodyHeight = height * 0.6;

    // 1. Corpo principal (cilindro vertical)
    final bodyRect = Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight);
    final bodyGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDark
          ? [Colors.grey[850]!, Colors.grey[700]!, Colors.grey[900]!]
          : [Colors.grey[400]!, Colors.grey[100]!, Colors.grey[500]!],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(bodyRect);
    paint.shader = bodyGradient;
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), paint);

    // 2. Topo (câmara de aquecimento - tons mais escuros)
    final topRect = Rect.fromLTWH(bodyLeft - 5, bodyTop - 15, bodyWidth + 10, 20);
    final topGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDark
          ? [Colors.grey[800]!, Colors.grey[600]!, Colors.grey[800]!]
          : [Colors.grey[500]!, Colors.grey[300]!, Colors.grey[500]!],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(topRect);
    paint.shader = topGradient;
    canvas.drawRRect(RRect.fromRectAndRadius(topRect, const Radius.circular(6)), paint);

    // 3. Saída de ar (chamine no topo)
    final chamineLeft = bodyLeft + bodyWidth / 2 - 8;
    final chamineRect = Rect.fromLTWH(chamineLeft, bodyTop - 35, 16, 22);
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark ? [Colors.grey[700]!, Colors.grey[800]!] : [Colors.grey[400]!, Colors.grey[500]!],
    ).createShader(chamineRect);
    canvas.drawRRect(RRect.fromRectAndRadius(chamineRect, const Radius.circular(3)), paint);

    // 4. Fogo/calor na base (efeito de chama)
    final firePath = Path();
    final fireBaseY = bodyTop + bodyHeight;
    firePath.moveTo(bodyLeft + 10, fireBaseY);
    firePath.lineTo(bodyLeft + bodyWidth / 2 - 10, fireBaseY + 25);
    firePath.lineTo(bodyLeft + bodyWidth / 2, fireBaseY + 15);
    firePath.lineTo(bodyLeft + bodyWidth / 2 + 10, fireBaseY + 25);
    firePath.lineTo(bodyLeft + bodyWidth - 10, fireBaseY);
    firePath.close();

    final firePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [statusColor.withOpacity(0.6), statusColor.withOpacity(0.2)],
      ).createShader(Rect.fromLTWH(bodyLeft, fireBaseY, bodyWidth, 25));
    canvas.drawPath(firePath, firePaint);

    // 5. Nervuras do secador
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;
    paint.color = isDark ? Colors.black26 : Colors.black.withOpacity(0.05);
    for (int i = 1; i < 6; i++) {
      final y = bodyTop + (bodyHeight * i / 6);
      canvas.drawLine(Offset(bodyLeft, y), Offset(bodyLeft + bodyWidth, y), paint);
    }

    // 6. Porta de inspeção
    final doorRect = Rect.fromLTWH(
      bodyLeft + bodyWidth / 2 - 12,
      bodyTop + bodyHeight / 2 - 12,
      24, 24,
    );
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    paint.color = isDark ? Colors.white24 : Colors.black.withOpacity(0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(doorRect, const Radius.circular(4)), paint);
    canvas.drawCircle(
      Offset(bodyLeft + bodyWidth / 2, bodyTop + bodyHeight / 2),
      2,
      paint,
    );

    // 7. Tubulação lateral (entrada de ar)
    final tuboLeft = bodyLeft + bodyWidth + 3;
    final tuboRect = Rect.fromLTWH(tuboLeft, bodyTop + bodyHeight * 0.3, 8, bodyHeight * 0.4);
    paint.style = PaintingStyle.fill;
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark ? [Colors.grey[700]!, Colors.grey[800]!] : [Colors.grey[300]!, Colors.grey[400]!],
    ).createShader(tuboRect);
    canvas.drawRRect(RRect.fromRectAndRadius(tuboRect, const Radius.circular(3)), paint);

    // 8. Reflexo de vidro
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(isDark ? 0.05 : 0.15),
        Colors.transparent,
        Colors.white.withOpacity(isDark ? 0.02 : 0.08),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(bodyRect);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), paint);
  }

  @override
  bool shouldRepaint(covariant DryerPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}