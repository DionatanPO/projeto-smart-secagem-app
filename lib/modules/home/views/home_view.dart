import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/home_controller.dart';
import '../../settings/views/settings_view.dart';
import '../../access_management/views/access_management_view.dart';
import '../../silo_management/views/silo_management_view.dart';
import '../../devices/views/devices_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../support/views/support_view.dart';
import '../../smart_sense_ia/views/smart_sense_ia_view.dart';
import '../../profile/views/profile_view.dart';
import '../../simulation/views/simulation_view.dart';
import '../../silo_viewer/views/silo_viewer_view.dart';
import '../../farm_management/views/farm_management_view.dart';
import '../../batch_management/views/batch_management_view.dart';
import '../../batch_management/bindings/batch_management_binding.dart';
import '../../secagem/views/secagem_view.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= 1100;

    return Scaffold(
      drawer: isDesktop ? null : SafeArea(child: Builder(builder: (drawerContext) => _buildSidebar(drawerContext))),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) _buildSidebar(context),
            Expanded(
              child: Builder(
                builder: (viewContext) => Obx(
                  () =>
                      _buildContent(viewContext, controller.selectedIndex.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withOpacity(0.5),
          ),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(5, 0),
            ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(context, 0, 'Projeto',
                      Icons.architecture_rounded),
                  _buildMenuItem(
                      context, 1, 'Dashboard', Icons.dashboard_rounded),
                  _buildMenuItem(
                      context, 2, 'Gestão de Fazendas', Icons.location_on_rounded),
                  _buildMenuItem(
                      context, 3, 'Gestão de Silos', Icons.warehouse_rounded),
                  _buildMenuItem(
                      context, 12, 'Gestão de Lotes', Icons.inventory_2_rounded),
                  _buildMenuItem(
                      context, 13, 'Controle de Secagem', Icons.waves_rounded),
                  _buildMenuItem(context, 4, 'Dispositivos', Icons.hub_rounded),
                  _buildMenuItem(
                      context, 5, 'Notificações', Icons.notifications_rounded),
                  _buildMenuItem(
                      context, 6, 'Suporte Técnico', Icons.help_center_rounded),
                  _buildMenuItem(context, 7, 'Gestão de Acesso',
                      Icons.admin_panel_settings_rounded),
                  _buildMenuItem(
                      context, 8, 'Configuração', Icons.settings_rounded),
                  _buildMenuItem(
                      context, 9, 'Smart Sense IA', Icons.psychology_rounded),
                  _buildMenuItem(context, 10, 'Simulador Interativo',
                      Icons.science_rounded),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Divider(height: 1),
                  ),
                  _buildMenuItem(
                      context, 11, 'Meu Perfil', Icons.person_rounded),
                ],
              ),
            ),
          ),
          _buildSidebarFooter(context),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome_mosaic_rounded,
                color: theme.primaryColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'SMART SECAGEM',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : theme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, int index, String title, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.changePage(index);
              if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor.withOpacity(isDark ? 0.2 : 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? theme.primaryColor
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? (isDark ? Colors.white : theme.primaryColor)
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  if (isSelected) const Spacer(),
                  if (isSelected)
                    Container(
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
          ),
        ),
      );
    });
  }

  Widget _buildSidebarFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : AppColors.border.withOpacity(0.5),
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
            Navigator.pop(context);
          }
          controller.logout();
        },
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            const SizedBox(width: 16),
            Text(
              'Sair da Conta',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const SiloViewerView();
      case 1:
        return _buildDashboardContent(context);
      case 2:
        return const FarmManagementView();
      case 3:
        return const SiloManagementView();
      case 4:
        return const DevicesView();
      case 5:
        return const NotificationsView();
      case 6:
        return const SupportView();
      case 7:
        return const AccessManagementView();
      case 8:
        return const SettingsView();
      case 9:
        return const SmartSenseIAView();
      case 10:
        return const SimulationView();
      case 11:
        return const ProfileView();
      case 12:
        return const BatchManagementView();
      case 13:
        return const SecagemView();
      default:
        return const SiloViewerView();
    }
  }

  Widget _buildDashboardContent(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= 1100;

    return Container(
      width: double.infinity,
      height: double.infinity,
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
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Dashboard',
                    style: (isDesktop
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Obx(() => controller.isAnalyzing.value
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'IA Analisando...',
                          style: GoogleFonts.inter(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : IconButton(
                      onPressed: controller.analyzeData,
                      icon: Icon(Icons.refresh_rounded, color: theme.primaryColor),
                      tooltip: 'Atualizar Análise',
                    )),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildMainDashboardContent(context, isDesktop),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _buildAIChat(context),
                      ),
                    ],
                  )
                : _buildMainDashboardContent(context, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboardContent(BuildContext context, bool isDesktop) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAISummaryCard(context),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.activeAlerts.isEmpty) return const SizedBox.shrink();
            return Column(
              children: [
                ...controller.activeAlerts.map((alert) => _buildAlertCard(context, alert)),
                const SizedBox(height: 24),
              ],
            );
          }),
          _buildKPIPredictionsGrid(context, isDesktop),
          if (!isDesktop) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 500,
              child: _buildAIChat(context),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildAISummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Briefing Inteligente Gemini',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.aiSummary.value,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  height: 1.5,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, dynamic> alert) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (alert['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (alert['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert['icon'] as IconData, color: alert['color'] as Color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'] as String,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  alert['description'] as String,
                  style: GoogleFonts.inter(
                    color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: alert['color'] as Color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Aprovar Ação'),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIPredictionsGrid(BuildContext context, bool isDesktop) {
    return Obx(() {
      if (controller.kpiPredictions.isEmpty) return const SizedBox.shrink();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KPIs PREDITIVOS (IA)',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.5 : 2.0,
            ),
            itemCount: controller.kpiPredictions.length,
            itemBuilder: (context, index) {
              final kpi = controller.kpiPredictions[index];
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (kpi['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(kpi['icon'] as IconData, color: kpi['color'] as Color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            kpi['title'] as String,
                            style: GoogleFonts.inter(
                              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                kpi['value'] as String,
                                style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (kpi['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  kpi['status'] as String,
                                  style: GoogleFonts.inter(
                                    color: kpi['color'] as Color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildAIChat(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_fix_high_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analista de Dados IA',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.chatMessages[index];
                    final isUser = msg['isUser'] as bool;
                    return _buildChatMessage(context, isUser, msg['text'] as String);
                  },
                )),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.chatController,
                    decoration: InputDecoration(
                      hintText: 'Pergunte sobre os silos...',
                      hintStyle: GoogleFonts.inter(
                        color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (val) => controller.sendMessage(val),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => controller.sendMessage(controller.chatController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(BuildContext context, bool isUser, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                  ? AppColors.primary 
                  : (isDark ? AppColors.backgroundDark : AppColors.background),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                  bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: isUser ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded, color: isDark ? Colors.white70 : Colors.black54, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
