import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';

import '../widgets/web_footer.dart';
import '../widgets/web_drawer.dart';
import '../controllers/landing_controller.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LandingController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      drawer: isMobile ? const WebDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context, controller),
            _buildStats(context),
            _buildFeatures(context),
            _buildCTA(context, controller),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, LandingController controller) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceDark, AppColors.backgroundDark],
              )
            : AppColors.primaryGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -100,
            top: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.primary : Colors.white)
                    .withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : size.width * 0.1,
              vertical: isMobile ? 40 : 120,
            ),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'AERAÇÃO INTELIGENTE 2.0',
                              style: GoogleFonts.inter(
                                color:
                                    isDark ? AppColors.primary : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Proteja seu grão,\nguarde seu lucro.',
                        textAlign:
                            isMobile ? TextAlign.center : TextAlign.start,
                        style: GoogleFonts.outfit(
                          fontSize:
                              isMobile ? (size.width < 360 ? 32 : 42) : 72,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'O Smart Secagem utiliza algoritmos de equilíbrio higroscópico para automatizar sua aeração, garantindo a qualidade da massa e reduzindo custos de energia.',
                        textAlign:
                            isMobile ? TextAlign.center : TextAlign.start,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 18 : 22,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildPrimaryButton(
                              'Acessar Sistema', controller.accessSystem),
                          _buildSecondaryButton('Solicitar Orçamento', () {}),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isMobile) const SizedBox(width: 60),
                if (!isMobile)
                  Expanded(
                    flex: 1,
                    child: _buildHeroImage(isDark),
                  ),
                if (isMobile) const SizedBox(height: 60),
                if (isMobile) _buildHeroImage(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(bool isDark) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withOpacity(0.5)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.warehouse_rounded,
                size: 160,
                color: (isDark ? AppColors.primary : Colors.white)
                    .withOpacity(0.8),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.thermostat_rounded,
                            color: AppColors.success),
                        SizedBox(width: 8),
                        Text('Massa Estável',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 20 : size.width * 0.1,
      ),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: Wrap(
        spacing: 40,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _buildStatItem('30%', 'Economia de Energia', isDark),
          _buildStatItem('100%', 'Monitoramento Remoto', isDark),
          _buildStatItem('24h', 'Alertas de Hotspot', isDark),
          _buildStatItem('0%', 'Perda de Qualidade', isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: isDark ? AppColors.textMuted : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 120,
        horizontal: isMobile ? 20 : size.width * 0.1,
      ),
      child: Column(
        children: [
          Text(
            'TECNOLOGIA DE PONTA',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'O controle total do seu armazém\nna palma da sua mão.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeatureCard(
                    context,
                    Icons.psychology_rounded,
                    'Algoritmo Inteligente',
                    'Automação baseada em Ponto de Orvalho e Delta T para uma aeração técnica e precisa.',
                    isDark,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.notifications_active_rounded,
                    'Alertas em Real-Time',
                    'Receba notificações imediatas no seu celular sobre qualquer variação térmica anormal.',
                    isDark,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.settings_remote_rounded,
                    'Controle Remoto',
                    'Ligue ou desligue exaustores e aeradores de qualquer lugar do mundo via internet.',
                    isDark,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.battery_saver_rounded,
                    'Eficiência Energética',
                    'Redução drástica no consumo de energia ao operar apenas nos horários de clima favorável.',
                    isDark,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.layers_rounded,
                    'Visão Multi-camada',
                    'Monitore o topo, meio e base do silo de forma independente para detectar focos internos.',
                    isDark,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.history_edu_rounded,
                    'Histórico e Laudos',
                    'Gere laudos técnicos de conservação e histórico térmico para valorizar seu produto.',
                    isDark,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title,
      String description, bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      width: isMobile ? double.infinity : 380,
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context, LandingController controller) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 20 : size.width * 0.1,
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 80),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceDark, AppColors.backgroundDark],
              )
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppColors.glow,
      ),
      child: Column(
        children: [
          Text(
            'Pronto para modernizar seu pós-colheita?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Junte-se aos produtores que já utilizam o Smart Secagem para garantir a máxima qualidade.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 48),
          _buildPrimaryButton('Acessar Painel Agora', controller.accessSystem),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(220, 64),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24, width: 2),
        minimumSize: const Size(220, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
