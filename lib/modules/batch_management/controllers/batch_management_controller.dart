import 'package:get/get.dart';
import '../../../core/models/batch_model.dart';
import '../../../core/services/api_service.dart';
import '../../silo_management/controllers/silo_management_controller.dart';

class BatchManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var batches = <BatchModel>[].obs;
  var clients = <dynamic>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  List<BatchModel> get filteredBatches {
    if (searchQuery.value.isEmpty) return batches;
    final q = searchQuery.value.toLowerCase();
    return batches.where((b) =>
      (b.numeroLote?.toLowerCase().contains(q) ?? false) ||
      b.cultura.toLowerCase().contains(q) ||
      b.safra.toLowerCase().contains(q) ||
      (b.farmName?.toLowerCase().contains(q) ?? false) ||
      (b.clienteNome?.toLowerCase().contains(q) ?? false) ||
      b.status.toLowerCase().contains(q)
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getBatches();
    getClients();
  }

  void filterBatches(String query) => searchQuery.value = query;

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
      // silent
    }
  }
}
