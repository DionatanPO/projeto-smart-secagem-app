import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(NotificationsController());
    }

    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 32.0 : 16.0,
          isDesktop ? 32.0 : 16.0,
          isDesktop ? 32.0 : 16.0,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDesktop),
            const SizedBox(height: 24),
            _buildFilterBar(context),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                final notifications = controller.filteredNotifications;
                if (notifications.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return _buildNotificationItem(context, item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildBottomActions(context, isDesktop),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    return Row(
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
              Text(
                'Notificações',
                style: (isDesktop
                        ? theme.textTheme.headlineSmall
                        : theme.textTheme.titleLarge)
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Acompanhe o histórico de eventos e alertas.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() => SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<String>(
          segments: controller.filters.map((filter) {
            return ButtonSegment<String>(
              value: filter,
              label: Text(filter),
              icon: _getFilterIcon(filter),
            );
          }).toList(),
          selected: {controller.selectedFilter.value},
          onSelectionChanged: (newSelection) {
            controller.changeFilter(newSelection.first);
          },
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            selectedBackgroundColor: theme.primaryColor,
            selectedForegroundColor: Colors.white,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            visualDensity: VisualDensity.comfortable,
          ),
        ),
      ),
    ));
  }

  Icon? _getFilterIcon(String filter) {
    switch (filter.toLowerCase()) {
      case 'todos': return const Icon(Icons.all_inclusive_rounded, size: 18);
      case 'críticos': return const Icon(Icons.warning_amber_rounded, size: 18);
      case 'avisos': return const Icon(Icons.info_outline_rounded, size: 18);
      case 'lidos': return const Icon(Icons.mark_email_read_outlined, size: 18);
      default: return null;
    }
  }

  Widget _buildBottomActions(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.9) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            context,
            onPressed: controller.clearAll,
            icon: Icons.delete_sweep_rounded,
            label: 'Limpar Tudo',
            color: AppColors.error,
            isPrimary: false,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context,
            onPressed: controller.markAllAsRead,
            icon: Icons.done_all_rounded,
            label: 'Marcar Lidos',
            color: theme.primaryColor,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isPrimary,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        foregroundColor: isPrimary ? Colors.white : color,
        backgroundColor: isPrimary ? color : color.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRead = item['isRead'] as bool;
    final typeColor = item['color'] as Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.markAsRead(item['id'] as String),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isRead
                ? Colors.transparent
                : theme.primaryColor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead
                  ? (isDark
                      ? AppColors.borderDark
                      : AppColors.border.withOpacity(0.5))
                  : theme.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(item['icon'] as IconData, color: typeColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item['title'] as String,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight:
                                        !isRead ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['time'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    if (item['target'] != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['target'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64,
            color: theme.disabledColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Tudo limpo por aqui!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.disabledColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhuma nova notificação ou alerta no momento.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
