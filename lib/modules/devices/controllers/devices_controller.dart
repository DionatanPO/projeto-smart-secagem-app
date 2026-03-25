import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/telemetry_model.dart';
import '../../../core/models/sensor_model.dart';
import '../../../core/models/silo_model.dart';

class DevicesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final hubs = <Map<String, dynamic>>[
    {
      'id': 'HUB-001',
      'name': 'Central de Secagem A',
      'status': 'Online',
      'lastSeen': 'Agora',
      'ip': '192.168.1.50',
      'signal': 0.85,
      'battery': 1.0,
      'connectedDevices': 12,
    },
  ].obs;

  final sensors = <SensorModel>[].obs;
  final silos = <SiloModel>[].obs;
  final telemetry = <TelemetryModel>[].obs;
  final isLoading = false.obs;
  final isLoadingTelemetry = false.obs;
  final selectedTab = 0.obs;
  final rxSelectedDate = DateTime.now().obs;
  String? _currentSensorId; // Para recarregar quando a data mudar

  @override
  void onInit() {
    super.onInit();
    getSensors();
    getSilos();
  }

  Future<void> getSensors() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('sensores/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        sensors.assignAll(data.map((json) => SensorModel.fromJson(json)).toList());
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar os sensores');
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
    } catch (e) {
      print('Erro ao carregar silos: $e');
    }
  }

  Future<void> createSensor(SensorModel sensor) async {
    try {
      final response = await _apiService.dio.post('sensores/', data: sensor.toJson());
      if (response.statusCode == 201) {
        getSensors(); // Refresh to get names and related data
        Get.back();
        Get.snackbar('Sucesso', 'Sensor cadastrado');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao cadastrar sensor');
    }
  }

  Future<void> updateSensor(SensorModel sensor) async {
    try {
      final response = await _apiService.dio.put('sensores/${sensor.id}/', data: sensor.toJson());
      if (response.statusCode == 200) {
        getSensors();
        Get.back();
        Get.snackbar('Sucesso', 'Sensor atualizado');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar sensor');
    }
  }

  Future<void> deleteSensor(int id) async {
    try {
      final response = await _apiService.dio.delete('sensores/$id/');
      if (response.statusCode == 204) {
        sensors.removeWhere((s) => s.id == id);
        Get.snackbar('Sucesso', 'Sensor removido');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao remover sensor');
    }
  }

  Future<void> getTelemetry(SensorModel sensor, {bool resetDate = false}) async {
    isLoadingTelemetry.value = true;
    
    if (resetDate) {
       rxSelectedDate.value = DateTime.now();
    }
    
    resetTelemetry(); // Limpa tudo antes de começar a nova busca
    try {
      _currentSensorId = sensor.sensorId;
      final sensorDbId = sensor.id; // ID numérico do banco
      
      final response = await _apiService.dio.get(
        'telemetria/',
        queryParameters: {
          'sensor': sensorDbId, // Parâmetro comum para chaves estrangeiras no Django
          'sensor_id': sensor.sensorId, 
          'sensor_physical_id': sensor.sensorId, 
          'data': DateFormat('yyyy-MM-dd').format(rxSelectedDate.value),
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        telemetry.assignAll(data.map((json) => TelemetryModel.fromJson(json)).toList());
        processTelemetryData();
      }
    } catch (e) {
      print('Erro ao buscar telemetria: $e');
      Get.snackbar('Erro', 'Falha ao buscar histórico de telemetria');
    } finally {
      isLoadingTelemetry.value = false;
    }
  }


  final filteredTelemetryList = <TelemetryModel>[].obs;
  
  final reativeAvgTemp = 0.0.obs;
  final reativeMaxTemp = 0.0.obs;
  final reativeMinTemp = 0.0.obs;
  final reativeAvgHum = 0.0.obs;
  final reativeMaxHum = 0.0.obs;
  final reativeMinHum = 0.0.obs;

  final tempSpots = <FlSpot>[].obs;
  final humSpots = <FlSpot>[].obs;
  final chartLabels = <String>[].obs; // Ex: 10:30, 11:00

  void resetTelemetry() {
    telemetry.clear();
    filteredTelemetryList.clear();
    tempSpots.clear();
    humSpots.clear();
    chartLabels.clear();
    reativeAvgTemp.value = 0;
    reativeMaxTemp.value = 0;
    reativeMinTemp.value = 0;
    reativeAvgHum.value = 0;
    reativeMaxHum.value = 0;
    reativeMinHum.value = 0;
  }

  void processTelemetryData() {
    // Filtrar a lista completa pelo dia selecionado E pelo sensor atual (segurança extra)
    final listFilteredByDate = telemetry.where((t) =>
      t.sensorPhysicalId == _currentSensorId &&
      t.timestamp.year == rxSelectedDate.value.year &&
      t.timestamp.month == rxSelectedDate.value.month &&
      t.timestamp.day == rxSelectedDate.value.day
    ).toList();
    listFilteredByDate.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    filteredTelemetryList.assignAll(listFilteredByDate);

    // Gráfico: apenas leituras do DIA ATUAL e deste sensor, agrupadas em buckets de 30min
    tempSpots.clear();
    humSpots.clear();
    chartLabels.clear();

    final chartData = telemetry.where((t) =>
      t.sensorPhysicalId == _currentSensorId &&
      t.timestamp.year == rxSelectedDate.value.year &&
      t.timestamp.month == rxSelectedDate.value.month &&
      t.timestamp.day == rxSelectedDate.value.day
    ).toList();
    chartData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (chartData.isNotEmpty) {
      for (int i = 0; i < chartData.length; i++) {
        final item = chartData[i];
        final timeLabel = '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';
        
        tempSpots.add(FlSpot(i.toDouble(), item.temperature));
        humSpots.add(FlSpot(i.toDouble(), item.humidity));
        chartLabels.add(timeLabel);
      }
    }

    // Stats gerais do dia selecionado
    if (listFilteredByDate.isNotEmpty) {
      double totalTemp = 0;
      double maxT = listFilteredByDate[0].temperature;
      double minT = listFilteredByDate[0].temperature;
      double totalHum = 0;
      double maxH = listFilteredByDate[0].humidity;
      double minH = listFilteredByDate[0].humidity;

      for (var item in listFilteredByDate) {
        totalTemp += item.temperature;
        totalHum += item.humidity;
        if (item.temperature > maxT) maxT = item.temperature;
        if (item.temperature < minT) minT = item.temperature;
        if (item.humidity > maxH) maxH = item.humidity;
        if (item.humidity < minH) minH = item.humidity;
      }
      reativeAvgTemp.value = totalTemp / listFilteredByDate.length;
      reativeMaxTemp.value = maxT;
      reativeMinTemp.value = minT;
      reativeAvgHum.value = totalHum / listFilteredByDate.length;
      reativeMaxHum.value = maxH;
      reativeMinHum.value = minH;
    } else {
      reativeAvgTemp.value = 0;
      reativeMaxTemp.value = 0;
      reativeMinTemp.value = 0;
      reativeAvgHum.value = 0;
      reativeMaxHum.value = 0;
      reativeMinHum.value = 0;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: rxSelectedDate.value,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != rxSelectedDate.value) {
      rxSelectedDate.value = picked;
      // Precisamos do objeto sensor completo ou apenas o ID dele
      // Para manter o funcionamento, vou buscar o sensor atual na lista de sensores
      if (_currentSensorId != null) {
        final currentSensor = sensors.firstWhereOrNull((s) => s.sensorId == _currentSensorId);
        if (currentSensor != null) {
          getTelemetry(currentSensor, resetDate: false);
        } else {
          processTelemetryData();
        }
      } else {
        processTelemetryData();
      }
    }
  }

  void scanDevices() {
    Get.snackbar(
      'Buscando Dispositivos',
      'Procurando novos hubs e sensores na rede...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue[800],
      icon: const Icon(Icons.search_rounded, color: Colors.blue),
    );
  }
}

