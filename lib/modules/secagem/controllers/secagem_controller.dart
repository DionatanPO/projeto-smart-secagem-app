import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/secador_model.dart';
import '../../farm_management/controllers/farm_management_controller.dart';
import '../../../core/models/farm_model.dart';

class SecagemController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final _farmController = Get.find<FarmManagementController>();

  final secadores = <SecadorModel>[].obs;
  List<FarmModel> get availableFarms => _farmController.farms;
  
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getSecadores();
  }

  Future<void> getSecadores() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('secadores/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        secadores.assignAll(data.map((json) => SecadorModel.fromJson(json)).toList());
      }
    } catch (e) {
      print('Erro ao carregar secadores: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSecador(SecadorModel secador) async {
    try {
      final response = await _apiService.dio.post(
        'secadores/',
        data: secador.toJson(),
      );
      if (response.statusCode == 201) {
        secadores.add(SecadorModel.fromJson(response.data));
        Get.back();
        Get.snackbar('Sucesso', 'Secador cadastrado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar secador');
    }
  }

  Future<void> updateSecador(SecadorModel secador) async {
    try {
      final response = await _apiService.dio.put(
        'secadores/${secador.id}/',
        data: secador.toJson(),
      );
      if (response.statusCode == 200) {
        final index = secadores.indexWhere((s) => s.id == secador.id);
        if (index != -1) {
          secadores[index] = SecadorModel.fromJson(response.data);
        }
        Get.back();
        Get.snackbar('Sucesso', 'Secador atualizado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar secador');
    }
  }

  Future<void> deleteSecador(int id) async {
    try {
      final response = await _apiService.dio.delete('secadores/$id/');
      if (response.statusCode == 204) {
        secadores.removeWhere((s) => s.id == id);
        Get.snackbar('Sucesso', 'Secador removido com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover secador');
    }
  }
}
