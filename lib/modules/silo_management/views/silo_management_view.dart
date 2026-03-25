import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/silo_model.dart';
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

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
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
                      Icon(Icons.warehouse_outlined, size: 64, color: theme.hintColor),
                      const SizedBox(height: 16),
                      Text('Nenhum silo cadastrado', style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }

              return LayoutBuilder(builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 2;
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    mainAxisExtent: 450,
                  ),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
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
                      'Gestão de Silos',
                      style: (isDesktop
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitoramento em tempo real dos seus silos de secagem.',
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
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: controller.refreshSilos,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Sincronizar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  side: BorderSide(color: theme.primaryColor),
                  foregroundColor: theme.primaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showSiloForm(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Novo Silo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
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
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.border.withOpacity(0.5),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.warehouse_rounded,
                              color: theme.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              silo.name,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              silo.productType,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        silo.status.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Silo Visual com nível
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      width: 120,
                      height: 180 * (silo.percentage / 100).clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.primaryColor.withOpacity(0.8),
                            theme.primaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${silo.percentage.toInt()}%',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    // Detalhes da capacidade
                    Positioned(
                      top: 10,
                      child: Text(
                        '${silo.currentQuantity}t / ${silo.capacity}t',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Ações do Silo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.border.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => _showSiloForm(context, silo: silo),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar Silo',
                ),
                IconButton(
                  onPressed: () => controller.toggleAeration(index),
                  icon: const Icon(Icons.air_rounded),
                  tooltip: 'Controlar Aeração',
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, silo),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Excluir Silo',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return Colors.green;
      case 'manutencao':
        return Colors.orange;
      case 'desactivated':
      case 'desativado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showSiloForm(BuildContext context, {SiloModel? silo}) {
    final isEditing = silo != null;
    final nameController = TextEditingController(text: silo?.name ?? '');
    final capacityController = TextEditingController(text: silo?.capacity.toString() ?? '');
    final quantityController = TextEditingController(text: silo?.currentQuantity.toString() ?? '');
    final productController = TextEditingController(text: silo?.productType ?? '');
    final status = (silo?.status ?? 'ativo').obs;

    Get.dialog(
      AlertDialog(
        title: Text(isEditing ? 'Editar Silo' : 'Novo Silo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do Silo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: productController,
                decoration: const InputDecoration(labelText: 'Tipo de Grão'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: capacityController,
                      decoration: const InputDecoration(labelText: 'Capacidade (t)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Qtd Atual (t)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: status.value,
                    items: const [
                      DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                      DropdownMenuItem(value: 'manutencao', child: Text('Em Manutenção')),
                      DropdownMenuItem(value: 'desativado', child: Text('Desativado')),
                    ],
                    onChanged: (v) => status.value = v!,
                    decoration: const InputDecoration(labelText: 'Status Operacional'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final newSilo = SiloModel(
                id: silo?.id,
                name: nameController.text,
                capacity: double.tryParse(capacityController.text) ?? 0.0,
                currentQuantity: double.tryParse(quantityController.text) ?? 0.0,
                productType: productController.text,
                status: status.value,
              );
              if (isEditing) {
                controller.updateSilo(newSilo);
              } else {
                controller.createSilo(newSilo);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SiloModel silo) {
    Get.dialog(
      AlertDialog(
        title: const Text('Excluir Silo'),
        content: Text('Deseja realmente excluir o silo ${silo.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              controller.deleteSilo(silo.id!);
              Get.back();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
