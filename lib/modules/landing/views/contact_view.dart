import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';

import '../widgets/web_footer.dart';
import '../widgets/web_drawer.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const WebDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildContactForm(context),
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
            'FALE CONOSCO',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          Text(
            'Estamos aqui para ajudar.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactInfo('E-mail', 'suporte@smartsecagem.com',
                      Icons.email_rounded),
                  _buildContactInfo(
                      'Telefone', '+55 (11) 99999-9999', Icons.phone_rounded),
                  _buildContactInfo('Endereço', 'Av. Paulista, 1000 - SP',
                      Icons.location_on_rounded),
                ],
              ),
            ),
          const SizedBox(width: 80),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Envie uma mensagem',
                      style: GoogleFonts.outfit(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  _buildField('Seu Nome', 'Ex: João Silva'),
                  _buildField('E-mail Profissional', 'Ex: joao@empresa.com'),
                  _buildField('Mensagem', 'Como podemos ajudar?', maxLines: 5),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60)),
                    child: const Text('Enviar Mensagem'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String title, String val, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text(val,
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: maxLines,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}
