import 'package:get/get.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/services/api_service.dart';

class FarmManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var farms = <FarmModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getFarms();
  }

  Future<void> getFarms() async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('fazendas/');
      if (response.statusCode == 200) {
        farms.assignAll(
          (response.data as List).map((e) => FarmModel.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar as fazendas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createFarm(FarmModel farm) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.post('fazendas/', data: farm.toJson());
      if (response.statusCode == 201) {
        getFarms();
        Get.back();
        Get.snackbar('Sucesso', 'Fazenda cadastrada com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar fazenda');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFarm(FarmModel farm) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.put('fazendas/${farm.id}/', data: farm.toJson());
      if (response.statusCode == 200) {
        getFarms();
        Get.back();
        Get.snackbar('Sucesso', 'Fazenda atualizada com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar fazenda');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFarm(int id) async {
    try {
      final response = await _apiService.dio.delete('fazendas/$id/');
      if (response.statusCode == 204) {
        getFarms();
        Get.snackbar('Sucesso', 'Fazenda removida');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover fazenda');
    }
  }
}
