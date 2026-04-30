import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/silo_model.dart';

class SmartSenseIAController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final isProcessing = false.obs;
  final silos = <SiloModel>[].obs;
  final selectedSilo = Rxn<SiloModel>();
  final aiInsight = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchSilos();
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
    
    try {
      final response = await _apiService.dio.get('silos/${selectedSilo.value!.id}/analise/');
      if (response.statusCode == 200) {
        aiInsight.value = response.data['insight'];
      }
    } catch (e) {
      Get.snackbar(
        'Erro na Análise',
        'Não foi possível obter a análise da IA. Verifique se o servidor está rodando e se a API KEY foi configurada.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isProcessing.value = false;
    }
  }
}
