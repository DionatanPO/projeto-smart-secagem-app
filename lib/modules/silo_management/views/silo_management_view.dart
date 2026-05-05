import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/silo_model.dart';
import '../../../core/models/telemetry_model.dart';
import '../../devices/widgets/telemetry_history_dialog.dart';
import '../controllers/silo_management_controller.dart';

class SiloManagementView extends GetView<SiloManagementController> {
  const SiloManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SiloManagementController>()) {
      Get.put(SiloManagementController());
    }

    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
  
                if (controller.silos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warehouse_outlined,
                            size: 64, color: theme.hintColor),
                        const SizedBox(height: 16),
                        Text('Nenhum silo cadastrado',
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                  );
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
                        mainAxisExtent: 600, // Altura segura para acomodar quebras de linha em textos de lote
                      ),
                      itemCount: controller.silos.length,
                      itemBuilder: (context, index) {
                        final silo = controller.silos[index];
                        return Align(
                          alignment: Alignment.topCenter,
                          child: _buildSiloCard(context, silo, index),
                        );
                      },
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
                    itemCount: controller.silos.length,
                    itemBuilder: (context, index) {
                      final silo = controller.silos[index];
                      return _buildSiloCard(context, silo, index);
                    },
                  );
                });
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSiloForm(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Novo Silo',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isMobile = width < 600;

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 600 : (width - (isMobile ? 48 : 80))),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Gestão de Silos',
                          style: (isDesktop
                                  ? theme.textTheme.headlineSmall
                                  : theme.textTheme.titleLarge)
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitoramento em tempo real dos seus silos.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                          fontSize: isMobile ? 12 : 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: isMobile ? double.infinity : null,
            child: OutlinedButton.icon(
              onPressed: controller.refreshSilos,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Sincronizar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: BorderSide(color: theme.primaryColor),
                foregroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiloCard(BuildContext context, SiloModel silo, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(silo.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          // 1. Header Integrado com Nome, Status e Ações
          _buildSiloHeader(context, silo, statusColor, isDark, index),
          
          // 2. Conteúdo Principal (Gráfico + Métricas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400; // Threshold reduzido para manter Row em 2 colunas grid
                return isWide 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gráfico do Silo com Telemetria Integrada
                        Expanded(
                          flex: 3,
                          child: _buildSiloGraphic(context, silo, statusColor, isDark, true),
                        ),
                        // Card Lateral de Lote
                        Expanded(
                          flex: 2,
                          child: _buildBatchSideCard(context, silo, isDark),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildSiloGraphic(context, silo, statusColor, isDark, false),
                        _buildBatchSideCard(context, silo, isDark),
                      ],
                    );
              },
            ),
          ),
          
          // 3. Rodapé de Notas (Subtil e Integrado)
          if (silo.observations != null && silo.observations!.isNotEmpty)
            _buildSiloFooter(context, silo, isDark),
        ],
      ),
    );
  }

  Widget _buildSiloHeader(BuildContext context, SiloModel silo, Color statusColor, bool isDark, int index) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      silo.name,
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(silo.status, statusColor),
                  ],
                ),
                if (silo.farmName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: theme.hintColor),
                        const SizedBox(width: 4),
                        Text(
                          silo.farmName!,
                          style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                // Capacidade abaixo da Fazenda
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(Icons.warehouse_outlined, size: 14, color: AppColors.primary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'Carga: ',
                        style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor),
                      ),
                      Text(
                        '${silo.currentQuantity}t / ${silo.capacity}t',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                onTap: () {
                  controller.getSensorsBySilo(silo.id!);
                  _showSiloSensors(context, silo);
                },
                child: const Row(children: [Icon(Icons.sensors_rounded, size: 20, color: AppColors.primary), SizedBox(width: 12), Text('Ver Sensores')]),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () => Future.delayed(Duration.zero, () => _showSiloForm(context, silo: silo)),
                child: const Row(children: [Icon(Icons.edit_rounded, size: 20), SizedBox(width: 12), Text('Editar Silo')]),
              ),
              PopupMenuItem(
                onTap: () => controller.deleteSilo(silo.id!),
                child: const Row(children: [Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red), SizedBox(width: 12), Text('Remover', style: TextStyle(color: Colors.red))]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSiloGraphic(BuildContext context, SiloModel silo, Color statusColor, bool isDark, bool isHorizontal) {
    final theme = Theme.of(context);
    final graphicWidth = isHorizontal ? 320.0 : 280.0;
    final graphicHeight = isHorizontal ? 240.0 : 220.0;
    final siloWidth = graphicWidth * (isHorizontal ? 0.4 : 0.4);

    return Obx(() {
      final readings = controller.getLatestReadings(silo.id ?? 0);
      
      return Center(
        child: SizedBox(
          width: graphicWidth,
          height: graphicHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // O Silo (CustomPaint)
              Positioned(
                left: 20,
                child: CustomPaint(
                  size: Size(siloWidth, graphicHeight),
                  painter: SiloPainter(
                    percentage: silo.percentage,
                    statusColor: statusColor,
                    isDark: isDark,
                  ),
                ),
              ),

              // Porcentagem de Nível (Sobre o Silo)
              Positioned(
                left: 20 + (siloWidth * 0.15),
                bottom: graphicHeight * 0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${silo.percentage.toInt()}%',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),

              // Sensores Integrados (Callouts)
              if (readings.isNotEmpty)
                ...List.generate(readings.length, (index) {
                  final r = readings[index];
                  // Distribuir sensores verticalmente ao longo do corpo do silo
                  final double topOffset = (graphicHeight * 0.3) + (index * 60.0);
                  
                  return Positioned(
                    left: 20 + (siloWidth * 0.75), // Começa na borda direita do silo
                    top: topOffset,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Linha de Conexão
                        Container(
                          width: 15,
                          height: 1,
                          color: theme.primaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(width: 8),
                        // Label do Sensor
                        _buildIntegratedSensorLabel(r, isDark),
                      ],
                    ),
                  );
                }),
              
              if (readings.isEmpty)
                Positioned(
                  right: 40,
                  top: graphicHeight * 0.4,
                  child: Text(
                    'Sem sensores\nativos',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.withOpacity(0.5), fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIntegratedSensorLabel(TelemetryModel reading, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reading.sensorPhysicalId.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildMiniSensorBadge(Icons.thermostat_rounded, '${reading.temperature}°C', Colors.orange),
            const SizedBox(width: 8),
            _buildMiniSensorBadge(Icons.water_drop_rounded, '${reading.humidity}%', Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniSensorBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildBatchDetailItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.orange.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.orange.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildSiloFooter(BuildContext context, SiloModel silo, bool isDark) {
    // ... mantido ...
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
              Icon(Icons.assignment_outlined, size: 14, color: Theme.of(context).primaryColor.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                'NOTAS E DIAGNÓSTICOS',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.6), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            silo.observations!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchSideCard(BuildContext context, SiloModel silo, bool isDark) {
    return Obx(() {
      final batch = controller.getBatchBySilo(silo.id ?? 0);
      if (batch == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'LOTE ATIVO',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              batch.numeroLote,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 4),
            Text(
              batch.cultura,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
            ),
            if (batch.variedade != null)
              Text(
                batch.variedade!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            const SizedBox(height: 12),
            const Divider(color: Colors.orange, height: 1, thickness: 0.1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event_available_rounded, size: 14, color: Colors.orange.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  'Safra ${batch.safra}',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSiloMetricsGrid(BuildContext context, SiloModel silo, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMetricTile('Quantidade Atual', '${silo.currentQuantity} t', Icons.inventory_2_outlined, isDark),
        const SizedBox(height: 16),
        _buildMetricTile('Capacidade Total', '${silo.capacity} t', Icons.warehouse_outlined, isDark),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSensorMiniStat(TelemetryModel reading, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.developer_board_rounded, size: 12, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text(
              reading.sensorPhysicalId.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10, 
                fontWeight: FontWeight.w900, 
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniCircleIcon(Icons.thermostat_rounded, Colors.orange),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${reading.temperature}°C', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Temperatura', style: GoogleFonts.inter(fontSize: 9, color: Colors.grey)),
              ],
            ),
            const SizedBox(width: 16),
            _buildMiniCircleIcon(Icons.water_drop_rounded, Colors.blue),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${reading.humidity}%', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Umidade', style: GoogleFonts.inter(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCircleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, size: 12, color: color),
    );
  }


  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(_getStatusText(status).toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disponivel':
        return Colors.green;
      case 'em_uso':
        return AppColors.primary;
      case 'manutencao':
        return Colors.orange;
      case 'desativado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'disponivel':
        return 'Disponível';
      case 'em_uso':
        return 'Em Uso';
      case 'manutencao':
        return 'Manutenção';
      case 'desativado':
        return 'Inativo';
      default:
        return status;
    }
  }

  void _showSiloSensors(BuildContext context, SiloModel silo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
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
                        Text(
                          'Sensores do Silo',
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          silo.name,
                          style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: Obx(() {
                  if (controller.isLoadingSensors.value) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  if (controller.siloSensors.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.sensors_off_rounded, size: 48, color: Colors.grey.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum sensor vinculado a este silo.',
                              style: GoogleFonts.inter(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.siloSensors.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sensor = controller.siloSensors[index];
                      final sensorStatusColor = sensor.status.toLowerCase() == 'ativo' ? Colors.green : Colors.orange;
                      
                      return InkWell(
                        onTap: () {
                          Get.back(); // Fecha o modal de lista de sensores
                          TelemetryHistoryDialog.show(context, sensor);
                        },
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
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.settings_input_antenna_rounded, color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sensor.description,
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      'ID: ${sensor.sensorId}',
                                      style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: sensorStatusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  sensor.status.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: sensorStatusColor,
                                  ),
                                ),
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

  void _showSiloForm(BuildContext context, {SiloModel? silo}) {
    final isEditing = silo != null;
    final nameController = TextEditingController(text: silo?.name ?? '');
    final capacityController = TextEditingController(text: silo?.capacity.toString() ?? '');
    final quantityController = TextEditingController(text: silo?.currentQuantity.toString() ?? '');
    final observationsController = TextEditingController(text: silo?.observations ?? '');
    
    // Garantir que o status inicial seja válido para não quebrar o Dropdown
    final validStatuses = ['disponivel', 'em_uso', 'manutencao', 'desativado'];
    final currentStatus = silo?.status ?? 'disponivel';
    final status = (validStatuses.contains(currentStatus) ? currentStatus : 'disponivel').obs;
    
    final selectedFarmId = (silo?.farmId).obs;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.all(24),
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
                            isEditing ? 'Editar Silo' : 'Novo Silo',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isEditing ? 'Atualize as informações do silo.' : 'Configure um novo silo para monitoramento.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                _buildFieldLabel('FAZENDA / LOCALIZAÇÃO'),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<int?>(
                      value: selectedFarmId.value,
                      style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                      dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Nenhuma (Unidade Independente)')),
                        ...controller.availableFarms.map((f) => DropdownMenuItem(
                              value: f.id,
                              child: Text(f.name),
                            )),
                      ],
                      onChanged: (v) => selectedFarmId.value = v,
                      decoration: _buildInputDecoration('Selecione onde este silo está...', Icons.location_on_rounded, isDark),
                    )),
                const SizedBox(height: 24),
                _buildFieldLabel('NOME DO SILO'),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: _buildInputDecoration('Ex: Silo Sul 01', Icons.warehouse_rounded, isDark),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 350;
                    return Flex(
                      direction: isSmall ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(
                          flex: isSmall ? 0 : 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('CAPACIDADE (T)'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: capacityController,
                                style: GoogleFonts.inter(fontSize: 14),
                                keyboardType: TextInputType.number,
                                decoration: _buildInputDecoration('0.0', Icons.scale_rounded, isDark),
                              ),
                            ],
                          ),
                        ),
                        if (!isSmall) const SizedBox(width: 16) else const SizedBox(height: 24),
                        Expanded(
                          flex: isSmall ? 0 : 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('QTD ATUAL (T)'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: quantityController,
                                style: GoogleFonts.inter(fontSize: 14),
                                keyboardType: TextInputType.number,
                                decoration: _buildInputDecoration('0.0', Icons.inventory_2_rounded, isDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 24),
                _buildFieldLabel('STATUS OPERACIONAL'),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                      value: status.value,
                      style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                      dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                      items: const [
                        DropdownMenuItem(value: 'disponivel', child: Text('Disponível')),
                        DropdownMenuItem(value: 'em_uso', child: Text('Em Uso')),
                        DropdownMenuItem(value: 'manutencao', child: Text('Manutenção')),
                        DropdownMenuItem(value: 'desativado', child: Text('Desativado')),
                      ],
                      onChanged: (v) => status.value = v!,
                      decoration: _buildInputDecoration('', Icons.info_outline_rounded, isDark),
                    )),
                const SizedBox(height: 24),
                _buildFieldLabel('NOTAS E DIAGNÓSTICOS'),
                const SizedBox(height: 8),
                TextField(
                  controller: observationsController,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: _buildInputDecoration('Detalhes do lote, datas de carga, notas técnicas...', Icons.notes_rounded, isDark),
                ),
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
                          final newSilo = SiloModel(
                            id: silo?.id,
                            farmId: selectedFarmId.value,
                            name: nameController.text,
                            capacity: double.tryParse(capacityController.text) ?? 0.0,
                            currentQuantity: double.tryParse(quantityController.text) ?? 0.0,
                            status: status.value,
                            observations: observationsController.text,
                          );
                          if (isEditing) {
                            controller.updateSilo(newSilo);
                          } else {
                            controller.createSilo(newSilo);
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
                          isEditing ? 'Atualizar Silo' : 'Cadastrar Silo',
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

  void _confirmDelete(BuildContext context, SiloModel silo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
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
                'Excluir Silo',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Deseja realmente remover o silo ${silo.name}? Esta ação não poderá ser desfeita e removerá todos os vínculos.',
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
                        controller.deleteSilo(silo.id!);
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

  Widget _buildSensorBadge(BuildContext context, int siloId) {
    final count = controller.getSiloSensorCount(siloId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sensors_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '$count Sensores',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeIndicator(BuildContext context, IconData icon, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorReadingRow(BuildContext context, TelemetryModel telemetry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasData = telemetry.temperature != 0.0 || telemetry.humidity != 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: hasData ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sensors_rounded, size: 12, color: hasData ? AppColors.primary : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    telemetry.sensorPhysicalId,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.thermostat_auto_rounded, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${telemetry.temperature.toStringAsFixed(1)}°C',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.water_drop_rounded, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    '${telemetry.humidity.toStringAsFixed(1)}%',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          if (hasData) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Lido em: ${DateFormat('dd/MM/yyyy HH:mm').format(telemetry.timestamp)}',
                style: GoogleFonts.inter(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Aguardando primeira leitura...',
                style: GoogleFonts.inter(fontSize: 9, color: Colors.orange.withOpacity(0.6), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SiloPainter extends CustomPainter {
  final double percentage;
  final Color statusColor;
  final bool isDark;

  SiloPainter({
    required this.percentage,
    required this.statusColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final width = size.width;
    final height = size.height;

    // Margens para a escala lateral
    final siloWidth = width * 0.7;
    final siloLeft = width * 0.1;
    final siloTop = height * 0.25;
    final siloHeight = height * 0.7;

    // 1. Desenhar o corpo do Silo (Cilindro metálico com 3D)
    final siloRect = Rect.fromLTWH(siloLeft, siloTop, siloWidth, siloHeight);
    
    // Gradiente metálico principal
    final bodyGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDark 
        ? [Colors.grey[850]!, Colors.grey[700]!, Colors.grey[900]!] 
        : [Colors.grey[400]!, Colors.grey[100]!, Colors.grey[500]!],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(siloRect);
    
    paint.shader = bodyGradient;
    canvas.drawRRect(RRect.fromRectAndRadius(siloRect, const Radius.circular(4)), paint);

    // 2. Desenhar o topo (Cone metálico)
    final roofPath = Path();
    roofPath.moveTo(siloLeft - 2, siloTop + 2);
    roofPath.lineTo(siloLeft + siloWidth / 2, height * 0.1);
    roofPath.lineTo(siloLeft + siloWidth + 2, siloTop + 2);
    roofPath.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark ? [Colors.grey[700]!, Colors.grey[800]!] : [Colors.grey[300]!, Colors.grey[400]!],
    ).createShader(Rect.fromLTWH(0, height * 0.1, width, siloTop));
    canvas.drawPath(roofPath, paint);

    // 3. Preenchimento (Grãos)
    if (percentage > 0) {
      final fillHeight = (siloHeight - 6) * (percentage / 100).clamp(0.05, 1.0);
      final fillRect = Rect.fromLTWH(
        siloLeft + 3, 
        siloTop + siloHeight - fillHeight - 3, 
        siloWidth - 6, 
        fillHeight
      );
      
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [statusColor.withOpacity(0.8), statusColor],
        ).createShader(fillRect);
      
      canvas.drawRRect(RRect.fromRectAndRadius(fillRect, const Radius.circular(2)), fillPaint);
      
      // Reflexo interno no grão (Efeito 3D)
      final grainGloss = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.2), 
            Colors.transparent, 
            Colors.black.withOpacity(0.1)
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(fillRect);
      canvas.drawRRect(RRect.fromRectAndRadius(fillRect, const Radius.circular(2)), grainGloss);
    }

    // 4. Detalhes: Nervuras (Ribs) do Silo
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;
    paint.color = isDark ? Colors.black26 : Colors.black.withOpacity(0.05);
    
    for (int i = 1; i < 8; i++) {
      double y = siloTop + (siloHeight * i / 8);
      canvas.drawLine(Offset(siloLeft, y), Offset(siloLeft + siloWidth, y), paint);
    }

    // 5. Escala de Medição Lateral
    paint.color = isDark ? Colors.white24 : Colors.black26;
    paint.strokeWidth = 1.5;
    for (int i = 0; i <= 4; i++) {
      double y = siloTop + siloHeight - (siloHeight * i / 4);
      canvas.drawLine(Offset(siloLeft + siloWidth + 5, y), Offset(siloLeft + siloWidth + 12, y), paint);
    }

    // 6. Vidro de Inspeção / Reflexo de Vidro (Efeito Profissional)
    final glassRect = Rect.fromLTWH(siloLeft, siloTop, siloWidth, siloHeight);
    final glassGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(isDark ? 0.05 : 0.2),
        Colors.transparent,
        Colors.white.withOpacity(isDark ? 0.02 : 0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(glassRect);
    
    paint.shader = glassGradient;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(glassRect, const Radius.circular(4)), paint);
  }

  @override
  bool shouldRepaint(covariant SiloPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.isDark != isDark;
  }
}
