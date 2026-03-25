import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import '../../../routes/app_routes.dart';

class WebNavBar extends StatelessWidget {
  const WebNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            padding:
                EdgeInsets.symmetric(horizontal: isMobile ? 20 : width * 0.1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              border: Border(
                bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                // Logo
                InkWell(
                  onTap: () {
                    if (Get.currentRoute != Routes.landing) {
                      Get.offAllNamed(Routes.landing);
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome_mosaic_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'MODELO',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                if (!isMobile)
                  Row(
                    children: [
                      _buildNavItem('Início', Routes.landing),
                      _buildNavItem('Funcionalidades', Routes.features),
                      _buildNavItem('Preços', Routes.pricing),
                      _buildNavItem('Sobre', Routes.about),
                      _buildNavItem('Contato', Routes.contact),
                      const SizedBox(width: 32),
                    ],
                  ),

                if (!isMobile)
                  ElevatedButton(
                    onPressed: () {
                      if (Get.currentRoute != Routes.login) {
                        Get.toNamed(Routes.login);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Área Restrita',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                if (isMobile)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded,
                            color: AppColors.primary),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, String route) {
    final bool isSelected = Get.currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            Get.toNamed(route);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
