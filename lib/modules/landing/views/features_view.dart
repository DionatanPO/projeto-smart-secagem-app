import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';

import '../widgets/web_footer.dart';
import '../widgets/web_drawer.dart';

class FeaturesView extends StatelessWidget {
  const FeaturesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const WebDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFeatureList(context),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(color: AppColors.background),
      child: Column(
        children: [
          Text(
            'FUNCIONALIDADES',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Poder real para o seu negócio.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          _buildFeatureItem(
            context,
            'Painel de Controle Inteligente',
            'Visualize todos os seus dados em tempo real com gráficos interativos e relatórios automatizados.',
            Icons.analytics_rounded,
            true,
          ),
          _buildFeatureItem(
            context,
            'Gestão de Usuários e Permissões',
            'Controle quem acessa o quê com um sistema de hierarquia robusto e seguro.',
            Icons.admin_panel_settings_rounded,
            false,
          ),
          _buildFeatureItem(
            context,
            'Integração Financeira Completa',
            'Gerencie fluxos de caixa, faturamento e pagamentos em uma única interface.',
            Icons.account_balance_rounded,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String title, String desc,
      IconData icon, bool imageRight) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final List<Widget> children = [
      Expanded(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 48),
            const SizedBox(height: 24),
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(desc,
                style: GoogleFonts.inter(
                    fontSize: 18, color: AppColors.textSecondary, height: 1.6)),
          ],
        ),
      ),
      const SizedBox(width: 80, height: 40),
      Expanded(
        flex: 1,
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, size: 80, color: AppColors.textMuted),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: isMobile
          ? Column(
              children: [children[0], const SizedBox(height: 40), children[2]])
          : Row(children: imageRight ? children : children.reversed.toList()),
    );
  }
}
