import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized if not using bindings
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }

    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Personalização',
                        style: (isDesktop
                                ? theme.textTheme.headlineSmall
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha como o sistema deve ser exibido para você.',
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
            const SizedBox(height: 32),
            _buildThemeSection(context),
            const SizedBox(height: 48),
            _buildColorSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identidade Visual',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecione a cor de destaque da interface.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.border.withOpacity(0.5),
            ),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: controller.colorPresets.map((color) {
              return Obx(() {
                final isSelected =
                    controller.primaryColor.value.value == color.value;

                return GestureDetector(
                  onTap: () => controller.changePrimaryColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black.withOpacity(0.2))
                            : Colors.transparent,
                        width: isSelected ? 3 : 0,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 28,
                          )
                        : null,
                  ),
                );
              });
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modo de Exibição',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final cardWidth = isMobile ? double.infinity : 220.0;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildThemeCard(
                    context,
                    index: 0,
                    title: 'Automático',
                    subtitle: 'Segue o sistema',
                    icon: Icons.brightness_auto_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildThemeCard(
                    context,
                    index: 1,
                    title: 'Tema Claro',
                    subtitle: 'Interface clara',
                    icon: Icons.light_mode_rounded,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildThemeCard(
                    context,
                    index: 2,
                    title: 'Tema Escuro',
                    subtitle: 'Interface escura',
                    icon: Icons.dark_mode_rounded,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isSelected = controller.selectedThemeIndex.value == index;

      return InkWell(
        onTap: () => controller.changeThemeMode(index),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(isDark ? 0.12 : 0.05)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : (isDark
                      ? AppColors.borderDark
                      : AppColors.border.withOpacity(0.5)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor.withOpacity(0.15)
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.iconTheme.color?.withOpacity(0.6),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.textTheme.titleMedium?.color,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
