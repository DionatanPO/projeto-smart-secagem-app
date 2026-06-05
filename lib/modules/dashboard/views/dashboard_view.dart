import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/values/app_colors.dart';

class RespostaIA extends StatelessWidget {
  final String resposta;

  const RespostaIA({super.key, required this.resposta});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: MarkdownBody(
        data: resposta,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.inter(
            fontSize: 14,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          pPadding: const EdgeInsets.only(bottom: 8),
          strong: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          em: GoogleFonts.inter(
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          h1: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          h2: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          h3: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          listBullet: GoogleFonts.inter(
            color: AppColors.primary,
            fontSize: 14,
          ),
          listBulletPadding: const EdgeInsets.only(right: 6),
          listIndent: 20,
          code: GoogleFonts.robotoMono(
            fontSize: 13,
            backgroundColor: isDark ? Colors.black45 : Colors.grey[200],
            color: AppColors.primary,
          ),
          codeblockPadding: const EdgeInsets.all(12),
          codeblockDecoration: BoxDecoration(
            color: isDark ? Colors.black45 : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          a: GoogleFonts.inter(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
          blockquote: GoogleFonts.inter(
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppColors.primary.withOpacity(0.5),
                width: 3,
              ),
            ),
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1,
              ),
            ),
          ),
          blockSpacing: 10,
        ),
        checkboxBuilder: (bool value) {
          return Transform.scale(
            scale: 0.8,
            child: Checkbox(
              value: value,
              onChanged: null,
              activeColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }
}

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo IA'),
        actions: [
          Obx(() => controller.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refresh,
                  tooltip: 'Atualizar',
                )),
        ],
      ),
      body: Obx(() => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return switch (controller.status.value) {
      DashboardStatus.loading => _buildLoading(),
      DashboardStatus.error   => _buildError(context),
      DashboardStatus.success => _buildContent(context),
      DashboardStatus.idle    => const SizedBox.shrink(),
    };
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Consultando o modelo...'),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48,
                color: isDark ? Colors.white38 : Colors.red),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(), // Corrigido para async
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMetaInfo(context),
          const SizedBox(height: 16),
          // Acessando a propriedade resposta do modelo tipado
          if (controller.modelResponse.value != null)
            RespostaIA(resposta: controller.modelResponse.value!.resposta),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white38 : Colors.black45;
    final updated = controller.lastUpdated.value;

    return Row(
      children: [
        Icon(Icons.schedule, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          updated != null
              ? 'Atualizado às ${_formatTime(updated)}'
              : 'Carregando...',
          style: GoogleFonts.inter(fontSize: 12, color: color),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          color: color,
          tooltip: 'Baixar PDF',
          // Corrigido: passando string do modelo ou vazio
          onPressed: () => PdfService().generateDashboardPdf(
            controller.modelResponse.value?.resposta ?? '', 
            updated
          ),
        ),
        Icon(Icons.speed, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          controller.responseTime.value,
          style: GoogleFonts.inter(fontSize: 12, color: color),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
