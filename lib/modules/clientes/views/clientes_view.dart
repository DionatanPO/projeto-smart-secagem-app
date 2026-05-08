import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/cliente_model.dart';
import '../controllers/clientes_controller.dart';

class ClientesView extends GetView<ClientesController> {
  const ClientesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                if (controller.clientes.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildClientesList(context);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClienteForm(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text('Novo Cliente', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestão de Clientes',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie o cadastro e informações dos seus clientes.',
          style: GoogleFonts.inter(fontSize: 16, color: theme.hintColor),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhum cliente cadastrado',
            style: GoogleFonts.inter(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildClientesList(BuildContext context) {
    return ListView.separated(
      itemCount: controller.clientes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildClienteCard(context, controller.clientes[index]),
    );
  }

  Widget _buildClienteCard(BuildContext context, ClienteModel cliente) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.person_rounded, color: theme.primaryColor, size: 28),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nome,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (cliente.email != null) ...[
                      Icon(Icons.email_outlined, size: 14, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        cliente.email!,
                        style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (cliente.telefone != null) ...[
                      Icon(Icons.phone_outlined, size: 14, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        cliente.telefone!,
                        style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ],
                ),
                if (cliente.cpfCnpj != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Doc: ${cliente.cpfCnpj}',
                    style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ],
            ),
          ),
          _buildQuickActions(context, cliente),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ClienteModel cliente) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _ActionButton(
          icon: Icons.edit_outlined, 
          color: theme.primaryColor, 
          onTap: () => _showClienteForm(context, cliente: cliente)
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.delete_outline_rounded, 
          color: Colors.red, 
          onTap: () => _confirmDelete(cliente)
        ),
      ],
    );
  }

  void _confirmDelete(ClienteModel cliente) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remover Cliente?'),
        content: Text('Tem certeza que deseja remover o cliente "${cliente.nome}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCliente(cliente.id!);
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showClienteForm(BuildContext context, {ClienteModel? cliente}) {
    final isEditing = cliente != null;
    final nomeController = TextEditingController(text: cliente?.nome);
    final emailController = TextEditingController(text: cliente?.email);
    final telefoneController = TextEditingController(text: cliente?.telefone);
    final cpfCnpjController = TextEditingController(text: cliente?.cpfCnpj);
    final enderecoController = TextEditingController(text: cliente?.endereco);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Editar Cliente' : 'Cadastrar Novo Cliente', 
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 24),
                _buildTextField(label: 'Nome Completo', controller: nomeController, icon: Icons.person_outlined),
                const SizedBox(height: 16),
                _buildTextField(label: 'E-mail', controller: emailController, icon: Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField(label: 'Telefone', controller: telefoneController, icon: Icons.phone_outlined),
                const SizedBox(height: 16),
                _buildTextField(label: 'CPF/CNPJ', controller: cpfCnpjController, icon: Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildTextField(label: 'Endereço', controller: enderecoController, icon: Icons.location_on_outlined),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (nomeController.text.isEmpty) {
                          Get.snackbar('Erro', 'O nome é obrigatório');
                          return;
                        }
                        final newCliente = ClienteModel(
                          id: cliente?.id,
                          nome: nomeController.text,
                          email: emailController.text.isEmpty ? null : emailController.text,
                          telefone: telefoneController.text.isEmpty ? null : telefoneController.text,
                          cpfCnpj: cpfCnpjController.text.isEmpty ? null : cpfCnpjController.text,
                          endereco: enderecoController.text.isEmpty ? null : enderecoController.text,
                        );
                        if (isEditing) {
                          controller.updateCliente(newCliente);
                        } else {
                          controller.createCliente(newCliente);
                        }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                      child: Text(isEditing ? 'Salvar Alterações' : 'Cadastrar'),
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

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
