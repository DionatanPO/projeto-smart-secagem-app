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
  final searchQuery = ''.obs;

  List<SecadorModel> get filteredSecadores {
    if (searchQuery.value.isEmpty) return secadores;
    final q = searchQuery.value.toLowerCase();
    return secadores.where((s) =>
      s.nome.toLowerCase().contains(q) ||
      s.tipo.toLowerCase().contains(q) ||
      s.fonteCalor.toLowerCase().contains(q) ||
      s.status.toLowerCase().contains(q) ||
      (s.farmName?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getSecadores();
  }

  void filterSecadores(String query) => searchQuery.value = query;

  Future<void> getSecadores() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('secadores/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        secadores.assignAll(data.map((json) => SecadorModel.fromJson(json)).toList());
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar secadores');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSecador(SecadorModel secador) async {
    try {
      final response = await _apiService.dio.post('secadores/', data: secador.toJson());
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
      final response = await _apiService.dio.put('secadores/${secador.id}/', data: secador.toJson());
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
