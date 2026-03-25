import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/app_colors.dart';
import 'widgets/network_architecture_diagram.dart';

class SiloViewerView extends StatelessWidget {
  const SiloViewerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Projeto do Silo',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      height: 48,
                      width: 540, // Increased width to accommodate 4 tabs
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border.withOpacity(0.5),
                        ),
                      ),
                      child: TabBar(
                        indicatorColor: AppColors.primary,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        labelColor: AppColors.primary,
                        unselectedLabelColor:
                            isDark ? Colors.white70 : Colors.black54,
                        tabs: const [
                          Tab(text: 'Informações'),
                          Tab(text: 'Etapas'),
                          Tab(text: 'Modelo 3D'),
                          Tab(text: 'Conectividade'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Acompanhe as fases, diretrizes e a infraestrutura tecnológica do projeto.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color:
                        isDark ? AppColors.textMuted : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(context),
            _buildStagesTab(context),
            _build3DTab(context),
            _buildConnectivityTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= 1100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Description Card - High Impact Hero Section
          _buildHeroSection(
            context,
            'Descrição do Projeto',
            'O Smart Secagem redefine o armazenamento de grãos através da convergência entre termometria digital e inteligência artificial. Nosso compromisso é transformar simples silos em centros de dados inteligentes, garantindo a integridade da safra com precisão cirúrgica.',
            Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 32),
          
          // Responsive Grid for Strategic Cards
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildGlassCard(
                    context,
                    'Objetivo Estratégico',
                    'Implementar monitoramento 24/7 para neutralizar riscos de deterioração e maximizar a rentabilidade operacional.',
                    Icons.api_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildGlassCard(
                    context,
                    'Metodologia Técnica',
                    'Integração de sensores LoRaWAN inteligentes e modelos preditivos de equilíbrio higroscópico em tempo real.',
                    Icons.layers_rounded,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildGlassCard(
                    context,
                    'Impacto Mensurável',
                    'Alcançar excelência na secagem com redução drástica no consumo energético e perdas de massa.',
                    Icons.bolt_rounded,
                    Colors.green,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildGlassCard(
                  context,
                  'Objetivo Estratégico',
                  'Implementar monitoramento 24/7 para neutralizar riscos de deterioração e maximizar a rentabilidade operacional.',
                  Icons.api_rounded,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildGlassCard(
                  context,
                  'Metodologia Técnica',
                  'Integração de sensores LoRaWAN inteligentes e modelos preditivos de equilíbrio higroscópico em tempo real.',
                  Icons.layers_rounded,
                  Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildGlassCard(
                  context,
                  'Impacto Mensurável',
                  'Alcançar excelência na secagem com redução drástica no consumo energético e perdas de massa.',
                  Icons.bolt_rounded,
                  Colors.green,
                ),
              ],
            ),
          const SizedBox(height: 32),
          _buildExtraInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildStagesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStageItem(
            context,
            'FASE 01',
            'Planejamento Estratégico',
            'Definição dos KPIs de secagem, análise de infraestrutura local e mapeamento de zonas críticas do silo para posicionamento dos sensores.',
            'Concluído',
            true,
            true,
            false,
          ),
          _buildStageItem(
            context,
            'FASE 02',
            'Hardware & Conectividade',
            'Instalação dos cabos termométricos de alta precisão e configuração do Gateway LoRaWAN industrial para comunicação sem fio.',
            'Em Andamento',
            false,
            true,
            false,
          ),
          _buildStageItem(
            context,
            'FASE 03',
            'Integração Smart Sense IA',
            'Treinamento dos modelos de Machine Learning com dados históricos e calibração dos algoritmos de IA para detecção de anomalias.',
            'Pendente',
            false,
            false,
            false,
          ),
          _buildStageItem(
            context,
            'FASE 04',
            'Operação & Certificação',
            'Teste final de estresse, treinamento da equipe operacional e entrega técnica com o selo de conformidade Smart Secagem.',
            'Pendente',
            false,
            false,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildStageItem(
    BuildContext context,
    String step,
    String title,
    String description,
    String status,
    bool isCompleted,
    bool isActive,
    bool isLast,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isCompleted
        ? AppColors.primary
        : (isActive ? Colors.orange : AppColors.textMuted);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Marker
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : (isDark ? AppColors.surfaceDark : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withOpacity(0.5),
                      width: isCompleted ? 0 : 2,
                    ),
                    boxShadow: [
                      if (isCompleted || isActive)
                        BoxShadow(
                          color: accentColor.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : (isActive
                            ? Icons.sync_rounded
                            : Icons.lock_outline_rounded),
                    color: isCompleted ? Colors.white : accentColor,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accentColor.withOpacity(0.5),
                            AppColors.border.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Stage Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive
                      ? accentColor.withOpacity(0.4)
                      : (isDark
                          ? AppColors.borderDark
                          : AppColors.border.withOpacity(0.3)),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: accentColor.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  if (!isDark && !isActive)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(
              icon,
              size: 200,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Visão Geral',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Text(
                    content,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, String title, String content, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: isDark ? AppColors.textMuted : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraInfoSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primary.withOpacity(0.05) : AppColors.primary.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Este silo utiliza a tecnologia de sensores IoT de 4ª geração com blindagem magnética e comunicação criptografada.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.border.withOpacity(0.5),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ModelViewer(
                  backgroundColor: isDark
                      ? const Color(0xFF1A1C1E)
                      : const Color(0xFFEEF2F6),
                  src: kIsWeb ? 'assets/silo3d.glb' : 'assets/silo3d.glb',
                  alt: 'Modelo 3D do Silo',
                  ar: true,
                  autoRotate: true,
                  cameraControls: true,
                  shadowIntensity: 1,
                  exposure: 0.5,
                  environmentImage: 'neutral',
                  interactionPrompt: InteractionPrompt.auto,
                  cameraOrbit: '30deg 65deg 1%',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInteractiveTips(context),
        ],
      ),
    );
  }

  Widget _buildConnectivityTab(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: NetworkArchitectureDiagram(),
    );
  }

  Widget _buildInteractiveTips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _buildTip(
          context,
          Icons.touch_app_rounded,
          'Arraste para girar',
          isDark,
        ),
        const SizedBox(width: 24),
        _buildTip(
          context,
          Icons.zoom_in_rounded,
          'Pinça para zoom',
          isDark,
        ),
        const SizedBox(width: 24),
        _buildTip(
          context,
          Icons.view_in_ar_rounded,
          'Suporte a RA',
          isDark,
        ),
      ],
    );
  }

  Widget _buildTip(
      BuildContext context, IconData icon, String label, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textMuted : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
