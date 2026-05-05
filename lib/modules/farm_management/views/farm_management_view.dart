import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/farm_management_controller.dart';

class FarmManagementView extends GetView<FarmManagementController> {
  const FarmManagementView({super.key});

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
                                'Gestão de Fazendas',
                                style: GoogleFonts.outfit(
                                  fontSize: isDesktop ? 28 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isDesktop)
                              Text(
                                'Gerencie as unidades de armazenamento e suas localizações.',
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
                if (controller.isLoading.value && controller.farms.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
  
                if (controller.farms.isEmpty) {
                  return _buildEmptyState(context);
                }
  
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 450,
                    mainAxisExtent: 200,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: controller.farms.length,
                  itemBuilder: (context, index) {
                    return _buildFarmCard(context, controller.farms[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFarmForm(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(
          'Nova Unidade',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildFarmCard(BuildContext context, FarmModel farm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.name,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      farm.location ?? 'Sem localização definida',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => Future.delayed(Duration.zero, () => _showFarmForm(context, farm: farm)),
                    child: const Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Editar')]),
                  ),
                  PopupMenuItem(
                    onTap: () => controller.deleteFarm(farm.id!),
                    child: const Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhuma fazenda cadastrada',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece adicionando uma fazenda ou armazém para organizar seus silos.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showFarmForm(BuildContext context, {FarmModel? farm}) {
    final isEditing = farm != null;
    final nameController = TextEditingController(text: farm?.name ?? '');
    final locationController = TextEditingController(text: farm?.location ?? '');
    final descController = TextEditingController(text: farm?.description ?? '');
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
                            isEditing ? 'Editar Unidade' : 'Nova Unidade',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isEditing ? 'Atualize as informações da fazenda ou armazém.' : 'Cadastre uma nova localidade para seus silos.',
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
                _buildFieldLabel('NOME DA FAZENDA/ARMAZÉM'),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: _buildInputDecoration('Ex: Fazenda Santa Fé', Icons.business_rounded, isDark),
                ),
                const SizedBox(height: 24),
                _buildFieldLabel('LOCALIZAÇÃO / CIDADE'),
                const SizedBox(height: 8),
                TextField(
                  controller: locationController,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: _buildInputDecoration('Ex: Rio Verde - GO', Icons.location_on_rounded, isDark),
                ),
                const SizedBox(height: 24),
                _buildFieldLabel('DESCRIÇÃO / OBSERVAÇÕES'),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: _buildInputDecoration('Notas técnicas ou histórico da unidade...', Icons.notes_rounded, isDark),
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
                          final newFarm = FarmModel(
                            id: farm?.id,
                            name: nameController.text,
                            location: locationController.text,
                            description: descController.text,
                          );
                          if (isEditing) {
                            controller.updateFarm(newFarm);
                          } else {
                            controller.createFarm(newFarm);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          isEditing ? 'Atualizar Unidade' : 'Cadastrar Unidade',
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
}
