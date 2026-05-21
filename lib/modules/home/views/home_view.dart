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
import '../../secagem/views/secagem_view.dart';
import '../../processos/views/processos_view.dart';
import '../../clientes/views/clientes_view.dart';

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
                  () => _buildContent(viewContext, controller.selectedIndex.value),
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
        border: Border(right: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(context, 0, 'Projeto', Icons.architecture_rounded),
                  _buildMenuItem(context, 1, 'Dashboard', Icons.dashboard_rounded),
                  _buildMenuItem(context, 2, 'Gestão de Fazendas', Icons.location_on_rounded),
                  _buildMenuItem(context, 3, 'Gestão de Silos', Icons.warehouse_rounded),
                  _buildMenuItem(context, 12, 'Gestão de Lotes', Icons.inventory_2_rounded),
                  _buildMenuItem(context, 13, 'Controle de Secagem', Icons.waves_rounded),
                  _buildMenuItem(context, 14, 'Processos Ativos', Icons.history_rounded),
                  _buildMenuItem(context, 15, 'Gestão de Clientes', Icons.people_alt_rounded),
                  _buildMenuItem(context, 4, 'Dispositivos', Icons.hub_rounded),
                  _buildMenuItem(context, 5, 'Notificações', Icons.notifications_rounded),
                  _buildMenuItem(context, 7, 'Gestão de Acesso', Icons.admin_panel_settings_rounded),
                  _buildMenuItem(context, 9, 'Smart Sense IA', Icons.psychology_rounded),
                  _buildMenuItem(context, 10, 'Simulador Interativo', Icons.science_rounded),
                  const Divider(),
                  _buildMenuItem(context, 11, 'Meu Perfil', Icons.person_rounded),
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
      padding: const EdgeInsets.all(24),
      child: Text('SMART SECAGEM', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: theme.primaryColor)),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index, String title, IconData icon) {
    final theme = Theme.of(context);
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? theme.primaryColor : Colors.grey),
          title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
          onTap: () {
            controller.changePage(index);
            if (!MediaQuery.of(context).size.width.isGreaterThan(1100)) Navigator.pop(context);
          },
        ),
      );
    });
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Sair', style: TextStyle(color: Colors.red)),
      onTap: controller.logout,
    );
  }

  Widget _buildContent(BuildContext context, int index) {
    switch (index) {
      case 0: return const SiloViewerView();
      case 1: return _buildDashboardContent(context);
      case 2: return const FarmManagementView();
      case 3: return const SiloManagementView();
      case 4: return const DevicesView();
      case 5: return const NotificationsView();
      case 6: return const SupportView();
      case 7: return const AccessManagementView();
      case 8: return const SettingsView();
      case 9: return const SmartSenseIAView();
      case 10: return const SimulationView();
      case 11: return const ProfileView();
      case 12: return const BatchManagementView();
      case 13: return const SecagemView();
      case 14: return const ProcessosView();
      case 15: return const ClientesView();
      default: return _buildDashboardContent(context);
    }
  }

  Widget _buildDashboardContent(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDesktop = MediaQuery.of(context).size.width >= 1100;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Column(
        children: [
          Row(
            children: [
              Text('Dashboard', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Obx(() => controller.isAnalyzing.value
                  ? const CircularProgressIndicator()
                  : IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.onInit())),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: isDesktop
                ? Row(children: [Expanded(flex: 2, child: _buildAISummaryCard(context)), const SizedBox(width: 24), Expanded(flex: 1, child: _buildAIChat(context))])
                : Column(children: [_buildAISummaryCard(context), const SizedBox(height: 24), Expanded(child: _buildAIChat(context))]),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
      child: Obx(() => Text(controller.aiSummary.value, style: const TextStyle(color: Colors.white, fontSize: 16))),
    );
  }

  Widget _buildAIChat(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Expanded(child: Obx(() => ListView.builder(itemCount: controller.chatMessages.length, itemBuilder: (c, i) => Text(controller.chatMessages[i]['text'])))),
          TextField(controller: controller.chatController, onSubmitted: controller.sendMessage),
        ],
      ),
    );
  }
}
