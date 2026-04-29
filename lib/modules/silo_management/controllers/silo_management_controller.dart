import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/silo_model.dart';
import '../../../core/models/sensor_model.dart';
import '../../../core/models/telemetry_model.dart';
import '../../farm_management/controllers/farm_management_controller.dart';
import '../../../core/models/farm_model.dart';

class SiloManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final _farmController = Get.find<FarmManagementController>();

  final silos = <SiloModel>[].obs;
  List<FarmModel> get availableFarms => _farmController.farms;
  final siloSensors = <SensorModel>[].obs;
  
  // Guardamos as últimas leituras de CADA sensor agrupadas por ID do silo
  final siloLatestReadings = <int, List<TelemetryModel>>{}.obs;
  
  final isLoading = false.obs;
  final isLoadingSensors = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    await getSilos();
    await getAllSensors();
  }

  Future<void> getAllSensors() async {
    try {
      final response = await _apiService.dio.get('sensores/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final allSensors = data.map((json) => SensorModel.fromJson(json)).toList();
        
        // Vamos buscar as telemetrias de HOJE para popular os cards
        await _calculateAllSiloMetrics(allSensors);
      }
    } catch (e) {
      print('Erro ao carregar dados de monitoramento: $e');
    }
  }

  Future<void> _calculateAllSiloMetrics(List<SensorModel> allSensors) async {
    try {
      for (var silo in silos) {
        if (silo.id == null) continue;

        // Filtramos os sensores deste silo
        final sensorsThisSilo = allSensors.where((s) => s.siloId == silo.id).toList();
        if (sensorsThisSilo.isEmpty) {
          siloLatestReadings[silo.id!] = [];
          continue;
        }

        // Busca telemetria filtrada por SILO (sem trava de data)
        final response = await _apiService.dio.get('telemetria/', queryParameters: {'silo': silo.id});
        
        if (response.statusCode == 200) {
          final List<dynamic> teleData = response.data;
          final siloTelemetries = teleData.map((json) => TelemetryModel.fromJson(json)).toList();

          final List<TelemetryModel> currentSiloReadings = [];

          for (var sensor in sensorsThisSilo) {
            // Filtra as telemetrias DESTE sensor específico dentro do set do Silo
            final sensorTele = siloTelemetries.where((t) => t.sensorId == sensor.id).toList();
            
            if (sensorTele.isNotEmpty) {
              // Como o backend já ordena por -timestamp, a primeira é a mais recente
              // Mas garantimos ordenando aqui também para segurança
              sensorTele.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              currentSiloReadings.add(sensorTele.first);
            } else {
              currentSiloReadings.add(TelemetryModel(
                sensorId: sensor.id ?? 0,
                sensorPhysicalId: sensor.sensorId,
                temperature: 0.0,
                humidity: 0.0,
                timestamp: DateTime.now(), // Placeholder indicando falta de dados
              ));
            }
          }

          currentSiloReadings.sort((a, b) => a.sensorPhysicalId.compareTo(b.sensorPhysicalId));
          siloLatestReadings[silo.id!] = currentSiloReadings;
        }
      }
    } catch (e) {
      print('Erro ao calcular métricas dos silos: $e');
    }
  }

  Future<void> getSilos() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('silos/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        silos.assignAll(data.map((json) => SiloModel.fromJson(json)).toList());
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os silos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSilo(SiloModel silo) async {
    try {
      final response = await _apiService.dio.post(
        'silos/',
        data: silo.toJson(),
      );
      if (response.statusCode == 201) {
        silos.add(SiloModel.fromJson(response.data));
        Get.back();
        Get.snackbar('Sucesso', 'Silo cadastrado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar silo');
    }
  }

  Future<void> updateSilo(SiloModel silo) async {
    try {
      final response = await _apiService.dio.put(
        'silos/${silo.id}/',
        data: silo.toJson(),
      );
      if (response.statusCode == 200) {
        final index = silos.indexWhere((s) => s.id == silo.id);
        if (index != -1) {
          silos[index] = SiloModel.fromJson(response.data);
        }
        Get.back();
        Get.snackbar('Sucesso', 'Silo atualizado com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar silo');
    }
  }

  Future<void> deleteSilo(int id) async {
    try {
      final response = await _apiService.dio.delete('silos/$id/');
      if (response.statusCode == 204) {
        silos.removeWhere((s) => s.id == id);
        Get.snackbar('Sucesso', 'Silo removido com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover silo');
    }
  }

  void refreshSilos() {
    getSilos();
  }

  Future<void> getSensorsBySilo(int siloId) async {
    isLoadingSensors.value = true;
    siloSensors.clear();
    try {
      // Nota: Assume-se que o backend suporta filtragem por ?silo=id ou que filtramos no front
      final response = await _apiService.dio.get('sensores/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final allSensors = data.map((json) => SensorModel.fromJson(json)).toList();
        siloSensors.assignAll(allSensors.where((s) => s.siloId == siloId).toList());
      }
    } catch (e) {
      print('Erro ao carregar sensores do silo: $e');
    } finally {
      isLoadingSensors.value = false;
    }
  }

  // Métodos utilitários mantidos para compatibilidade com a UI ou futura expansão
  double getAverageTemp(int index) {
    // Como a API básica não tem temperaturas ainda, retornamos um valor padrão ou mock
    return 25.0;
  }

  bool hasHotspot(int index) {
    return false;
  }

  void toggleAeration(int index) {
    final silo = silos[index];
    Get.snackbar(
      'Aeração',
      'Comando enviado para o ${silo.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Métodos para o Dashboard em Tempo Real
  int getSiloSensorCount(int siloId) {
    return siloLatestReadings[siloId]?.length ?? 0;
  }

  List<TelemetryModel> getLatestReadings(int siloId) {
    return siloLatestReadings[siloId] ?? [];
  }
}

