import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 80,
          horizontal: isMobile ? 20 : width * 0.1,
        ),
        color: AppColors.primaryDark,
        child: Column(
          children: [
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.start,
              children: [
                // Brand section
                SizedBox(
                  width: isMobile ? double.infinity : 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.auto_awesome_mosaic_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A plataforma definitiva para produtores que buscam transformar seu pós-colheita com tecnologia e automação.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMobile) const SizedBox(height: 40),
                // Links sections
                Wrap(
                  spacing: isMobile ? 30 : 60,
                  runSpacing: 40,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    _buildFooterColumn('PRODUTO',
                        ['Funcionalidades', 'Preços', 'Segurança', 'Roadmap']),
                    _buildFooterColumn('EMPRESA',
                        ['Sobre Nós', 'Carreiras', 'Blog', 'Imprensa']),
                    _buildFooterColumn(
                        'SUPORTE', ['Documentação', 'Guia', 'Contato', 'FAQ']),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 80),
            const Divider(color: Colors.white10),
            const SizedBox(height: 40),
            isMobile
                ? Column(
                    children: [
                      _buildSocialIcons(),
                      const SizedBox(height: 24),
                      _buildCopyrightText(),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildCopyrightText()),
                      _buildSocialIcons(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyrightText() {
    return Text(
      '© 2026 Smart Secagem. Todos os direitos reservados.',
      textAlign: TextAlign.start,
      style: GoogleFonts.inter(
        color: Colors.white.withOpacity(0.4),
        fontSize: 14,
      ),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSocialIcon(Icons.facebook),
        const SizedBox(width: 16),
        _buildSocialIcon(Icons.camera_alt_rounded),
        const SizedBox(width: 16),
        _buildSocialIcon(Icons.alternate_email_rounded),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {},
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
