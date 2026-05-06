import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/processo_model.dart';
import '../../../core/models/batch_model.dart';
import '../../../core/models/secador_model.dart';
import '../../../core/models/silo_model.dart';
import '../../batch_management/controllers/batch_management_controller.dart';
import '../../secagem/controllers/secagem_controller.dart';
import '../../silo_management/controllers/silo_management_controller.dart';

class ProcessosController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final _batchController = Get.find<BatchManagementController>();
  final _secagemController = Get.find<SecagemController>();
  final _siloController = Get.find<SiloManagementController>();

  final processos = <ProcessoModel>[].obs;
  final isLoading = false.obs;

  List<BatchModel> get availableBatches => _batchController.batches;
  List<SecadorModel> get availableDryers => _secagemController.secadores;
  List<SiloModel> get availableSilos => _siloController.silos;

  @override
  void onInit() {
    super.onInit();
    getProcessos();
  }

  Future<void> getProcessos() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('processos/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        processos.assignAll(data.map((json) => ProcessoModel.fromJson(json)).toList());
      }
    } catch (e) {
      print('Erro ao carregar processos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProcesso(ProcessoModel processo) async {
    try {
      final response = await _apiService.dio.post(
        'processos/',
        data: processo.toJson(),
      );
      if (response.statusCode == 201) {
        processos.insert(0, ProcessoModel.fromJson(response.data));
        _refreshData();
        Get.back();
        Get.snackbar('Sucesso', 'Processo iniciado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao iniciar processo');
    }
  }

  Future<void> updateProcesso(ProcessoModel processo) async {
    try {
      final response = await _apiService.dio.put(
        'processos/${processo.id}/',
        data: processo.toJson(),
      );
      if (response.statusCode == 200) {
        final index = processos.indexWhere((p) => p.id == processo.id);
        if (index != -1) {
          processos[index] = ProcessoModel.fromJson(response.data);
        }
        _refreshData();
        Get.back();
        Get.snackbar('Sucesso', 'Processo atualizado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar processo');
    }
  }

  Future<void> changeStatus(ProcessoModel processo, String newStatus) async {
    try {
      final now = DateTime.now();
      Map<String, dynamic> data = {'status': newStatus};

      if (newStatus == 'Finalizada' || newStatus == 'Cancelada') {
        data['data_fim'] = now.toIso8601String();
      } else if (newStatus == 'Pausada') {
        data['data_fim'] = now.toIso8601String();
      } else if (newStatus == 'Iniciada') {
        // Se estava pausado e vai retomar
        if (processo.status == 'Pausada' && processo.dataFim != null) {
          final tempoParado = now.difference(processo.dataFim!);
          final novaDataInicio = processo.dataInicio.add(tempoParado);
          data['data_inicio'] = novaDataInicio.toIso8601String();
        }
        data['data_fim'] = null;
      }

      final response = await _apiService.dio.patch(
        'processos/${processo.id}/',
        data: data,
      );

      if (response.statusCode == 200) {
        final index = processos.indexWhere((p) => p.id == processo.id);
        if (index != -1) {
          processos[index] = ProcessoModel.fromJson(response.data);
        }
        _refreshData();
        Get.snackbar('Status Atualizado', 'Atividade agora está: $newStatus');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao alterar status');
    }
  }

  Future<void> deleteProcesso(int id) async {
    try {
      final response = await _apiService.dio.delete('processos/$id/');
      if (response.statusCode == 204) {
        processos.removeWhere((p) => p.id == id);
        _refreshData();
        Get.snackbar('Sucesso', 'Processo removido com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover processo');
    }
  }

  void _refreshData() {
    try {
      _batchController.getBatches();
      _siloController.getSilos();
    } catch (e) {
      print('Erro ao atualizar dados secundários: $e');
    }
  }
}
