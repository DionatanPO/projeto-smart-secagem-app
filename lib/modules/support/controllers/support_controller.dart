import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportController extends GetxController {
  final activeSection = 0.obs;

  final aerationLogicSteps = [
    {
      'title': 'Monitoramento Constante',
      'description':
          'O sistema lê os sensores de temperatura e umidade interna e externa a cada 60 segundos.',
      'icon': Icons.monitor_heart_rounded,
    },
    {
      'title': 'Análise de Equilíbrio Higroscópico',
      'description':
          'Calculamos se o ar externo é capaz de remover umidade do grão sem ressecá-lo excessivamente.',
      'icon': Icons.calculate_rounded,
    },
    {
      'title': 'Decisão Inteligente',
      'description':
          'A aeração liga apenas se o Delta T (diferença de temperatura) for favorável e a UR (Umidade Relativa) externa estiver na janela ideal.',
      'icon': Icons.psychology_rounded,
    },
    {
      'title': 'Proteção de Qualidade',
      'description':
          'O sistema desliga automaticamente se detectar tendência de aquecimento ou aumento de umidade na massa.',
      'icon': Icons.verified_user_rounded,
    },
  ];

  final attributes = [
    {
      'name': 'Temperatura Interna',
      'importance': 'Crítica',
      'desc': 'Detecta focos de calor e atividade biológica no grão.',
      'icon': Icons.thermostat_rounded,
      'color': Colors.orange,
    },
    {
      'name': 'Umidade Relativa',
      'importance': 'Alta',
      'desc':
          'Define o ponto de equilíbrio para evitar ganho de peso por água.',
      'icon': Icons.water_drop_rounded,
      'color': Colors.blue,
    },
    {
      'name': 'Ponto de Orvalho',
      'importance': 'Média',
      'desc': 'Previne a condensação de água nas paredes frias do silo.',
      'icon': Icons.grain_rounded,
      'color': Colors.cyan,
    },
    {
      'name': 'Delta T',
      'importance': 'Operacional',
      'desc':
          'Diferença entre o ar externo e a massa para resfriamento efetivo.',
      'icon': Icons.compare_arrows_rounded,
      'color': Colors.purple,
    },
  ];

  void changeSection(int index) {
    activeSection.value = index;
  }
}
