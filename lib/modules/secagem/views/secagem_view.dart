import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/secador_model.dart';
import '../controllers/secagem_controller.dart';

class SecagemView extends GetView<SecagemController> {
  const SecagemView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32),
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
                if (controller.secadores.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildSecadoresGrid(context);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSecadorForm(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Novo Secador', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Controle de Secagem',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie sua frota de secadores industriais e monitore a capacidade de processamento.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waves_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhum secador cadastrado',
            style: GoogleFonts.inter(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no botão abaixo para adicionar seu primeiro equipamento.',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSecadoresGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 220,
      ),
      itemCount: controller.secadores.length,
      itemBuilder: (context, index) {
        final secador = controller.secadores[index];
        return _buildSecadorCard(context, secador);
      },
    );
  }

  Widget _buildSecadorCard(BuildContext context, SecadorModel secador) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
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
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.heat_pump_rounded, color: theme.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      secador.nome,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      secador.farmName ?? 'Sem Fazenda',
                      style: GoogleFonts.inter(fontSize: 13, color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(secador.status),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.settings_input_component_rounded, 'Tipo', secador.tipo),
              _buildInfoItem(Icons.speed_rounded, 'Capacidade', '${secador.capacidade} t/h'),
              _buildInfoItem(Icons.local_fire_department_rounded, 'Calor', secador.fonteCalor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showSecadorForm(context, secador: secador),
                icon: const Icon(Icons.edit_outlined),
                color: theme.primaryColor,
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, secador),
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Ativo': color = Colors.green; break;
      case 'Manutenção': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showSecadorForm(BuildContext context, {SecadorModel? secador}) {
    final isEditing = secador != null;
    final nameController = TextEditingController(text: secador?.nome);
    final capacityController = TextEditingController(text: secador?.capacidade.toString());
    final obsController = TextEditingController(text: secador?.observacoes);
    
    var selectedFarmId = secador?.farmId ?? (controller.availableFarms.isNotEmpty ? controller.availableFarms.first.id : null);
    var selectedType = secador?.tipo ?? 'Coluna';
    var selectedFuel = secador?.fonteCalor ?? 'Lenha';
    var selectedStatus = secador?.status ?? 'Ativo';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar Secador' : 'Novo Secador',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDropdownField<int>(
                        label: 'Fazenda / Unidade',
                        value: selectedFarmId,
                        items: controller.availableFarms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                        onChanged: (val) => selectedFarmId = val,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Nome do Equipamento', controller: nameController, icon: Icons.badge_outlined),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField<String>(
                              label: 'Tipo de Secador',
                              value: selectedType,
                              items: ['Coluna', 'Cascata', 'Fluxo Contínuo', 'Batelada']
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) => selectedType = val!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Capacidade (t/h)', 
                              controller: capacityController, 
                              icon: Icons.speed_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField<String>(
                              label: 'Fonte de Calor',
                              value: selectedFuel,
                              items: ['Lenha', 'Gás GLP', 'Biomassa', 'Elétrico']
                                  .map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                              onChanged: (val) => selectedFuel = val!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField<String>(
                              label: 'Status Operacional',
                              value: selectedStatus,
                              items: ['Ativo', 'Manutenção', 'Inativo']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) => selectedStatus = val!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Observações Técnicas', controller: obsController, icon: Icons.note_alt_outlined, maxLines: 3),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final newSecador = SecadorModel(
                        id: secador?.id,
                        farmId: selectedFarmId!,
                        nome: nameController.text,
                        tipo: selectedType,
                        capacidade: double.tryParse(capacityController.text) ?? 0.0,
                        fonteCalor: selectedFuel,
                        status: selectedStatus,
                        observacoes: obsController.text,
                      );
                      if (isEditing) {
                        controller.updateSecador(newSecador);
                      } else {
                        controller.createSecador(newSecador);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isEditing ? 'Salvar Alterações' : 'Cadastrar Secador'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, SecadorModel secador) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remover Secador?'),
        content: Text('Deseja realmente excluir o equipamento "${secador.nome}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => controller.deleteSecador(secador.id!),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
