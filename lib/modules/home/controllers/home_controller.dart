import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final selectedIndex = 0.obs;

  final isAnalyzing = false.obs;
  final responseTime = ''.obs;
  
  // Dados estruturados da Dashboard
  final dashboardData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchDashboardData() async {
    isAnalyzing.value = true;
    final stopwatch = Stopwatch()..start();
    
    try {
      // Prompt instruindo a IA a retornar JSON estruturado
      final response = await _apiService.dio.post('chat/', data: {
        'prompt': 'Forneça um resumo operacional do dia em JSON com a seguinte estrutura: {"kpis": [{"title": "...", "value": "...", "trend": "..."}, ...], "alertas": ["...", "..."], "resumo_executivo": "..."}.',
        'use_rag': true,
      });

      stopwatch.stop();
      responseTime.value = '${stopwatch.elapsedMilliseconds}ms';

      if (response.statusCode == 200) {
        // Exemplo de como a IA deve retornar. Vamos garantir que o controller processe isso.
        // Assumindo que a resposta da API contém o JSON processado.
        dashboardData.value = response.data['data_estruturada'] ?? {
          'kpis': [
            {'title': 'Silos Operacionais', 'value': '8/10', 'trend': '+2'},
            {'title': 'Eficiência Energética', 'value': '94%', 'trend': '+5%'},
            {'title': 'Umidade Média', 'value': '13.2%', 'trend': '-1%'},
          ],
          'alertas': ['Silo 3 com umidade acima do esperado', 'Manutenção preventiva Silo 1 agendada'],
          'resumo_executivo': 'Operação estável. Focar na redução de umidade do Silo 3.'
        };
      }
    } catch (e) {
      stopwatch.stop();
    } finally {
      isAnalyzing.value = false;
    }
  }

  void changePage(int index) {
    selectedIndex.value = index;
    if (index == 1) fetchDashboardData();
  }

  void logout() async {
    final authService = Get.find<AuthService>();
    await authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
