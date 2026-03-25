import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          _buildFilters(context),
          const SizedBox(height: 24),
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
                      Icon(Icons.people_outline_rounded, size: 64, color: Get.theme.hintColor),
                      const SizedBox(height: 16),
                      Text('Nenhum usuário cadastrado', style: Get.textTheme.titleMedium),
                    ],
                  ),
                );
              }
              return _buildUsersList(context);
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
                      'Gestão de Acesso',
                      style: (isDesktop
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gerencie os usuários e permissões do sistema.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showUserForm(context),
            icon: const Icon(Icons.person_add_rounded, size: 20),
            label: const Text('Novo Usuário'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: theme.hintColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome...',
                hintStyle: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
                border: InputBorder.none,
                filled: false,
              ),
              onChanged: (val) {
                // TODO: Implement search logic in controller
              },
            ),
          ),
          const VerticalDivider(indent: 10, endIndent: 10),
          IconButton(
            onPressed: () => controller.getUsers(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar Lista',
          ),
        ],
      ),
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

    Get.dialog(
      AlertDialog(
        title: Text(isEditing ? 'Editar Usuário' : 'Novo Usuário'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (v) => GetUtils.isEmail(v!) ? null : 'E-mail inválido',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Nova Senha (opcional)' : 'Senha',
                  ),
                  obscureText: true,
                  validator: (v) => !isEditing && v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<String>(
                      value: accountType.value,
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                        DropdownMenuItem(value: 'operador', child: Text('Operador')),
                      ],
                      onChanged: (v) => accountType.value = v!,
                      decoration: const InputDecoration(labelText: 'Tipo de Conta'),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
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
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Excluir Usuário'),
        content: Text('Deseja realmente excluir o usuário ${user.username}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              controller.deleteUser(user.id!);
              Get.back();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
