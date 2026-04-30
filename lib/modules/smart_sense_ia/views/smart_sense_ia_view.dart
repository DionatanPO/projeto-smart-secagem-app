import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/smart_sense_ia_controller.dart';

class SmartSenseIAView extends GetView<SmartSenseIAController> {
  const SmartSenseIAView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SmartSenseIAController>()) {
      Get.put(SmartSenseIAController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(builder: (headerContext) => _buildHeader(headerContext, isDesktop, theme)),
            const SizedBox(height: 32),
            
            // Grid principal para Desktop, Coluna para Mobile
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildActionCard(isDark),
                        const SizedBox(height: 24),
                        _buildDataPreviewCard(isDark),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 3,
                    child: _buildAIResponseCard(isDark),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildActionCard(isDark),
                  const SizedBox(height: 24),
                  _buildAIResponseCard(isDark),
                  const SizedBox(height: 24),
                  _buildDataPreviewCard(isDark),
                ],
              ),
              
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel(bool isDark) {
    return Column(
      children: [
        _buildSiloSelector(isDark),
        const SizedBox(height: 24),
        _buildActionCard(isDark),
      ],
    );
  }

  Widget _buildRightPanel(bool isDark) {
    return Column(
      children: [
        _buildDataPreviewCard(isDark),
        const SizedBox(height: 24),
        _buildAIResponseCard(isDark),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop, ThemeData theme) {
    return Row(
      children: [
        if (!isDesktop) ...[
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
            color: theme.primaryColor,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'GEMINI 3.0 FLASH ACTIVE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Silo Sense IA',
                  style: GoogleFonts.outfit(
                    fontSize: isDesktop ? 32 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSiloSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UNIDADE DE ANÁLISE',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                  color: isDark ? Colors.black.withOpacity(0.2) : AppColors.background.withOpacity(0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.selectedSilo.value?.id,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                    items: controller.silos.map((silo) {
                      return DropdownMenuItem<int>(
                        value: silo.id,
                        child: Text(
                          '${silo.name} • ${silo.productType}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedSilo.value = controller.silos.firstWhere((s) => s.id == val);
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: AssetImage('assets/images/hero_tractor.png'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withBlue(200),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Diagnóstico Preditivo',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Inicie uma varredura profunda nos sensores usando redes neurais para detectar riscos invisíveis.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Obx(() => ElevatedButton(
                onPressed: controller.isProcessing.value ? null : controller.runDiagnosis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: controller.isProcessing.value
                    ? const _LoadingBrain()
                    : Text(
                        'INICIAR ANÁLISE',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
              )),
        ],
      ),
    );
  }

  Widget _buildDataPreviewCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'CRITÉRIOS DE DIAGNÓSTICO',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDataPoint(
            Icons.thermostat_rounded, 
            'Tendência Térmica', 
            'Variação de temperatura nas últimas 10 coletas para detectar focos de calor.',
            isDark
          ),
          const Divider(height: 32),
          _buildDataPoint(
            Icons.water_drop_rounded, 
            'Equilíbrio Higroscópico', 
            'Relação entre umidade e temperatura para prever o ponto de condensação.',
            isDark
          ),
          const Divider(height: 32),
          _buildDataPoint(
            Icons.inventory_2_rounded, 
            'Especificidade do Grão', 
            'A IA ajusta os limites de alerta baseada no tipo de produto (Soja, Milho, etc).',
            isDark
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Estes dados são extraídos em tempo real dos seus sensores e processados pelo motor Gemini.',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPoint(IconData icon, String title, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIResponseCard(bool isDark) {
    return Obx(() {
      if (controller.aiInsight.value.isEmpty && !controller.isProcessing.value) {
        return _buildEmptyState(isDark);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark 
                ? AppColors.primary.withOpacity(0.05) 
                : AppColors.primary.withOpacity(0.02),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _PulseIcon(),
                    const SizedBox(width: 16),
                    Text(
                      'INSIGHT DO GEMINI',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (controller.isProcessing.value)
                  const _AIThinkingPlaceholder()
                else
                  SelectionArea(
                    child: Text(
                      controller.aiInsight.value,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimary,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                if (!controller.isProcessing.value)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Análise concluída com sucesso',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.green),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withOpacity(0.5) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.3), style: BorderStyle.none),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.psychology_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Aguardando comando...',
              style: GoogleFonts.inter(color: Colors.grey.withOpacity(0.6), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  const _PulseIcon();

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1 + (_controller.value * 0.2)),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3 * _controller.value),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
        );
      },
    );
  }
}

class _LoadingBrain extends StatelessWidget {
  const _LoadingBrain();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Text('Sincronizando Neurônios...', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AIThinkingPlaceholder extends StatelessWidget {
  const _AIThinkingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerLine(double.infinity),
        const SizedBox(height: 12),
        _buildShimmerLine(double.infinity),
        const SizedBox(height: 12),
        _buildShimmerLine(200),
      ],
    );
  }

  Widget _buildShimmerLine(double width) {
    return Container(
      height: 14,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}
