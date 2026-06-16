import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/secador_model.dart';
import '../../../core/models/sensor_model.dart';
import '../../../core/models/telemetry_model.dart';
import '../../../core/models/motor_aeracao_model.dart';
import '../../unidade_armazenadora_management/controllers/unidade_armazenadora_management_controller.dart';
import '../../../core/models/unidade_armazenadora_model.dart';

class SecagemController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final _unidadeController = Get.find<UnidadeArmazenadoraManagementController>();

  final secadores = <SecadorModel>[].obs;
  List<UnidadeArmazenadoraModel> get availableUnidades => _unidadeController.unidades;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // Motors
  final _allMotors = <MotorAeracaoModel>[].obs;
  final secadorMotors = <MotorAeracaoModel>[].obs;
  final isLoadingMotors = false.obs;

  // Sensors & telemetry per secador
  final secadorSensors = <SensorModel>[].obs;
  final secadorLatestReadings = <int, List<TelemetryModel>>{}.obs;
  final isLoadingSecadorSensors = false.obs;

  List<SecadorModel> get filteredSecadores {
    if (searchQuery.value.isEmpty) return secadores;
    final q = searchQuery.value.toLowerCase();
    return secadores.where((s) =>
      s.nome.toLowerCase().contains(q) ||
      s.tipo.toLowerCase().contains(q) ||
      s.fonteCalor.toLowerCase().contains(q) ||
      s.status.toLowerCase().contains(q) ||
      (s.unidadeArmazenadoraNome?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    await getSecadores();
    await getAllSensors();
    await getAllMotors();
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

  // --- Sensors ---

  Future<void> getAllSensors() async {
    try {
      final response = await _apiService.dio.get('sensores/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final allSensors = data.map((json) => SensorModel.fromJson(json)).toList();
        await _calculateAllSecadorMetrics(allSensors);
      }
    } catch (_) {}
  }

  Future<void> _calculateAllSecadorMetrics(List<SensorModel> allSensors) async {
    try {
      for (var secador in secadores) {
        if (secador.id == null) continue;
        final sensorsThisSecador = allSensors.where((s) => s.secadorId == secador.id).toList();
        if (sensorsThisSecador.isEmpty) {
          secadorLatestReadings[secador.id!] = [];
          continue;
        }
        final response = await _apiService.dio.get('telemetria/', queryParameters: {'secador': secador.id});
        if (response.statusCode == 200) {
          final List<dynamic> teleData = response.data;
          final secadorTelemetries = teleData.map((json) => TelemetryModel.fromJson(json)).toList();
          final List<TelemetryModel> currentReadings = [];
          for (var sensor in sensorsThisSecador) {
            final sensorTele = secadorTelemetries.where((t) => t.sensorId == sensor.id).toList();
            if (sensorTele.isNotEmpty) {
              sensorTele.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              currentReadings.add(sensorTele.first);
            } else {
              currentReadings.add(TelemetryModel(
                sensorId: sensor.id ?? 0,
                sensorPhysicalId: sensor.sensorId,
                temperature: 0.0,
                humidity: 0.0,
                timestamp: DateTime.now(),
              ));
            }
          }
          currentReadings.sort((a, b) => a.sensorPhysicalId.compareTo(b.sensorPhysicalId));
          secadorLatestReadings[secador.id!] = currentReadings;
        }
      }
    } catch (_) {}
  }

  Future<void> getSensorsBySecador(int secadorId) async {
    isLoadingSecadorSensors.value = true;
    secadorSensors.clear();
    try {
      final response = await _apiService.dio.get('sensores/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final allSensors = data.map((json) => SensorModel.fromJson(json)).toList();
        secadorSensors.assignAll(allSensors.where((s) => s.secadorId == secadorId).toList());
      }
    } catch (_) {} finally {
      isLoadingSecadorSensors.value = false;
    }
  }

  int getSecadorSensorCount(int secadorId) {
    return secadorLatestReadings[secadorId]?.length ?? 0;
  }

  List<TelemetryModel> getLatestReadings(int secadorId) {
    return secadorLatestReadings[secadorId] ?? [];
  }

  Future<List<SensorModel>> getSensores(int secadorId) async {
    try {
      final response = await _apiService.dio.get('sensores/', queryParameters: {'secador': secadorId});
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => SensorModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<TelemetryModel>> getTelemetria(int sensorId, {String? data}) async {
    try {
      final params = <String, dynamic>{'sensor': sensorId};
      if (data != null) params['data'] = data;
      final response = await _apiService.dio.get('telemetria/', queryParameters: params);
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => TelemetryModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // --- Motors ---

  Future<void> getAllMotors() async {
    try {
      final response = await _apiService.dio.get('motores-aeracao/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _allMotors.assignAll(data.map((json) => MotorAeracaoModel.fromJson(json)).toList());
      }
    } catch (_) {}
  }

  Future<void> getMotorsBySecador(int secadorId) async {
    isLoadingMotors.value = true;
    secadorMotors.clear();
    try {
      final response = await _apiService.dio.get('motores-aeracao/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final allMotors = data.map((json) => MotorAeracaoModel.fromJson(json)).toList();
        secadorMotors.assignAll(allMotors.where((m) => m.secadorId == secadorId).toList());
      }
    } catch (_) {} finally {
      isLoadingMotors.value = false;
    }
  }

  int getSecadorMotorCount(int secadorId) {
    return _allMotors.where((m) => m.secadorId == secadorId).length;
  }

  List<MotorAeracaoModel> getMotorsForSecador(int secadorId) {
    return _allMotors.where((m) => m.secadorId == secadorId).toList();
  }

  // --- CRUD ---

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

  void refreshSecadores() {
    getSecadores();
  }
}
