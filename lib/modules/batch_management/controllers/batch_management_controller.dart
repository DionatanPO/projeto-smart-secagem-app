import 'package:get/get.dart';
import '../../../core/models/batch_model.dart';
import '../../../core/services/api_service.dart';
import '../../silo_management/controllers/silo_management_controller.dart';

class BatchManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var batches = <BatchModel>[].obs;
  var clients = <dynamic>[].obs; // Usando dynamic para evitar conflito se o modelo não estiver importado corretamente, mas vamos importar
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getBatches();
    getClients();
  }

  Future<void> getBatches() async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('lotes/');
      if (response.statusCode == 200) {
        batches.assignAll(
          (response.data as List).map((e) => BatchModel.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar os lotes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBatch(BatchModel batch) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.post('lotes/', data: batch.toJson());
      if (response.statusCode == 201) {
        getBatches();
        // Atualiza a lista de silos pois o status mudou para 'ocupado' no backend
        if (Get.isRegistered<SiloManagementController>()) {
          Get.find<SiloManagementController>().getSilos();
        }
        Get.back();
        Get.snackbar('Sucesso', 'Lote cadastrado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar lote');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBatch(BatchModel batch) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.patch('lotes/${batch.id}/', data: batch.toJson());
      if (response.statusCode == 200) {
        getBatches();
        // Atualiza a lista de silos pois o status pode ter mudado para 'livre' no backend
        if (Get.isRegistered<SiloManagementController>()) {
          Get.find<SiloManagementController>().getSilos();
        }
        Get.back();
        Get.snackbar('Sucesso', 'Lote atualizado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar lote');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBatch(int id) async {
    try {
      final response = await _apiService.dio.delete('lotes/$id/');
      if (response.statusCode == 204) {
        getBatches();
        Get.snackbar('Sucesso', 'Lote removido');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover lote');
    }
  }

  Future<void> getClients() async {
    try {
      final response = await _apiService.dio.get('clientes/');
      if (response.statusCode == 200) {
        clients.assignAll(response.data);
      }
    } catch (e) {
      print("Erro ao buscar clientes: $e");
    }
  }
}
