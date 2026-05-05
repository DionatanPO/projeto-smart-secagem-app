import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../controllers/access_management_controller.dart';

class AccessManagementView extends GetView<AccessManagementController> {
  const AccessManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AccessManagementController>()) {
      Get.put(AccessManagementController());
    }

    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 64, color: theme.hintColor),
                        const SizedBox(height: 16),
                        Text('Nenhum usuário cadastrado', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  );
                }
                return _buildUsersList(context);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserForm(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(
          'Novo Usuário',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Row(
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
                        'Gestão de Acesso',
                        style: (isDesktop
                                ? theme.textTheme.headlineSmall
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Gerencie os usuários e permissões do sistema.',
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
    );
  }


  Widget _buildUsersList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: controller.users.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        itemBuilder: (context, index) {
          final user = controller.users[index];
          return _buildUserTile(context, user);
        },
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final avatarColor = user.isStaff ? Colors.blue : Colors.green;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: avatarColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            user.username.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: avatarColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      title: Text(
        user.username,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(user.email),
            Text('•', style: TextStyle(color: theme.hintColor)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (user.isStaff ? AppColors.primary : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.accountType.toUpperCase(),
                style: TextStyle(
                  color: user.isStaff ? AppColors.primary : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.hintColor),
            onPressed: () => _showUserForm(context, user: user),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => _confirmDelete(context, user),
          ),
        ],
      ),
    );
  }

  void _showUserForm(BuildContext context, {UserModel? user}) {
    final isEditing = user != null;
    final usernameController = TextEditingController(text: user?.username ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    final accountType = (user?.accountType ?? 'operador').obs;
    final formKey = GlobalKey<FormState>();

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
            child: Form(
              key: formKey,
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
                              isEditing ? 'Editar Usuário' : 'Novo Usuário',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              isEditing ? 'Atualize as permissões ou dados do usuário.' : 'Cadastre um novo colaborador no sistema.',
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
                  _buildFieldLabel('NOME DE USUÁRIO'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: usernameController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: _buildInputDecoration('Ex: dionatan.p', Icons.person_outline_rounded, isDark),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('ENDEREÇO DE E-MAIL'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: _buildInputDecoration('Ex: contato@empresa.com', Icons.email_outlined, isDark),
                    validator: (v) => GetUtils.isEmail(v!) ? null : 'E-mail inválido',
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel(isEditing ? 'NOVA SENHA (OPCIONAL)' : 'SENHA DE ACESSO'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    style: GoogleFonts.inter(fontSize: 14),
                    obscureText: true,
                    decoration: _buildInputDecoration('••••••••', Icons.lock_outline_rounded, isDark),
                    validator: (v) => !isEditing && v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('NÍVEL DE ACESSO'),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<String>(
                        value: accountType.value,
                        style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        items: const [
                          DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                          DropdownMenuItem(value: 'operador', child: Text('Operador')),
                        ],
                        onChanged: (v) => accountType.value = v!,
                        decoration: _buildInputDecoration('', Icons.admin_panel_settings_outlined, isDark),
                      )),
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
                            if (formKey.currentState!.validate()) {
                              final newUser = UserModel(
                                id: user?.id,
                                username: usernameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                accountType: accountType.value,
                              );
                              if (isEditing) {
                                controller.updateUser(newUser);
                              } else {
                                controller.createUser(newUser);
                              }
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
                            isEditing ? 'Atualizar Dados' : 'Criar Conta',
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

  void _confirmDelete(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
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
                'Excluir Usuário',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Deseja realmente remover o usuário ${user.username}? Esta ação não poderá ser desfeita.',
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
                        controller.deleteUser(user.id!);
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
}
