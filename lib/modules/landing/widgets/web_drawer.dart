import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/landing_controller.dart';

class WebDrawer extends StatelessWidget {
  const WebDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LandingController>();

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_mosaic_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  'Smart Secagem',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Aeração Inteligente',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerItem('Início', Icons.home_rounded, Routes.landing),
                _buildDrawerItem('Funcionalidades', Icons.extension_rounded,
                    Routes.features),
                _buildDrawerItem('Preços', Icons.sell_rounded, Routes.pricing),
                _buildDrawerItem('Sobre Nós', Icons.info_rounded, Routes.about),
                _buildDrawerItem(
                    'Contato', Icons.contact_support_rounded, Routes.contact),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: Divider(),
                ),
                _buildDrawerItem('Área Restrita', Icons.lock_person_rounded, '',
                    isSpecial: true, onTap: () {
                  Get.back(); // Fecha o drawer
                  controller.accessSystem();
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'v2.0.0 Stable',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String label, IconData icon, String route,
      {bool isSpecial = false, VoidCallback? onTap}) {
    final bool isSelected = Get.currentRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSpecial
              ? AppColors.primary
              : (isSelected ? AppColors.primary : AppColors.textSecondary),
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight:
                isSelected || isSpecial ? FontWeight.w700 : FontWeight.w500,
            color: isSpecial
                ? AppColors.primary
                : (isSelected ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap ??
            () {
              Get.back();
              Get.toNamed(route);
            },
      ),
    );
  }
}
