import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/silo_model.dart';

class SmartSenseIAController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final isProcessing = false.obs;
  final processingStep = "".obs;
  final silos = <SiloModel>[].obs;
  final selectedSilo = Rxn<SiloModel>();
  final aiInsight = "".obs;
  
  // Chat Logic
  final chatMessages = <Map<String, dynamic>>[].obs;
  final chatInputController = TextEditingController();
  final scrollController = ScrollController();
  final isChatLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSilos();
  }

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

  Future<void> fetchSilos() async {
    try {
      final response = await _apiService.dio.get('silos/');
      if (response.statusCode == 200) {
        final List list = response.data;
        silos.value = list.map((e) => SiloModel.fromJson(e)).toList();
        if (silos.isNotEmpty) {
          selectedSilo.value = silos.first;
        }
      }
    } catch (e) {
      print("Erro ao buscar silos: $e");
    }
  }

  void runDiagnosis() async {
    if (selectedSilo.value == null) {
      Get.snackbar('Atenção', 'Selecione um silo para analisar');
      return;
    }

    isProcessing.value = true;
    aiInsight.value = "";
    
    final steps = [
      "Conectando aos sensores do Silo...",
      "Extraindo telemetria de temperatura...",
      "Analisando níveis de umidade...",
      "Processando dados na rede neural local...",
      "Gerando insights preditivos...",
    ];

    int stepIndex = 0;
    final stepTimer = Stream.periodic(const Duration(milliseconds: 1500), (i) => i).listen((_) {
      if (stepIndex < steps.length) {
        processingStep.value = steps[stepIndex];
        stepIndex++;
      }
    });

    try {
      processingStep.value = steps[0];
      final response = await _apiService.dio.get('silos/${selectedSilo.value!.id}/analise/');
      if (response.statusCode == 200) {
        // Wait a bit if it was too fast to show the animations
        await Future.delayed(const Duration(seconds: 1));
        aiInsight.value = response.data['insight'];
      }
    } catch (e) {
      Get.snackbar(
        'Erro na Análise',
        'Não foi possível obter a análise da IA. Verifique se o servidor local (LM Studio) está rodando e se o modelo está carregado.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      stepTimer.cancel();
      isProcessing.value = false;
      processingStep.value = "";
    }
  }

  Future<void> sendMessage() async {
    final text = chatInputController.text.trim();
    if (text.isEmpty) return;

    // Adiciona mensagem do usuário localmente
    chatMessages.add({
      'isUser': true,
      'text': text,
      'time': DateTime.now(),
    });

    chatInputController.clear();
    scrollToBottom();
    isChatLoading.value = true;

    try {
      final response = await _apiService.dio.post('chat-ia/', data: {
        'message': text,
      });

      if (response.statusCode == 200) {
        chatMessages.add({
          'isUser': false,
          'text': response.data['response'],
          'time': DateTime.now(),
        });
        scrollToBottom();
      }
    } catch (e) {
      chatMessages.add({
        'isUser': false,
        'text': "Desculpe, tive um problema ao processar sua pergunta. Verifique o servidor local.",
        'time': DateTime.now(),
      });
      scrollToBottom();
    } finally {
      isChatLoading.value = false;
    }
  }
}
