import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/user_model.dart';

class AccessManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final users = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getUsers();
  }

  Future<void> getUsers() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('usuarios/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        users.assignAll(data.map((json) => UserModel.fromJson(json)).toList());
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os usuários',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      final response = await _apiService.dio.post(
        'usuarios/',
        data: user.toJson(),
      );
      if (response.statusCode == 201) {
        users.add(UserModel.fromJson(response.data));
        Get.back();
        Get.snackbar('Sucesso', 'Usuário criado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao criar usuário');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final response = await _apiService.dio.put(
        'usuarios/${user.id}/',
        data: user.toJson(),
      );
      if (response.statusCode == 200) {
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = UserModel.fromJson(response.data);
        }
        Get.back();
        Get.snackbar('Sucesso', 'Usuário atualizado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar usuário');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await _apiService.dio.delete('usuarios/$id/');
      if (response.statusCode == 204) {
        users.removeWhere((u) => u.id == id);
        Get.snackbar('Sucesso', 'Usuário removido');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover usuário');
    }
  }

  void showUserForm({UserModel? user}) {
    // Implementação do diálogo de formulário virá na View
  }
}
