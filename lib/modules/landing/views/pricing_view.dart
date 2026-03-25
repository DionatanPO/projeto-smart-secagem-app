import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';

import '../widgets/web_footer.dart';
import '../widgets/web_drawer.dart';

class PricingView extends StatelessWidget {
  const PricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const WebDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildPricingCards(context),
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
      child: Column(
        children: [
          Text(
            'Escolha o plano ideal para você',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            'Sem taxas escondidas. Cancele a qualquer momento.',
            style:
                GoogleFonts.inter(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Wrap(
        spacing: 30,
        runSpacing: 30,
        alignment: WrapAlignment.center,
        children: [
          _buildCard('Básico', 'R\$ 99', 'Ideal para iniciantes', [
            'Gerenciamento de Usuários',
            'Relatórios Básicos',
            'Suporte por E-mail'
          ]),
          _buildCard(
              'Pro',
              'R\$ 249',
              'O mais popular',
              [
                'Tudo do Básico',
                'Dashboard Avançado',
                'Integração Bancária',
                'Suporte 24/7'
              ],
              isFeatured: true),
          _buildCard('Enterprise', 'Custom', 'Para grandes operações', [
            'Tudo do Pro',
            'Customizações Exclusivas',
            'Gerente de Contas',
            'SLA Garantido'
          ]),
        ],
      ),
    );
  }

  Widget _buildCard(
      String title, String price, String subtitle, List<String> features,
      {bool isFeatured = false}) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isFeatured ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: isFeatured ? AppColors.primary : AppColors.border),
        boxShadow: isFeatured
            ? [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isFeatured ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 12),
          Text(price,
              style: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: isFeatured ? Colors.white : AppColors.textPrimary)),
          Text(subtitle,
              style: GoogleFonts.inter(
                  color:
                      isFeatured ? Colors.white70 : AppColors.textSecondary)),
          const SizedBox(height: 32),
          const Divider(color: Colors.white12),
          const SizedBox(height: 32),
          ...features
              .map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color:
                                isFeatured ? Colors.white : AppColors.primary,
                            size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(f,
                                style: GoogleFonts.inter(
                                    color: isFeatured
                                        ? Colors.white
                                        : AppColors.textPrimary))),
                      ],
                    ),
                  ))
              .toList(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isFeatured ? Colors.white : AppColors.primary,
              foregroundColor: isFeatured ? AppColors.primary : Colors.white,
              minimumSize: const Size(double.infinity, 54),
            ),
            child: const Text('Selecionar Plano'),
          ),
        ],
      ),
    );
  }
}
