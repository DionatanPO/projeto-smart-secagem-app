import 'package:get/get.dart';
import '../../../core/models/unidade_armazenadora_model.dart';
import '../../../core/services/api_service.dart';

class UnidadeArmazenadoraManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var unidades = <UnidadeArmazenadoraModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  List<UnidadeArmazenadoraModel> get filteredUnidades {
    if (searchQuery.value.isEmpty) return unidades;
    final q = searchQuery.value.toLowerCase();
    return unidades.where((f) =>
      f.name.toLowerCase().contains(q) ||
      (f.location?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getUnidades();
  }

  void filterUnidades(String query) => searchQuery.value = query;

  Future<void> getUnidades() async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('unidades-armazenadoras/');
      if (response.statusCode == 200) {
        unidades.assignAll(
          (response.data as List).map((e) => UnidadeArmazenadoraModel.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar as unidades armazenadoras');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUnidade(UnidadeArmazenadoraModel unidade) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.post('unidades-armazenadoras/', data: unidade.toJson());
      if (response.statusCode == 201) {
        getUnidades();
        Get.back();
        Get.snackbar('Sucesso', 'Unidade armazenadora cadastrada com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar unidade armazenadora');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUnidade(UnidadeArmazenadoraModel unidade) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.put('unidades-armazenadoras/${unidade.id}/', data: unidade.toJson());
      if (response.statusCode == 200) {
        getUnidades();
        Get.back();
        Get.snackbar('Sucesso', 'Unidade armazenadora atualizada com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar unidade armazenadora');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUnidade(int id) async {
    try {
      final response = await _apiService.dio.delete('unidades-armazenadoras/$id/');
      if (response.statusCode == 204) {
        getUnidades();
        Get.snackbar('Sucesso', 'Unidade armazenadora removida');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover unidade armazenadora');
    }
  }
}
