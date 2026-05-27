import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/cliente_model.dart';

class ClientesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final clientes = <ClienteModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  List<ClienteModel> get filteredClientes {
    if (searchQuery.value.isEmpty) return clientes;
    final q = searchQuery.value.toLowerCase();
    return clientes.where((c) =>
      c.nome.toLowerCase().contains(q) ||
      (c.email?.toLowerCase().contains(q) ?? false) ||
      (c.telefone?.contains(q) ?? false) ||
      (c.cpfCnpj?.contains(q) ?? false)
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getClientes();
  }

  void filterClientes(String query) => searchQuery.value = query;

  Future<void> getClientes() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('clientes/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        clientes.assignAll(data.map((json) => ClienteModel.fromJson(json)).toList());
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar clientes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCliente(ClienteModel cliente) async {
    try {
      final response = await _apiService.dio.post(
        'clientes/',
        data: cliente.toJson(),
      );
      if (response.statusCode == 201) {
        clientes.add(ClienteModel.fromJson(response.data));
        Get.back();
        Get.snackbar('Sucesso', 'Cliente cadastrado com sucesso');
      }
    } on DioException catch (e) {
      String errorMsg = 'Falha ao cadastrar cliente';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('cpf_cnpj')) {
          errorMsg = 'Este CPF/CNPJ já está cadastrado no sistema.';
        }
      }
      Get.snackbar('Erro', errorMsg, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar cliente', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateCliente(ClienteModel cliente) async {
    try {
      final response = await _apiService.dio.put(
        'clientes/${cliente.id}/',
        data: cliente.toJson(),
      );
      if (response.statusCode == 200) {
        final index = clientes.indexWhere((c) => c.id == cliente.id);
        if (index != -1) {
          clientes[index] = ClienteModel.fromJson(response.data);
        }
        Get.back();
        Get.snackbar('Sucesso', 'Cliente atualizado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar cliente');
    }
  }

  Future<void> deleteCliente(int id) async {
    try {
      final response = await _apiService.dio.delete('clientes/$id/');
      if (response.statusCode == 204) {
        clientes.removeWhere((c) => c.id == id);
        Get.snackbar('Sucesso', 'Cliente removido com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover cliente');
    }
  }
}
