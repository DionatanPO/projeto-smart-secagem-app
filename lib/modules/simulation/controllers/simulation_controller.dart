import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';

class SimulationController extends GetxController {
  // Clima Externo
  final externalTemp = 25.0.obs;
  final externalHum = 65.0.obs;

  // Massa de Grãos (Interno)
  final internalTemp = 35.0.obs;
  final internalHum = 16.0.obs;

  // Estado dos Atuadores
  final isAerationOn = false.obs;
  final isPlaying = false.obs;

  // Relógio do Simulador
  final simulationTime = 8.obs; // Hora do dia
  Timer? _timer;

  // Estado Visual do Silo
  final siloColor = const Color(0xFF10B981).obs; // Default Verde
  final siloStatusMessage = 'Temperatura Ideal'.obs;
  final actionReason =
      'Aguardando avaliação do clima logo após a inicialização...'.obs;

  // Histórico para o Gráfico
  final historyLogs = <Map<String, dynamic>>[].obs;

  // Log de Ações
  final logs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    addLog("Simulador de Aeração pronto para iniciar.");
  }

  void addLog(String message) {
    logs.insert(
        0, "[${simulationTime.value.toString().padLeft(2, '0')}:00] $message");
    if (logs.length > 50) logs.removeLast();
  }

  void toggleSimulation() {
    isPlaying.value = !isPlaying.value;
    if (isPlaying.value) {
      addLog("▶ Simulação iniciada automaticamente.");
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _tick();
      });
    } else {
      addLog("⏸ Simulação pausada.");
      _timer?.cancel();
    }
  }

  void advanceOneHour() {
    addLog("🕒 Avançando 1 hora manualmente...");
    _tick();
  }

  void resetSimulation() {
    isPlaying.value = false;
    _timer?.cancel();
    externalTemp.value = 25.0;
    externalHum.value = 65.0;
    internalTemp.value = 35.0;
    internalHum.value = 16.0;
    simulationTime.value = 8;
    isAerationOn.value = false;
    logs.clear();
    historyLogs.clear();
    addLog("Simulador resetado para valores padrão.");
  }

  void setManualWeather(double temp, double hum) {
    externalTemp.value = temp;
    externalHum.value = hum;
    addLog(
        "Clima alterado manualmente: ${temp.toStringAsFixed(1)}°C / ${hum.toStringAsFixed(1)}%");
    _evaluateConditions();
  }

  void _tick() {
    // Avança 1 hora no relógio do simulador
    simulationTime.value = (simulationTime.value + 1) % 24;

    // Curva climática realista ao longo do dia
    final random = Random();
    if (simulationTime.value >= 6 && simulationTime.value <= 15) {
      // Dia esquentando e secando
      externalTemp.value += 1.5 + random.nextDouble();
      externalHum.value -= 2.0 + random.nextDouble();
    } else {
      // Noite esfriando e umidificando
      externalTemp.value -= 1.0 + random.nextDouble();
      externalHum.value += 1.5 + random.nextDouble();
    }

    _evaluateConditions();

    // Efeito na massa de grãos (Simulação termodinâmica simples)
    if (isAerationOn.value) {
      // Resfriamento pela aeração
      internalTemp.value -= 0.8;
      // Leve secagem
      internalHum.value -= 0.1;
    } else {
      // Pequeno aquecimento biológico se não estiver aerando (grão vivo)
      if (internalTemp.value < 45) {
        internalTemp.value += 0.2;
      }
    }

    // Travas de limite
    externalTemp.value = externalTemp.value.clamp(10.0, 42.0);
    externalHum.value = externalHum.value.clamp(30.0, 98.0);
    internalTemp.value = internalTemp.value.clamp(15.0, 50.0);
    internalHum.value = internalHum.value.clamp(10.0, 25.0);

    // Registra no histórico para o gráfico (mantém as últimas 24 horas simuladas)
    historyLogs.add({
      'time': simulationTime.value,
      'extTemp': externalTemp.value,
      'intTemp': internalTemp.value,
      'aerationOn': isAerationOn.value,
    });
    if (historyLogs.length > 24) {
      historyLogs.removeAt(0);
    }
  }

  void _evaluateConditions() {
    // 1. Atualizar Cor do Silo e Mensagem de Status com base na Temperatura Interna
    if (internalTemp.value >= 40.0) {
      siloColor.value = Colors.red[600]!;
      siloStatusMessage.value = 'Risco Crítico (Hotspot)';
    } else if (internalTemp.value >= 32.0) {
      siloColor.value = Colors.orange[500]!;
      siloStatusMessage.value = 'Alerta Térmico (Aquecendo)';
    } else {
      siloColor.value = const Color(0xFF10B981); // Verde Ideal
      siloStatusMessage.value = 'Massa Estável e Segura';
    }

    // Regra de Aeração Inteligente do Smart Sense:
    // Ligar APENAS SE: Temperatura Externa < Temperatura Interna (com margem de segurança)
    // E Umidade Externa < 75% (para não re-umedecer o grão seco)
    bool goodTemperature = externalTemp.value < (internalTemp.value - 3);
    bool goodHumidity = externalHum.value < 75.0;
    bool idealConditions = goodTemperature && goodHumidity;

    if (idealConditions && !isAerationOn.value) {
      isAerationOn.value = true;
      actionReason.value =
          'T. Externa é menor que a T. Interna e Umidade Segura. Aeração LIGADA para resfriar os grãos.';
      addLog(
          "🟢 Condições favoráveis! Motores LIGADOS. (T.Ext menor e Umidade segura)");
    } else if (!idealConditions && isAerationOn.value) {
      isAerationOn.value = false;
      addLog(
          "🔴 Clima desfavorável. Motores DESLIGADOS para proteger os grãos.");
    }

    // Atualiza a razão sempre se a aeração estiver sendo evitada ou aplicada
    if (!idealConditions) {
      if (!goodTemperature && !goodHumidity) {
        actionReason.value =
            'Motores DESLIGADOS: T. Externa muito alta e Umidade elevada (Risco de molhar a massa).';
      } else if (!goodTemperature) {
        actionReason.value =
            'Motores DESLIGADOS: T. Externa está mais quente que os grãos (Aqueceria a massa se ligar).';
      } else if (!goodHumidity) {
        actionReason.value =
            'Motores DESLIGADOS: T. Externa ideal, mas Umidade excessiva > 75% (Risco de reumidificar os grãos).';
      }
    } else {
      if (isAerationOn.value) {
        siloColor.value = Colors.blue[400]!; // Azul demonstrando aeração ativa
        siloStatusMessage.value = 'Aeração Ativa (Resfriando)';
      }
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
