import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final selectedIndex = 0.obs;

  final isAnalyzing = true.obs;
  final aiSummary = 'Analisando o dia...'.obs;
  
  final chatMessages = <Map<String, dynamic>>[].obs;
  final chatController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _fetchDailySummary();
  }

  Future<void> _fetchDailySummary() async {
    isAnalyzing.value = true;
    try {
      final response = await _apiService.dio.post('chat/', data: {
        'prompt': 'Faça um resumo do dia da operação do Smart Secagem.',
        'use_rag': false,
      });

      if (response.statusCode == 200) {
        aiSummary.value = response.data['response'];
      } else {
        aiSummary.value = 'Não foi possível carregar o resumo.';
      }
    } catch (e) {
      aiSummary.value = 'Erro ao conectar com a IA: $e';
    } finally {
      isAnalyzing.value = false;
    }
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    chatMessages.add({'isUser': true, 'text': text});
    chatController.clear();
    
    try {
      final response = await _apiService.dio.post('chat/', data: {
        'prompt': text,
        'use_rag': true,
      });
      
      chatMessages.add({
        'isUser': false,
        'text': response.data['response']
      });
    } catch (e) {
      chatMessages.add({
        'isUser': false,
        'text': 'Erro ao processar sua pergunta.'
      });
    }
  }

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void logout() async {
    final authService = Get.find<AuthService>();
    await authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
