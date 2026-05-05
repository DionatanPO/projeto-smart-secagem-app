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
                  return ListView.separated(
                    padding: const EdgeInsets.all(4),
                    itemCount: controller.silos.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 32),
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
    final width = MediaQuery.of(context).size.width;
    final isHorizontal = width > 850;
    final padding = isHorizontal ? 24.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: isHorizontal
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _buildIdentitySection(context, silo, statusColor, isDark, padding, true)),
                  VerticalDivider(width: 1, color: theme.dividerColor.withOpacity(0.5)),
                  Expanded(flex: 4, child: _buildTelemetrySection(context, silo, padding)),
                  VerticalDivider(width: 1, color: theme.dividerColor.withOpacity(0.5)),
                  Expanded(flex: 3, child: _buildNotesSection(context, silo, padding, true)),
                  VerticalDivider(width: 1, color: theme.dividerColor.withOpacity(0.5)),
                  Expanded(flex: 2, child: _buildActionsSection(context, silo, index, padding, true)),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIdentitySection(context, silo, statusColor, isDark, padding, false),
                const Divider(height: 1),
                _buildTelemetrySection(context, silo, padding),
                const Divider(height: 1),
                _buildNotesSection(context, silo, padding, false),
                const Divider(height: 1),
                _buildActionsSection(context, silo, index, padding, false),
              ],
            ),
    );
  }

  Widget _buildIdentitySection(BuildContext context, SiloModel silo, Color statusColor, bool isDark, double padding, bool isHorizontal) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
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
                      silo.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capacidade: ${silo.capacity}t',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(silo.status, statusColor),
            ],
          ),
          SizedBox(height: isHorizontal ? 32 : 16),
          _buildSiloGraphic(context, silo, statusColor, isDark, isHorizontal),
        ],
      ),
    );
  }

  Widget _buildSiloGraphic(BuildContext context, SiloModel silo, Color statusColor, bool isDark, bool isHorizontal) {
    final theme = Theme.of(context);
    final graphicWidth = isHorizontal ? 120.0 : 100.0;
    final graphicHeight = isHorizontal ? 160.0 : 130.0;

    return Center(
      child: SizedBox(
        width: graphicWidth,
        height: graphicHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(graphicWidth, graphicHeight),
              painter: SiloPainter(
                percentage: silo.percentage,
                statusColor: statusColor,
                isDark: isDark,
              ),
            ),
            // Texto de Porcentagem
            Positioned(
              bottom: graphicHeight * 0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${silo.percentage.toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: isHorizontal ? 16 : 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Tooltip de Quantidade
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor, width: 0.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  '${silo.currentQuantity}t / ${silo.capacity}t',
                  style: GoogleFonts.inter(
                    fontSize: isHorizontal ? 9 : 8,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetrySection(BuildContext context, SiloModel silo, double padding) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors_rounded, size: 18, color: theme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SENSORES EM TEMPO REAL',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: theme.primaryColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final readings = controller.getLatestReadings(silo.id ?? 0);
            if (readings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('Aguardando conexão...', style: theme.textTheme.bodySmall),
                ),
              );
            }
            return Column(
              children: readings.map((r) => _buildSensorReadingRow(context, r)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, SiloModel silo, double padding, bool isHorizontal) {
    final theme = Theme.of(context);
    
    final notesWidget = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Text(
        silo.observations?.isEmpty ?? true 
            ? 'Nenhuma observação registrada para este silo.' 
            : silo.observations!,
        style: GoogleFonts.inter(
          fontSize: 12,
          height: 1.6,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          fontStyle: silo.observations?.isEmpty ?? true ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 18, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'NOTAS E DIAGNÓSTICOS',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: theme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isHorizontal)
            Expanded(
              child: SingleChildScrollView(
                child: notesWidget,
              ),
            )
          else
            notesWidget,
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, SiloModel silo, int index, double padding, bool isHorizontal) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.01) : Colors.black.withOpacity(0.01),
        borderRadius: isHorizontal 
          ? const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24))
          : const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AÇÕES AUTOMÁTICAS',
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: theme.hintColor),
          ),
          const SizedBox(height: 16),
          if (isHorizontal) ...[
            _buildActionItem(context, Icons.wind_power_rounded, 'AERAÇÃO', Colors.blue, () => controller.toggleAeration(index)),
            const SizedBox(height: 12),
            _buildActionItem(context, Icons.sensors_rounded, 'SENSORES', theme.primaryColor, () {
              controller.getSensorsBySilo(silo.id!);
              _showSiloSensors(context, silo);
            }),
            const SizedBox(height: 12),
            _buildActionItem(context, Icons.edit_rounded, 'EDITAR', Colors.grey, () => _showSiloForm(context, silo: silo)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _confirmDelete(context, silo),
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: const Text('REMOVER'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                textStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ] else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCompactAction(context, Icons.wind_power_rounded, 'Ar', Colors.blue, () => controller.toggleAeration(index)),
                _buildCompactAction(context, Icons.sensors_rounded, 'Sensores', theme.primaryColor, () {
                  controller.getSensorsBySilo(silo.id!);
                  _showSiloSensors(context, silo);
                }),
                _buildCompactAction(context, Icons.edit_rounded, 'Edit', Colors.grey, () => _showSiloForm(context, silo: silo)),
                _buildCompactAction(context, Icons.delete_outline_rounded, 'Del', Colors.redAccent, () => _confirmDelete(context, silo)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompactAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
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
