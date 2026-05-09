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
            Obx(() => Stack(
              children: [
                Column(
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
                            flex: 3,
                            child: _buildChatInterface(isDark),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildActionCard(isDark),
                                const SizedBox(height: 24),
                                _buildAIResponseCard(isDark),
                              ],
                            ),
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
                          _buildChatInterface(isDark),
                        ],
                      ),
                      
                    const SizedBox(height: 100),
                  ],
                ),
                if (controller.isProcessing.value)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: _ScanningOverlay(),
                    ),
                  ),
              ],
            )),
          ],
        ),
      ),
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
                      ?.copyWith(
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
                          silo.name,
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


  Widget _buildAIResponseCard(bool isDark) {
    return Obx(() {
      if (controller.aiInsight.value.isEmpty && !controller.isProcessing.value) {
        return _buildEmptyState(isDark);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark 
                ? AppColors.primary.withOpacity(0.05) 
                : AppColors.primary.withOpacity(0.02),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: controller.isProcessing.value 
                    ? AppColors.primary.withOpacity(0.5) 
                    : AppColors.primary.withOpacity(0.2),
                width: controller.isProcessing.value ? 2.5 : 1.5,
              ),
              boxShadow: controller.isProcessing.value ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ] : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const _PulseIcon(),
                        const SizedBox(width: 16),
                        Text(
                          'INSIGHT DA IA LOCAL',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (controller.isProcessing.value)
                      const _ProcessingTag(),
                  ],
                ),
                const SizedBox(height: 24),
                if (controller.isProcessing.value)
                  const _AIProcessingVisualizer()
                else
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: SelectionArea(
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

  Widget _buildChatInterface(bool isDark) {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5)),
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
          // Header do Chat
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SENSE CHAT IA',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Online - Consultando Base de Dados',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de Mensagens
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: controller.chatMessages.length,
              itemBuilder: (context, index) {
                final msg = controller.chatMessages[index];
                return _buildChatBubble(msg['isUser'], msg['text'], isDark);
              },
            )),
          ),

          if (controller.isChatLoading.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: _LoadingBrain(),
            ),

          // Input de Mensagem
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border.withOpacity(0.5))),
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
                      fillColor: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: controller.sendMessage,
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isUser, String text, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: Get.width * 0.6),
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
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: isUser ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            fontSize: 13,
          ),
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

class _LoadingBrain extends GetView<SmartSenseIAController> {
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
        Obx(() => Text(
          controller.processingStep.value.isEmpty 
              ? 'Sincronizando Neurônios...' 
              : controller.processingStep.value, 
          style: GoogleFonts.inter(fontWeight: FontWeight.bold)
        )),
      ],
    );
  }
}

class _ProcessingTag extends StatelessWidget {
  const _ProcessingTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Text(
            'PROCESSANDO',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIProcessingVisualizer extends StatelessWidget {
  const _AIProcessingVisualizer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _NeuralNetworkVisualizer(),
        const SizedBox(height: 32),
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

class _NeuralNetworkVisualizer extends StatefulWidget {
  const _NeuralNetworkVisualizer();

  @override
  State<_NeuralNetworkVisualizer> createState() => _NeuralNetworkVisualizerState();
}

class _NeuralNetworkVisualizerState extends State<_NeuralNetworkVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: _NeuralNetworkPainter(_controller),
      ),
    );
  }
}

class _NeuralNetworkPainter extends CustomPainter {
  final Animation<double> animation;
  _NeuralNetworkPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    const nodesCount = 12;
    final nodes = List.generate(nodesCount, (i) {
      double x = (size.width / (nodesCount / 2)) * (i % (nodesCount ~/ 2)) + 30;
      double y = (i < nodesCount / 2) ? 30.0 : 90.0;
      return Offset(x, y);
    });

    // Draw connections
    for (int i = 0; i < nodesCount / 2; i++) {
      for (int j = nodesCount ~/ 2; j < nodesCount; j++) {
        // Pulse effect
        double distance = (animation.value * size.width);
        double opacity = 0.1;
        if ((nodes[i].dx - distance).abs() < 50) {
          opacity = 0.5;
        }

        canvas.drawLine(
          nodes[i], 
          nodes[j], 
          paint..color = AppColors.primary.withOpacity(opacity)
        );
      }
    }

    // Draw nodes
    for (var node in nodes) {
      canvas.drawCircle(node, 4, dotPaint);
      canvas.drawCircle(node, 8, dotPaint..color = AppColors.primary.withOpacity(0.2));
    }
    
    // Draw scanning line
    final scanX = animation.value * size.width;
    canvas.drawLine(
      Offset(scanX, 0), 
      Offset(scanX, size.height), 
      Paint()..color = AppColors.primary.withOpacity(0.5)..strokeWidth = 2
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ScanningOverlay extends StatefulWidget {
  const _ScanningOverlay();

  @override
  State<_ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<_ScanningOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
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
        return Stack(
          children: [
            Positioned(
              top: _controller.value * MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0),
                      AppColors.primary.withOpacity(0.05),
                      AppColors.primary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
