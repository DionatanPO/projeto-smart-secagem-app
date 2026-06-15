import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../core/values/app_colors.dart';

import '../widgets/web_footer.dart';
import '../widgets/web_drawer.dart';
import '../controllers/landing_controller.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  static final _featuresKey = GlobalKey();

  void _scrollToFeatures() {
    final context = _featuresKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Text(
              'Carregando...',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(context, controller),
              _buildFeatures(context),
              _buildCTA(context, controller),
              const WebFooter(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHero(BuildContext context, LandingController controller) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        children: [
          // Background Video - full screen
          Positioned.fill(
            child: Obx(() {
              if (controller.isVideoInitialized.value && !controller.hasVideoError.value) {
                return ClipRRect(
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.videoController.value.size.width,
                        height: controller.videoController.value.size.height,
                        child: VideoPlayer(controller.videoController),
                      ),
                    ),
                  ),
                );
              }
              return Container(color: Colors.black);
            }),
          ),
          // Gradient Overlay for Readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Content Overlay - centered
          Center(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : size.width * 0.1,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'SMART SECAGEM',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: isMobile ? double.infinity : size.width * 0.7,
                      child: Text(
                        'A inteligência que seu grão precisa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: isMobile ? (size.width < 360 ? 36 : 48) : 84,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.05,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: isMobile ? double.infinity : size.width * 0.55,
                      child: Text(
                        'Otimize sua aeração com algoritmos avançados. Reduza perdas, economize energia e garanta a qualidade máxima da sua safra.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 18 : 22,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 54),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 24,
                      runSpacing: 20,
                      children: [
                        _buildPrimaryButton(
                            'Acessar Sistema', controller.accessSystem),
                        _buildSecondaryButton('Conhecer Soluções', _scrollToFeatures),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildFeatures(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      key: _featuresKey,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 120,
        horizontal: isMobile ? 20 : size.width * 0.1,
      ),
      child: Column(
        children: [
          Text(
            'TECNOLOGIA DE PONTA',
            style: TextStyle(
              fontFamily: 'Outfit',
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
            style: TextStyle(
              fontFamily: 'Outfit',
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
      padding: EdgeInsets.all(isMobile ? 32 : 40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.border.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.04),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              height: 1.7,
              fontWeight: FontWeight.w400,
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
        vertical: isMobile ? 60 : 120,
        horizontal: isMobile ? 24 : size.width * 0.08,
      ),
      padding: EdgeInsets.all(isMobile ? 40 : 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.primaryDark, AppColors.surfaceDark]
              : [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -50,
            child: Icon(
              Icons.agriculture_rounded,
              size: 200,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Column(
            children: [
              Text(
                'Pronto para modernizar seu pós-colheita?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: isMobile ? 36 : 56,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Junte-se aos produtores que já utilizam a inteligência artificial para garantir a máxima qualidade e lucratividade.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 18 : 22,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 54),
              _buildPrimaryButton(
                  'Acessar Painel Agora', controller.accessSystem),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size(260, 72),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
          minimumSize: const Size(240, 72),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
