import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/cliente_model.dart';
import '../../../core/models/farm_model.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/clientes_controller.dart';

class ClientesView extends GetView<ClientesController> {
  const ClientesView({super.key});

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
            Row(
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
                          'Clientes',
                          style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ),
                      if (isDesktop)
                        Text('Gerencie o cadastro dos seus clientes.', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 20),
              child: SearchBar(
                hintText: 'Buscar cliente...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(color: cs.onSurfaceVariant)),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHighest.withOpacity(0.5)),
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                onChanged: controller.filterClientes,
              ),
            ),
            Expanded(
              child: Obx(() {
                final list = controller.filteredClientes;
                if (controller.isLoading.value && list.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (list.isEmpty) {
                  return _buildEmptyState(context, controller.searchQuery.value.isNotEmpty);
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildClienteCard(context, list[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClienteForm(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.person_add_rounded),
        label: Text('Novo Cliente', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildClienteCard(BuildContext context, ClienteModel cliente) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showClienteForm(context, cliente: cliente),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.primary, cs.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.person_rounded, color: cs.onPrimary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nome, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    const SizedBox(height: 6),
                    if (cliente.email != null || cliente.telefone != null)
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          if (cliente.email != null)
                            _infoRow(cs, Icons.email_outlined, cliente.email!),
                          if (cliente.telefone != null)
                            _infoRow(cs, Icons.phone_outlined, cliente.telefone!),
                        ],
                      ),
                    if (cliente.cpfCnpj != null) ...[
                      const SizedBox(height: 2),
                      _infoRow(cs, Icons.badge_outlined, '${cliente.cpfCnpj}'),
                    ],
                    if (cliente.endereco != null) ...[
                      const SizedBox(height: 2),
                      _infoRow(cs, Icons.location_on_outlined, cliente.endereco!),
                    ],
                    if (cliente.farmName != null) ...[
                      const SizedBox(height: 2),
                      _infoRow(cs, Icons.agriculture_outlined, cliente.farmName!),
                    ],
                    if (cliente.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 12, color: cs.onSurfaceVariant.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(DateFormat('dd/MM/yyyy').format(cliente.createdAt!), style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant.withOpacity(0.5))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert_rounded, size: 20, color: cs.onSurfaceVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                color: cs.surfaceContainerLow,
                onSelected: (value) {
                  if (value == 0) _showClienteForm(context, cliente: cliente);
                  if (value == 1) _confirmDelete(context, cliente);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                  if (Get.find<HomeController>().isAdmin)
                  PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(ColorScheme cs, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasSearch) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(hasSearch ? Icons.search_off_rounded : Icons.people_alt_outlined, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(
            hasSearch ? 'Nenhum resultado encontrado' : 'Nenhum cliente cadastrado',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch ? 'Tente buscar por nome, e-mail, telefone ou documento.' : 'Adicione um novo cliente para começar.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ClienteModel cliente) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: cs.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.delete_outline_rounded, color: cs.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Remover Cliente?', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
        content: Text('Tem certeza que deseja remover "${cliente.nome}"?', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Cancelar', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () { Get.back(); controller.deleteCliente(cliente.id!); },
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Remover', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showClienteForm(BuildContext context, {ClienteModel? cliente}) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = cliente != null;
    final nomeCtl = TextEditingController(text: cliente?.nome);
    final emailCtl = TextEditingController(text: cliente?.email);
    final telCtl = TextEditingController(text: cliente?.telefone);
    final docCtl = TextEditingController(text: cliente?.cpfCnpj);
    final endCtl = TextEditingController(text: cliente?.endereco);
    final selectedFarm = (cliente?.farm).obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 520,
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
                          Text(isEditing ? 'Editar Cliente' : 'Novo Cliente', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text(isEditing ? 'Atualize as informações do cliente.' : 'Cadastre um novo cliente.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
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
                      _fieldLabel(cs, 'NOME COMPLETO'),
                      const SizedBox(height: 8),
                      _field(cs, nomeCtl, 'Ex: João Silva', Icons.person_outlined),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'E-MAIL'),
                      const SizedBox(height: 8),
                      _field(cs, emailCtl, 'Ex: joao@email.com', Icons.email_outlined),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'TELEFONE'),
                      const SizedBox(height: 8),
                      _field(cs, telCtl, 'Ex: (64) 99999-8888', Icons.phone_outlined),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'CPF / CNPJ'),
                      const SizedBox(height: 8),
                      _field(cs, docCtl, 'Ex: 000.000.000-00', Icons.badge_outlined),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'ENDEREÇO'),
                      const SizedBox(height: 8),
                      _field(cs, endCtl, 'Ex: Fazenda Boa Esperança - Zona Rural', Icons.location_on_outlined),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'FAZENDA'),
                      const SizedBox(height: 8),
                      Obx(() {
                        final farms = controller.farms;
                        return DropdownButtonFormField<int?>(
                          value: selectedFarm.value,
                          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                          dropdownColor: cs.surfaceContainerLow,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.agriculture_outlined, size: 20, color: cs.primary.withOpacity(0.6)),
                            filled: true, fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                          hint: Text('Selecione uma fazenda', style: GoogleFonts.inter(color: cs.onSurfaceVariant.withOpacity(0.5))),
                          items: farms.map((FarmModel f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(f.name),
                          )).toList(),
                          onChanged: (v) => selectedFarm.value = v,
                        );
                      }),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Get.back(),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: Text('Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () {
                                if (nomeCtl.text.isEmpty) {
                                  Get.snackbar('Erro', 'O nome é obrigatório');
                                  return;
                                }
                                if (selectedFarm.value == null) {
                                  Get.snackbar('Erro', 'Selecione uma fazenda');
                                  return;
                                }
                                final c = ClienteModel(
                                  id: cliente?.id, nome: nomeCtl.text,
                                  email: emailCtl.text.isEmpty ? null : emailCtl.text,
                                  telefone: telCtl.text.isEmpty ? null : telCtl.text,
                                  cpfCnpj: docCtl.text.isEmpty ? null : docCtl.text,
                                  endereco: endCtl.text.isEmpty ? null : endCtl.text,
                                  farm: selectedFarm.value,
                                );
                                if (isEditing) { controller.updateCliente(c); } else { controller.createCliente(c); }
                              },
                              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: Text(isEditing ? 'Atualizar' : 'Cadastrar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                            ),
                          ),
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

  Widget _field(ColorScheme cs, TextEditingController ctl, String hint, IconData icon) {
    return TextField(
      controller: ctl,
      style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant.withOpacity(0.5)),
        prefixIcon: Icon(icon, size: 20, color: cs.primary.withOpacity(0.6)),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.primary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
