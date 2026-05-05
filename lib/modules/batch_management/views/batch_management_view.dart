import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/batch_model.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/models/silo_model.dart';
import '../../../core/values/app_colors.dart';
import '../../farm_management/controllers/farm_management_controller.dart';
import '../../silo_management/controllers/silo_management_controller.dart';
import '../controllers/batch_management_controller.dart';

class BatchManagementView extends GetView<BatchManagementController> {
  const BatchManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
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
                                'Gestão de Lotes',
                                style: (isDesktop
                                        ? theme.textTheme.headlineSmall
                                        : theme.textTheme.titleLarge)
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isDesktop)
                              Text(
                                'Monitore e controle os ciclos de secagem de cada lote.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
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
            const SizedBox(height: 32),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.batches.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.batches.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(4),
                  itemCount: controller.batches.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildBatchCard(context, controller.batches[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBatchForm(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Novo Lote',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildBatchCard(BuildContext context, BatchModel batch) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 700;

    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(batch.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getStatusIcon(batch.status), color: _getStatusColor(batch.status), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lote ${batch.numeroLote}',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            _buildStatusChip(batch.status),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () => Future.delayed(Duration.zero, () => _showBatchForm(context, batch: batch)),
                            child: const Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Editar')]),
                          ),
                          PopupMenuItem(
                            onTap: () => controller.deleteBatch(batch.id!),
                            child: const Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      _buildInfoItem(Icons.inventory_2_outlined, '${batch.cultura} (${batch.safra})'),
                      _buildInfoItem(Icons.location_on_outlined, batch.farmName ?? 'N/A'),
                      if (batch.siloName != null) _buildInfoItem(Icons.warehouse_outlined, batch.siloName!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricItem('Peso Inicial', '${batch.pesoInicial.toStringAsFixed(0)} kg', isDark),
                        _buildMetricItem('Umidade', '${batch.umidadeInicial}%', isDark, crossAxisAlignment: CrossAxisAlignment.end),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(batch.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_getStatusIcon(batch.status), color: _getStatusColor(batch.status), size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Lote ${batch.numeroLote}',
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusChip(batch.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          children: [
                            _buildInfoItem(Icons.inventory_2_outlined, '${batch.cultura} (${batch.safra})'),
                            _buildInfoItem(Icons.location_on_outlined, batch.farmName ?? 'N/A'),
                            if (batch.siloName != null) _buildInfoItem(Icons.warehouse_outlined, batch.siloName!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  _buildMetricItem('Peso Inicial', '${batch.pesoInicial.toStringAsFixed(0)} kg', isDark, crossAxisAlignment: CrossAxisAlignment.end),
                  const SizedBox(width: 24),
                  _buildMetricItem('Umidade', '${batch.umidadeInicial}%', isDark, crossAxisAlignment: CrossAxisAlignment.end),
                  const SizedBox(width: 16),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => Future.delayed(Duration.zero, () => _showBatchForm(context, batch: batch)),
                        child: const Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Editar')]),
                      ),
                      PopupMenuItem(
                        onTap: () => controller.deleteBatch(batch.id!),
                        child: const Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))]),
                      ),
                    ],
                  ),
                ],
              ),
          if (batch.observacoes != null && batch.observacoes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_outlined, size: 14, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'NOTAS E DIAGNÓSTICOS',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: theme.primaryColor, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    batch.observacoes!,
                    style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, bool isDark, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusText(status).toUpperCase(),
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'aguardando': return Colors.orange;
      case 'secando': return AppColors.primary;
      case 'finalizado': return Colors.green;
      case 'despachado': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'aguardando': return 'Aguardando';
      case 'secando': return 'Em Secagem';
      case 'finalizado': return 'Finalizado';
      case 'despachado': return 'Despachado';
      default: return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'aguardando': return Icons.timer_outlined;
      case 'secando': return Icons.wb_sunny_outlined;
      case 'finalizado': return Icons.check_circle_outline;
      case 'despachado': return Icons.local_shipping_outlined;
      default: return Icons.help_outline;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhum lote cadastrado',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione lotes de grãos para iniciar o monitoramento da secagem.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showBatchForm(BuildContext context, {BatchModel? batch}) {
    final isEditing = batch != null;
    final farmController = Get.find<FarmManagementController>();
    final siloController = Get.find<SiloManagementController>();

    final numeroController = TextEditingController(text: batch?.numeroLote ?? '');
    final culturaController = TextEditingController(text: batch?.cultura ?? '');
    final safraController = TextEditingController(text: batch?.safra ?? '2023/2024');
    final pesoController = TextEditingController(text: batch?.pesoInicial.toString() ?? '');
    final umidadeController = TextEditingController(text: batch?.umidadeInicial.toString() ?? '');
    final observacoesController = TextEditingController(text: batch?.observacoes ?? '');
    
    final grainTypes = ['Milho', 'Soja', 'Arroz', 'Trigo', 'Sorgo', 'Café', 'Feijão', 'Outros'];
    final initialCultura = batch?.cultura ?? 'Milho';
    final selectedCultura = (grainTypes.contains(initialCultura) ? initialCultura : 'Outros').obs;
    
    var selectedFarmId = batch?.farm.obs ?? (farmController.farms.isNotEmpty ? farmController.farms.first.id : null).obs;
    var selectedSiloId = batch?.silo.obs ?? Rxn<int>();
    var selectedStatus = (batch?.status ?? 'aguardando').obs;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editar Lote' : 'Novo Lote',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('NÚMERO DO LOTE'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: numeroController,
                            decoration: _buildInputDecoration('Ex: L-001', Icons.tag, isDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('SAFRA'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: safraController,
                            decoration: _buildInputDecoration('Ex: 2023/24', Icons.calendar_today, isDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                _buildFieldLabel('CULTURA / GRÃO'),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedCultura.value,
                  decoration: _buildInputDecoration('Selecione o grão', Icons.grass, isDark),
                  items: grainTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (val) => selectedCultura.value = val!,
                )),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('PESO INICIAL (KG)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: pesoController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('0.0', Icons.scale, isDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('UMIDADE INICIAL (%)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: umidadeController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('0.0', Icons.water_drop, isDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildFieldLabel('FAZENDA / UNIDADE'),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<int>(
                  value: selectedFarmId.value,
                  decoration: _buildInputDecoration('Selecione a fazenda', Icons.agriculture, isDark),
                  items: farmController.farms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                  onChanged: (val) => selectedFarmId.value = val,
                )),

                const SizedBox(height: 24),
                _buildFieldLabel('STATUS'),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedStatus.value,
                  decoration: _buildInputDecoration('Status atual', Icons.info_outline, isDark),
                  items: const [
                    DropdownMenuItem(value: 'aguardando', child: Text('Aguardando')),
                    DropdownMenuItem(value: 'secando', child: Text('Em Secagem')),
                    DropdownMenuItem(value: 'finalizado', child: Text('Finalizado')),
                    DropdownMenuItem(value: 'despachado', child: Text('Despachado')),
                  ],
                  onChanged: (val) => selectedStatus.value = val!,
                )),

                const SizedBox(height: 24),
                Obx(() => DropdownButtonFormField<int>(
                  value: selectedSiloId.value,
                  decoration: _buildInputDecoration('Selecione o silo (Opcional)', Icons.warehouse, isDark),
                  items: siloController.silos
                      .where((s) => (s.farmId == selectedFarmId.value && s.status == 'disponivel') || s.id == batch?.silo)
                      .map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.capacity} Ton)')))
                      .toList(),
                  onChanged: (val) => selectedSiloId.value = val,
                )),
                
                const SizedBox(height: 24),
                _buildFieldLabel('NOTAS E DIAGNÓSTICOS'),
                const SizedBox(height: 8),
                TextField(
                  controller: observacoesController,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: _buildInputDecoration('Detalhes adicionais sobre o lote...', Icons.notes_rounded, isDark),
                ),

                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          final peso = double.tryParse(pesoController.text) ?? 0;
                          final siloId = selectedSiloId.value;

                          // Validação de Capacidade no Front
                          if (siloId != null) {
                            final silo = siloController.silos.firstWhere((s) => s.id == siloId);
                            if (peso > (silo.capacity * 1000)) {
                              Get.snackbar(
                                'Limite de Capacidade',
                                'O peso do lote (${peso}kg) excede a capacidade do silo ${silo.name} (${silo.capacity * 1000}kg).',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                          }

                          final newBatch = BatchModel(
                            id: batch?.id,
                            numeroLote: numeroController.text,
                            farm: selectedFarmId.value!,
                            cultura: selectedCultura.value,
                            safra: safraController.text,
                            pesoInicial: peso,
                            umidadeInicial: double.tryParse(umidadeController.text) ?? 0,
                            status: selectedStatus.value,
                            silo: siloId,
                            observacoes: observacoesController.text,
                          );
                          if (isEditing) {
                            controller.updateBatch(newBatch);
                          } else {
                            controller.createBatch(newBatch);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(isEditing ? 'Atualizar Lote' : 'Criar Lote'),
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
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.1),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.5)),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }
}
