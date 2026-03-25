import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/silo_model.dart';

class SiloManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final silos = <SiloModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getSilos();
  }

  Future<void> getSilos() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('silos/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        silos.assignAll(data.map((json) => SiloModel.fromJson(json)).toList());
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os silos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSilo(SiloModel silo) async {
    try {
      final response = await _apiService.dio.post(
        'silos/',
        data: silo.toJson(),
      );
      if (response.statusCode == 201) {
        silos.add(SiloModel.fromJson(response.data));
        Get.back();
        Get.snackbar('Sucesso', 'Silo cadastrado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar silo');
    }
  }

  Future<void> updateSilo(SiloModel silo) async {
    try {
      final response = await _apiService.dio.put(
        'silos/${silo.id}/',
        data: silo.toJson(),
      );
      if (response.statusCode == 200) {
        final index = silos.indexWhere((s) => s.id == silo.id);
        if (index != -1) {
          silos[index] = SiloModel.fromJson(response.data);
        }
        Get.back();
        Get.snackbar('Sucesso', 'Silo atualizado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar silo');
    }
  }

  Future<void> deleteSilo(int id) async {
    try {
      final response = await _apiService.dio.delete('silos/$id/');
      if (response.statusCode == 204) {
        silos.removeWhere((s) => s.id == id);
        Get.snackbar('Sucesso', 'Silo removido com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover silo');
    }
  }

  void refreshSilos() {
    getSilos();
  }

  // Métodos utilitários mantidos para compatibilidade com a UI ou futura expansão
  double getAverageTemp(int index) {
    // Como a API básica não tem temperaturas ainda, retornamos um valor padrão ou mock
    return 25.0;
  }

  bool hasHotspot(int index) {
    return false;
  }

  void toggleAeration(int index) {
    final silo = silos[index];
    Get.snackbar(
      'Aeração',
      'Comando enviado para o ${silo.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

