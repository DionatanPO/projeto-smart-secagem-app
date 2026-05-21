import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isDesktop ? 32.0 : 16.0),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0),
            child: Builder(
              builder: (headerContext) =>
                  _buildHeader(headerContext, isDesktop, theme),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.0 : 16.0,
                vertical: 8.0,
              ),
              child: _buildChatInterface(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDesktop, ThemeData theme) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'SENSE AI ACTIVE',
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
                  style: (isDesktop
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.titleLarge)
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatInterface(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header do chat ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.border.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.psychology_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SENSE CHAT IA',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Online - Consultando Base de Dados',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Lista de mensagens ──────────────────────────────────────
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.chatMessages[index];
                    return _buildChatBubble(
                        msg['isUser'] as bool, msg['text'] as String, isDark);
                  },
                )),
          ),

          // ── Indicador de carregamento ───────────────────────────────
          Obx(() => controller.isChatLoading.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: _LoadingIndicator(),
                )
              : const SizedBox.shrink()),

          // ── Input de mensagem ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.border.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.chatInputController,
                    decoration: InputDecoration(
                      hintText: 'Pergunte sobre sensores, lotes...',
                      hintStyle: GoogleFonts.inter(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.black26
                          : Colors.grey.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: controller.sendMessage,
                  icon: const Icon(Icons.send_rounded,
                      color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Widget de bolha de chat COM suporte a Markdown
  Widget _buildChatBubble(bool isUser, String text, bool isDark) {
    // Limpeza básica do texto (remove quebras excessivas)
    final cleanText = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : (isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: isUser
            ? Text(
                cleanText,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              )
            : MarkdownBody(
                data: cleanText,
                selectable: true,
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet(
                  // Parágrafo base
                  p: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  // Negrito
                  strong: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  // Itálico
                  em: GoogleFonts.inter(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  // Títulos
                  h1: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  h2: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  h3: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  // Listas
                  listBullet: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                  // Código inline
                  code: GoogleFonts.robotoMono(
                    fontSize: 12,
                    backgroundColor: isDark ? Colors.black45 : Colors.grey[200],
                    color: AppColors.primary,
                  ),
                  // Blocos de código
                  codeblockDecoration: BoxDecoration(
                    color: isDark ? Colors.black45 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Links
                  a: GoogleFonts.inter(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  // Citação
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
                  // Separador horizontal
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Customização de checkboxes se a IA retornar listas de tarefas
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
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          'Consultando IA...',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary),
        ),
      ],
    );
  }
}