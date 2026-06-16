import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/motor_aeracao_model.dart';
import '../../../core/models/silo_model.dart';
import '../../../core/models/secador_model.dart';

class AerationMotorController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final motors = <MotorAeracaoModel>[].obs;
  final silos = <SiloModel>[].obs;
  final secadores = <SecadorModel>[].obs;
  final isLoading = false.obs;
  final isCommanding = false.obs;

  final searchQuery = ''.obs;

  List<MotorAeracaoModel> get filteredMotors {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return motors;
    return motors.where((m) =>
      m.motorId.toLowerCase().contains(query) ||
      m.description.toLowerCase().contains(query) ||
      m.status.toLowerCase().contains(query) ||
      m.estado.toLowerCase().contains(query) ||
      (m.siloName?.toLowerCase().contains(query) ?? false) ||
      (m.secadorName?.toLowerCase().contains(query) ?? false)
    ).toList();
  }

  void filterMotors(String query) => searchQuery.value = query;

  @override
  void onInit() {
    super.onInit();
    getMotors();
    getSilos();
    getSecadores();
  }

  Future<void> getMotors() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('motores-aeracao/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        motors.assignAll(data.map((json) => MotorAeracaoModel.fromJson(json)).toList());
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar os motores');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSilos() async {
    try {
      final response = await _apiService.dio.get('silos/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        silos.assignAll(data.map((json) => SiloModel.fromJson(json)).toList());
      }
    } catch (_) {}
  }

  Future<void> getSecadores() async {
    try {
      final response = await _apiService.dio.get('secadores/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        secadores.assignAll(data.map((json) => SecadorModel.fromJson(json)).toList());
      }
    } catch (_) {}
  }

  Future<void> createMotor(MotorAeracaoModel motor) async {
    try {
      final response = await _apiService.dio.post('motores-aeracao/', data: motor.toJson());
      if (response.statusCode == 201) {
        getMotors();
        Get.back();
        Get.snackbar('Sucesso', 'Motor de aeração cadastrado');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar motor');
    }
  }

  Future<void> updateMotor(MotorAeracaoModel motor) async {
    try {
      final response = await _apiService.dio.put('motores-aeracao/${motor.id}/', data: motor.toJson());
      if (response.statusCode == 200) {
        getMotors();
        Get.back();
        Get.snackbar('Sucesso', 'Motor atualizado');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar motor');
    }
  }

  Future<void> deleteMotor(int id) async {
    try {
      final response = await _apiService.dio.delete('motores-aeracao/$id/');
      if (response.statusCode == 204) {
        motors.removeWhere((m) => m.id == id);
        Get.snackbar('Sucesso', 'Motor removido');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover motor');
    }
  }

  Future<void> turnOn(MotorAeracaoModel motor) async {
    isCommanding.value = true;
    try {
      final response = await _apiService.dio.post(
        'motores-aeracao/${motor.id}/comando/',
        data: {'comando': 'ligar'},
      );
      if (response.statusCode == 200) {
        final index = motors.indexWhere((m) => m.id == motor.id);
        if (index != -1) {
          motors[index] = motors[index].copyWith(
            estado: 'ligado',
            consumoAtualKW: motor.potenciaKW,
          );
        }
        Get.snackbar('Sucesso', 'Motor ${motor.motorId} ligado');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao ligar motor');
    } finally {
      isCommanding.value = false;
    }
  }

  Future<void> turnOff(MotorAeracaoModel motor) async {
    isCommanding.value = true;
    try {
      final response = await _apiService.dio.post(
        'motores-aeracao/${motor.id}/comando/',
        data: {'comando': 'desligar'},
      );
      if (response.statusCode == 200) {
        final index = motors.indexWhere((m) => m.id == motor.id);
        if (index != -1) {
          motors[index] = motors[index].copyWith(
            estado: 'desligado',
            consumoAtualKW: 0,
          );
        }
        Get.snackbar('Sucesso', 'Motor ${motor.motorId} desligado');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao desligar motor');
    } finally {
      isCommanding.value = false;
    }
  }

  Future<void> refreshMotorStatus() async {
    try {
      final response = await _apiService.dio.get('motores-aeracao/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final updated = data.map((json) => MotorAeracaoModel.fromJson(json)).toList();
        for (final updatedMotor in updated) {
          final index = motors.indexWhere((m) => m.id == updatedMotor.id);
          if (index != -1) {
            motors[index] = updatedMotor;
          }
        }
      }
    } catch (_) {}
  }
}
