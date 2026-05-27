import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class SmartSenseIAController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Chat Logic
  final chatMessages = <Map<String, dynamic>>[].obs;
  final chatInputController = TextEditingController();
  final scrollController = ScrollController();
  final isChatLoading = false.obs;


  @override
  void onClose() {
    scrollController.dispose();
    chatInputController.dispose();
    super.onClose();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = chatInputController.text.trim();
    if (text.isEmpty) return;

    // Adiciona mensagem do usuário localmente antes da chamada
    chatMessages.add({
      'isUser': true,
      'text': text,
      'time': DateTime.now(),
    });

    chatInputController.clear();
    scrollToBottom();
    isChatLoading.value = true;

    // Monta o histórico no formato esperado pela API (todas as mensagens
    // anteriores à que acabou de ser adicionada)
    final history = chatMessages
        .take(chatMessages.length - 1)
        .map((m) => {
              'role': (m['isUser'] as bool) ? 'user' : 'assistant',
              'content': m['text'] as String,
            })
        .toList();

    try {
      final response = await _apiService.dio.post(
        'chat/',
        options: Options(
          sendTimeout: const Duration(seconds: 300),
          receiveTimeout: const Duration(seconds: 300),
        ),
        data: {
          'prompt': text,
          'history': history,
          'use_rag': false,
          'temperature': 0.1,
        },
      );

      if (response.statusCode == 200) {
        chatMessages.add({
          'isUser': false,
          'text': response.data['response'] as String,
          'time': DateTime.now(),
        });
        scrollToBottom();
      }
    } catch (e) {
      chatMessages.add({
        'isUser': false,
        'text': 'Desculpe, tive um problema ao processar sua pergunta. Verifique se o servidor está online.',
        'time': DateTime.now(),
      });
      scrollToBottom();
    } finally {
      isChatLoading.value = false;
    }
  }
}
