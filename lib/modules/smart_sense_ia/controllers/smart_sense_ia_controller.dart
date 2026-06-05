import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class SmartSenseIAController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final chatMessages = <Map<String, dynamic>>[].obs;
  final chatInputController = TextEditingController();
  final scrollController = ScrollController();
  final isChatLoading = false.obs;

  StreamSubscription<Map<String, dynamic>>? _streamSubscription;

  @override
  void onClose() {
    _streamSubscription?.cancel();
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

    chatMessages.add({
      'isUser': true,
      'text': text,
      'time': DateTime.now(),
    });

    chatInputController.clear();
    scrollToBottom();
    isChatLoading.value = true;

    final responseIndex = chatMessages.length;
    chatMessages.add({
      'isUser': false,
      'text': '',
      'time': DateTime.now(),
    });

    final history = chatMessages
        .take(responseIndex)
        .map((m) => {
              'role': (m['isUser'] as bool) ? 'user' : 'assistant',
              'content': m['text'] as String,
            })
        .toList();

    Map<String, dynamic>? contexto;
    try {
      contexto = await _apiService.fetchContext();
    } catch (_) {}

    final prompt = contexto != null
        ? 'CONTEXTO:\n${jsonEncode(contexto)}\n\nPERGUNTA: $text'
        : text;

    _streamSubscription = _apiService.postStream('chat-stream/', {
      'prompt': prompt,
      'history': history,
      'use_rag': false,
    }).listen(
      (event) {
        final eventType = event['event'] as String?;

        switch (eventType) {
          case 'message':
            final data = event['data'] as String?;
            if (data != null && data.isNotEmpty) {
              chatMessages[responseIndex]['text'] = (chatMessages[responseIndex]['text'] as String) + data;
              chatMessages.refresh();
              scrollToBottom();
            }
            break;
          case 'error':
            chatMessages[responseIndex]['text'] = event['data'] as String? ?? 'Erro ao obter resposta.';
            chatMessages.refresh();
            isChatLoading.value = false;
            break;
          case 'thought':
          case 'metrics':
            break;
          case 'done':
            break;
          default:
            final type = event['type'] as String?;
            final content = ApiService.extractContent(event);
            if (type == 'error') {
              chatMessages[responseIndex]['text'] = event['content'] as String? ?? 'Erro ao obter resposta.';
              chatMessages.refresh();
              isChatLoading.value = false;
              return;
            }
            if (content != null && content.isNotEmpty) {
              chatMessages[responseIndex]['text'] = (chatMessages[responseIndex]['text'] as String) + content;
              chatMessages.refresh();
              scrollToBottom();
            }
            break;
        }
      },
      onError: (e) {
        chatMessages[responseIndex]['text'] = "Erro ao receber resposta.";
        chatMessages.refresh();
        isChatLoading.value = false;
      },
      onDone: () {
        isChatLoading.value = false;
      },
    );
  }
}
