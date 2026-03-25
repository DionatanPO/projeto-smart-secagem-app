import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SmartSenseIAController extends GetxController {
  final aiFeatures = [
    {
      'title': 'Análise Preditiva 24/7',
      'description':
          'Nossos modelos analisam tendências térmicas para prever focos de calor com até 48h de antecedência.',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Otimização Energética',
      'description':
          'O algoritmo cruza dados meteorológicos com o equilíbrio higroscópico para ligar a aeração apenas no momento exato.',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFF3B82F6),
    },
    {
      'title': 'Diagnóstico de Grãos',
      'description':
          'Relatórios automáticos que classificam a massa de grãos baseados na estabilidade térmica e riscos biológicos.',
      'icon': Icons.analytics_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Auto-ajuste de Sensores',
      'description':
          'A inteligência detecta falhas em cabos termométricos ou hubs, descartando leituras ruidosas automaticamente.',
      'icon': Icons.settings_suggest_rounded,
      'color': Color(0xFF6366F1),
    },
  ];

  final isProcessing = false.obs;

  void runDiagnosis() async {
    isProcessing.value = true;
    await Future.delayed(Duration(seconds: 3));
    isProcessing.value = false;
    Get.snackbar(
      'Análise Concluída',
      'O Smart Sense IA não detectou anomalias críticas nos seus silos.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green[800],
    );
  }
}
