import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';

import '../widgets/web_footer.dart';
import '../widgets/web_drawer.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const WebDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildMission(context),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
      ),
      child: Column(
        children: [
          Text(
            'NOSSA HISTÓRIA',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Text(
            'Inovando a forma como\nvocê gerencia o futuro.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildMission(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        children: [
          Text(
            'Nascemos da necessidade de simplificar o que é complexo. No Smart Secagem, nossa missão é democratizar o acesso a ferramentas de gestão de alta performance para produtores de todos os tamanhos.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 22, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('5+', 'Anos de Estrada'),
              const SizedBox(width: 40),
              _buildStat('500+', 'Clientes Ativos'),
              const SizedBox(width: 40),
              _buildStat('24/7', 'Suporte Especializado'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(val,
            style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary)),
      ],
    );
  }
}
