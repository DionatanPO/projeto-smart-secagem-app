import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= 1024;
    final bool isTablet = size.width >= 600 && size.width < 1024;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 1,
              child: _buildBrandingSide(context),
            ),
          Expanded(
            child: Container(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 80 : (isTablet ? 60 : 24),
                      vertical: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isDesktop) _buildMobileHeader(context),
                          const SizedBox(height: 48),
                          _buildFormHeader(context),
                          const SizedBox(height: 40),
                          _buildLoginForm(context),
                          const SizedBox(height: 32),
                          _buildFooter(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSide(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? null : AppColors.primaryGradient,
        color: isDark ? AppColors.surfaceDark : null,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.02)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.auto_awesome_mosaic_rounded,
                          color: isDark ? AppColors.primary : Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Smart Secagem',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Inteligência na\nSecagem de Grãos.',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      color: isDark ? Colors.white : AppColors.textLight,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Otimize sua colheita com aeração inteligente e monitoramento em tempo real.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textLight.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_mosaic_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Smart Secagem',
            style: theme.textTheme.titleLarge?.copyWith(
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acesse sua conta',
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: 12),
        Text(
          'Entre com suas credenciais para gerenciar seus dados.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildTextField(
            context,
            label: 'Seu e-mail de acesso',
            hint: 'seu@email.com',
            icon: Icons.mail_outline_rounded,
            controller: controller.emailController,
            validator: (val) =>
                GetUtils.isEmail(val ?? '') ? null : 'E-mail inválido',
          ),
          const SizedBox(height: 24),
          _buildPasswordField(context),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Esqueceu sua senha?'),
            ),
          ),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Senha de Acesso',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: !controller.showPassword.value,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showPassword.value
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: theme.hintColor,
                    size: 20,
                  ),
                  onPressed: controller.toggleShowPassword,
                ),
              ),
              validator: (val) =>
                  (val?.length ?? 0) >= 6 ? null : 'Mínimo 6 caracteres',
            )),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              if (!controller.isLoading.value)
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.login,
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                  )
                : const Text('Entrar no Sistema'),
          ),
        ));
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Precisa de acesso? ",
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Fale com o Administrador'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => Get.offAllNamed(Routes.landing),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Voltar para o site público'),
        ),
      ],
    );
  }
}
