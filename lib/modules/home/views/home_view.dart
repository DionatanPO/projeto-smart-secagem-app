import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../settings/views/settings_view.dart';
import '../../access_management/views/access_management_view.dart';
import '../../silo_management/views/silo_management_view.dart';
import '../../devices/views/devices_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../support/views/support_view.dart';
import '../../smart_sense_ia/views/smart_sense_ia_view.dart';
import '../../profile/views/profile_view.dart';
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
      drawer: isDesktop ? null : _buildDrawer(context),
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

  NavigationDrawer _buildDrawer(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: controller.selectedIndex.value,
      onDestinationSelected: (index) {
        controller.changePage(index);
        Navigator.pop(context);
      },
      children: [
        _buildDrawerHeader(context),
        Obx(() => Column(
          children: _buildAllDestinations(context: context, useDrawer: true),
        )),
      ],
    );
  }

  Padding _buildDrawerHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text('Smart Secagem', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('Plataforma de Gestão', style: GoogleFonts.inter(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          _buildSidebarHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildAllDestinations(context: context),
              )),
            ),
          ),
          _buildSidebarFooter(context),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Secagem', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
              Text('Plataforma de Gestão', style: GoogleFonts.inter(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllDestinations({required BuildContext context, bool useDrawer = false}) {
    final sections = [
      ('Principal', [
        (0, 'Projeto', Icons.architecture_rounded),
      ]),
      ('Monitoramento', [
        (2, 'Fazendas', Icons.location_on_rounded),
        (3, 'Silos', Icons.warehouse_rounded),
        (12, 'Lotes', Icons.inventory_2_rounded),
        (13, 'Secagem', Icons.waves_rounded),
        (14, 'Processos', Icons.history_rounded),
        (15, 'Clientes', Icons.people_alt_rounded),
      ]),
      ('Sistema', [
        (4, 'Dispositivos', Icons.hub_rounded),
        (5, 'Notificações', Icons.notifications_rounded),
        (7, 'Acesso', Icons.admin_panel_settings_rounded),
      ]),
      ('Inteligência', [
        (1, 'Resumo IA', Icons.dashboard_rounded),
        (9, 'Smart Sense IA', Icons.psychology_rounded),
      ]),
    ];

    final destinations = <Widget>[];

    for (final section in sections) {
      final title = section.$1;
      final items = section.$2;

      if (useDrawer) {
        destinations.add(Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 4),
          child: Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
        ));
      } else {
        destinations.add(Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
          child: Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
        ));
      }

      for (final item in items) {
        final index = item.$1;
        final label = item.$2;
        final icon = item.$3;

        if (index == 7 && !controller.isAdmin) continue;

        if (useDrawer) {
          destinations.add(NavigationDrawerDestination(
            icon: Icon(icon),
            selectedIcon: Icon(icon, fill: 1),
            label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ));
        } else {
          destinations.add(_buildMenuItem(context, index, label, icon));
        }
      }
    }

    if (!useDrawer) {
      destinations.add(const SizedBox(height: 8));
      destinations.add(_buildMenuItem(context, 11, 'Meu Perfil', Icons.person_rounded));
    }

    return destinations;
  }

  Widget _buildMenuItem(BuildContext context, int index, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final color = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => controller.changePage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: color),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: color,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: controller.logout,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 22, color: colorScheme.error),
                const SizedBox(width: 12),
                Text('Sair', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.error)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, int index) {
    switch (index) {
      case 0: return const SiloViewerView();
      case 1: return const DashboardView();
      case 2: return const FarmManagementView();
      case 3: return const SiloManagementView();
      case 4: return const DevicesView();
      case 5: return const NotificationsView();
      case 6: return const SupportView();
      case 7: return controller.isAdmin ? const AccessManagementView() : const DashboardView();
      case 8: return const SettingsView();
      case 9: return const SmartSenseIAView();
      case 11: return const ProfileView();
      case 12: return const BatchManagementView();
      case 13: return const SecagemView();
      case 14: return const ProcessosView();
      case 15: return const ClientesView();
      default: return const DashboardView();
    }
  }

}
