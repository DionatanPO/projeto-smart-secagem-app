import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/services/pdf_service.dart';

class RespostaIA extends StatelessWidget {
  final String resposta;

  const RespostaIA({super.key, required this.resposta});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: MarkdownBody(
        data: resposta,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
          h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
          h3: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor.withOpacity(0.85)),
          p: const TextStyle(fontSize: 14.5, height: 1.6),
          pPadding: const EdgeInsets.only(bottom: 8),
          strong: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          em: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.onSurface.withOpacity(0.75)),
          listBullet: TextStyle(fontSize: 14.5, color: primaryColor),
          listBulletPadding: const EdgeInsets.only(right: 6),
          listIndent: 20,
          code: TextStyle(fontFamily: 'monospace', fontSize: 13, backgroundColor: colorScheme.surfaceContainerHighest, color: colorScheme.error),
          codeblockPadding: const EdgeInsets.all(12),
          codeblockDecoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
          horizontalRuleDecoration: BoxDecoration(border: Border(top: BorderSide(color: primaryColor.withOpacity(0.3), width: 1.5))),
          blockSpacing: 10,
        ),
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
        title: const Text('Dashboard'),
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
      DashboardStatus.error   => _buildError(),
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
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
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMetaInfo(context),
          const SizedBox(height: 12),
          RespostaIA(resposta: controller.modelResponse.value),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    final updated = controller.lastUpdated.value;

    return Row(
      children: [
        Icon(Icons.schedule, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          updated != null
              ? 'Atualizado às ${_formatTime(updated)}'
              : 'Carregando...',
          style: TextStyle(fontSize: 12, color: color),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          color: color,
          tooltip: 'Baixar PDF',
          onPressed: () => PdfService().generateDashboardPdf(controller.modelResponse.value, updated),
        ),
        Icon(Icons.speed, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          controller.responseTime.value,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
