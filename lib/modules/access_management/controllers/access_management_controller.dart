import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/unidade_armazenadora_model.dart';

class AccessManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final users = <UserModel>[].obs;
  final unidades = <UnidadeArmazenadoraModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  int? currentUserId;

  List<UserModel> get filteredUsers {
    final list = currentUserId != null
        ? users.where((u) => u.id != currentUserId).toList()
        : users;
    if (searchQuery.value.isEmpty) return list;
    final q = searchQuery.value.toLowerCase();
    return list.where((u) =>
      u.displayName.toLowerCase().contains(q) ||
      u.email.toLowerCase().contains(q) ||
      u.accountType.toLowerCase().contains(q)
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
    getUsers();
    loadUnidades();
  }

  Future<void> loadUnidades() async {
    try {
      final response = await _apiService.dio.get('unidades-armazenadoras/');
      if (response.statusCode == 200) {
        unidades.assignAll(
          (response.data as List).map((e) => UnidadeArmazenadoraModel.fromJson(e)).toList(),
        );
      }
    } catch (_) {}
  }

  void filterUsers(String query) => searchQuery.value = query;

  Future<void> getCurrentUser() async {
    try {
      final response = await _apiService.dio.get('me/');
      currentUserId = response.data['id'] as int?;
    } catch (_) {}
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
      Get.snackbar('Erro', 'Não foi possível carregar os usuários', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      final response = await _apiService.dio.post('usuarios/', data: user.toJson());
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
      final data = <String, dynamic>{
        'email': user.email,
      };
      if (user.firstName.isNotEmpty) data['first_name'] = user.firstName;
      if (user.lastName.isNotEmpty) data['last_name'] = user.lastName;
      if (user.telefone != null) data['telefone'] = user.telefone;
      if (user.unidadeArmazenadora != null) data['unidade_armazenadora'] = user.unidadeArmazenadora;
      final response = await _apiService.dio.patch('usuarios/${user.id}/', data: data);
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
    if (id == currentUserId) {
      Get.snackbar('Erro', 'Você não pode excluir o próprio usuário');
      return;
    }
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
}
