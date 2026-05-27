import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/user_model.dart';
import '../controllers/access_management_controller.dart';

class AccessManagementView extends GetView<AccessManagementController> {
  const AccessManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AccessManagementController>()) {
      Get.put(AccessManagementController());
    }

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
                          'Gestão de Acesso',
                          style: GoogleFonts.outfit(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ),
                      if (isDesktop)
                        Text('Gerencie os usuários e permissões do sistema.', style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 20),
              child: SearchBar(
                hintText: 'Buscar usuário...',
                hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(color: cs.onSurfaceVariant)),
                leading: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerHighest.withOpacity(0.5)),
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                textStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 14, color: cs.onSurface)),
                onChanged: controller.filterUsers,
              ),
            ),
            Expanded(
              child: Obx(() {
                final list = controller.filteredUsers;
                if (controller.isLoading.value && list.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (list.isEmpty) {
                  return _buildEmptyState(context, controller.searchQuery.value.isNotEmpty);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(4),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _buildUserCard(context, list[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserForm(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.person_add_rounded),
        label: Text('Novo Usuário', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    final cs = Theme.of(context).colorScheme;
    final avatarColor = user.isStaff ? cs.primary : Colors.orange;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showUserForm(context, user: user),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: avatarColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(user.username.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: avatarColor),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(user.username, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (user.isStaff ? cs.primary : Colors.orange).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(user.accountType.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: avatarColor, letterSpacing: 0.3)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(user.email, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert_rounded, size: 20, color: cs.onSurfaceVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                color: cs.surfaceContainerLow,
                onSelected: (value) {
                  if (value == 0) _showUserForm(context, user: user);
                  if (value == 1) _confirmDelete(context, user);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: cs.primary), const SizedBox(width: 10), Text('Editar', style: GoogleFonts.inter(color: cs.onSurface))])),
                  PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: cs.error), const SizedBox(width: 10), Text('Excluir', style: GoogleFonts.inter(color: cs.error))])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            child: Icon(hasSearch ? Icons.search_off_rounded : Icons.people_outline_rounded, size: 40, color: cs.onSurfaceVariant.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(hasSearch ? 'Nenhum resultado encontrado' : 'Nenhum usuário cadastrado', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(hasSearch ? 'Tente buscar por nome, e-mail ou nível de acesso.' : 'Adicione um novo usuário para liberar o acesso ao sistema.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.delete_forever_rounded, color: cs.error, size: 22)),
            const SizedBox(width: 12),
            Text('Excluir Usuário', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
        content: Text('Deseja remover o usuário "${user.username}"? Esta ação não poderá ser desfeita.', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Cancelar', style: GoogleFonts.inter(color: cs.onSurfaceVariant))),
          FilledButton(onPressed: () { controller.deleteUser(user.id!); Get.back(); }, style: FilledButton.styleFrom(backgroundColor: cs.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Excluir', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showUserForm(BuildContext context, {UserModel? user}) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = user != null;
    final usernameCtl = TextEditingController(text: user?.username ?? '');
    final emailCtl = TextEditingController(text: user?.email ?? '');
    final passwordCtl = TextEditingController();
    final accountType = (user?.accountType ?? 'operador').obs;
    final formKey = GlobalKey<FormState>();

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
                          Text(isEditing ? 'Editar Usuário' : 'Novo Usuário', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                          const SizedBox(height: 4),
                          Text(isEditing ? 'Atualize as permissões ou dados do usuário.' : 'Cadastre um novo colaborador no sistema.', style: GoogleFonts.inter(fontSize: 13, color: cs.onPrimary.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded), style: IconButton.styleFrom(backgroundColor: cs.onPrimary.withOpacity(0.15)), color: cs.onPrimary),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(cs, 'NOME DE USUÁRIO'),
                      const SizedBox(height: 8),
                      _field(cs, usernameCtl, 'Ex: dionatan.p', Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'E-MAIL'),
                      const SizedBox(height: 8),
                      _field(cs, emailCtl, 'Ex: contato@empresa.com', Icons.email_outlined, validator: (v) => GetUtils.isEmail(v!) ? null : 'E-mail inválido'),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, isEditing ? 'NOVA SENHA (OPCIONAL)' : 'SENHA'),
                      const SizedBox(height: 8),
                      _field(cs, passwordCtl, '••••••••', Icons.lock_outline_rounded, obscure: true, validator: (v) => !isEditing && v!.isEmpty ? 'Campo obrigatório' : null),
                      const SizedBox(height: 20),
                      _fieldLabel(cs, 'NÍVEL DE ACESSO'),
                      const SizedBox(height: 8),
                      Obx(() => DropdownButtonFormField<String>(
                        value: accountType.value,
                        style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                        dropdownColor: cs.surfaceContainerLow,
                        decoration: _dropDeco(cs, Icons.admin_panel_settings_outlined),
                        items: const [
                          DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                          DropdownMenuItem(value: 'operador', child: Text('Operador')),
                        ],
                        onChanged: (v) => accountType.value = v!,
                      )),
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
                              if (formKey.currentState!.validate()) {
                                final u = UserModel(id: user?.id, username: usernameCtl.text, email: emailCtl.text, password: passwordCtl.text, accountType: accountType.value);
                                if (isEditing) { controller.updateUser(u); } else { controller.createUser(u); }
                              }
                            },
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: Text(isEditing ? 'Atualizar' : 'Criar Conta', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

  Widget _field(ColorScheme cs, TextEditingController ctl, String hint, IconData icon, {bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctl, obscureText: obscure, validator: validator,
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
}