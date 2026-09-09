import 'sensor_model.dart';
import 'telemetry_model.dart';

enum FireRiskLevel { safe, attention, warning, critical, emergency }

extension FireRiskLevelLabel on FireRiskLevel {
  String get label {
    switch (this) {
      case FireRiskLevel.safe: return 'Seguro';
      case FireRiskLevel.attention: return 'Atenção';
      case FireRiskLevel.warning: return 'Alerta';
      case FireRiskLevel.critical: return 'Crítico';
      case FireRiskLevel.emergency: return 'Emergência';
    }
  }
}

class FireRiskModel {
  final SensorModel sensor;
  final double currentTemp;
  final double? currentGasLevel;
  final double? currentVibration;
  final double temperatureRiseRate;
  final FireRiskLevel level;
  final String message;
  final List<String> recommendations;
  final DateTime timestamp;

  static const double mancalWarning = 75.0;
  static const double mancalCritical = 90.0;
  static const double mancalEmergency = 110.0;
  static const double coWarning = 50.0;
  static const double coCritical = 150.0;
  static const double coEmergency = 400.0;
  static const double riseRateWarning = 2.0;
  static const double riseRateCritical = 5.0;

  FireRiskModel({
    required this.sensor,
    required this.currentTemp,
    this.currentGasLevel,
    this.currentVibration,
    this.temperatureRiseRate = 0,
    required this.level,
    required this.message,
    this.recommendations = const [],
    required this.timestamp,
  });

  String get levelLabel => level.label;

  static FireRiskLevel calculateLevel({
    required double temperature,
    double? gasLevel,
    required double riseRate,
    required String tipo,
  }) {
    int dangerScore = 0;

    if (tipo == SensorModel.tipoMancal) {
      if (temperature >= mancalEmergency) dangerScore += 5;
      else if (temperature >= mancalCritical) dangerScore += 4;
      else if (temperature >= mancalWarning) dangerScore += 2;
    }

    if (tipo == SensorModel.tipoAbafando && gasLevel != null) {
      if (gasLevel >= coEmergency) dangerScore += 5;
      else if (gasLevel >= coCritical) dangerScore += 4;
      else if (gasLevel >= coWarning) dangerScore += 2;
    }

    if (riseRate >= riseRateCritical) dangerScore += 3;
    else if (riseRate >= riseRateWarning) dangerScore += 1;

    if (dangerScore >= 7) return FireRiskLevel.emergency;
    if (dangerScore >= 5) return FireRiskLevel.critical;
    if (dangerScore >= 3) return FireRiskLevel.warning;
    if (dangerScore >= 1) return FireRiskLevel.attention;
    return FireRiskLevel.safe;
  }

  static String buildMessage(FireRiskLevel level, String sensorId, String tipo, double temp, double? gasLevel) {
    final prefix = SensorModel.tipoLabel(tipo);
    switch (level) {
      case FireRiskLevel.safe:
        return '$prefix $sensorId operando normalmente (${temp.toStringAsFixed(1)}°C).';
      case FireRiskLevel.attention:
        return '$prefix $sensorId com temperatura elevada (${temp.toStringAsFixed(1)}°C).';
      case FireRiskLevel.warning:
        return '$prefix $sensorId: temperatura ${temp.toStringAsFixed(1)}°C${gasLevel != null ? ', gás ${gasLevel.toStringAsFixed(0)}ppm' : ''}.';
      case FireRiskLevel.critical:
        return 'ALTA PROBABILIDADE DE INCÊNDIO - $prefix $sensorId a ${temp.toStringAsFixed(1)}°C!';
      case FireRiskLevel.emergency:
        return 'EMERGÊNCIA - $prefix $sensorId ${temp.toStringAsFixed(1)}°C${gasLevel != null ? ', ${gasLevel.toStringAsFixed(0)}ppm CO' : ''}! AÇÃO IMEDIATA!';
    }
  }

  static List<String> buildRecommendations(FireRiskLevel level, String tipo) {
    switch (level) {
      case FireRiskLevel.safe:
        return ['Nenhuma ação necessária.'];
      case FireRiskLevel.attention:
        return [
          'Aumentar frequência de monitoramento do ${SensorModel.tipoLabel(tipo).toLowerCase()}.',
          'Verificar sistema de aeração do secador.',
        ];
      case FireRiskLevel.warning:
        return [
          'Reduzir temperatura da fonte de calor.',
          'Aumentar vazão de ar do sistema de aeração.',
          'Notificar operador responsável.',
        ];
      case FireRiskLevel.critical:
        return [
          'PARAR SECADOR IMEDIATAMENTE.',
          'Acionar sistema de combate a incêndio.',
          'Evacuar área ao redor do secador.',
          'Notificar equipe de emergência.',
          'Abrir registros de alívio de pressão.',
        ];
      case FireRiskLevel.emergency:
        return [
          'PARAR SECADOR AGORA!',
          'DESLIGAR FONTE DE CALOR TOTALMENTE.',
          'ACIONAR CORPO DE BOMBEIROS (193).',
          'ATIVAR SISTEMA DE SUPRESSÃO DE INCÊNDIO.',
          'EVACUAR ÁREA - MANTENHA DISTÂNCIA DE SEGURANÇA.',
          'ISOLAR EQUIPAMENTO E AGUARDAR EQUIPE ESPECIALIZADA.',
        ];
    }
  }

  factory FireRiskModel.fromSensor({
    required SensorModel sensor,
    required TelemetryModel? latestReading,
    required List<TelemetryModel> recentHistory,
  }) {
    final temp = latestReading?.temperature ?? 0;
    final gas = latestReading?.gasLevel;
    final vib = latestReading?.vibration;

    double riseRate = 0;
    if (recentHistory.length >= 2) {
      final sorted = List<TelemetryModel>.from(recentHistory)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final oldest = sorted.first;
      final newest = sorted.last;
      final dt = newest.timestamp.difference(oldest.timestamp).inMinutes;
      if (dt > 0) {
        riseRate = (newest.temperature - oldest.temperature) / dt;
      }
    }

    final level = calculateLevel(temperature: temp, gasLevel: gas, riseRate: riseRate, tipo: sensor.tipo);
    return FireRiskModel(
      sensor: sensor,
      currentTemp: temp,
      currentGasLevel: gas,
      currentVibration: vib,
      temperatureRiseRate: riseRate,
      level: level,
      message: buildMessage(level, sensor.sensorId, sensor.tipo, temp, gas),
      recommendations: buildRecommendations(level, sensor.tipo),
      timestamp: latestReading?.timestamp ?? DateTime.now(),
    );
  }
}