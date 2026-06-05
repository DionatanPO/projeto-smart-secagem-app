import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/resumo_model.dart';

enum DashboardStatus { idle, loading, success, error }

class DashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final status = DashboardStatus.idle.obs;
  final responseTime = ''.obs;
  final modelResponse = Rxn<ResumoModel>();
  final errorMessage = ''.obs;
  final lastUpdated = Rxn<DateTime>();

  StreamSubscription<Map<String, dynamic>>? _streamSubscription;

  bool get isLoading => status.value == DashboardStatus.loading;
  bool get hasError => status.value == DashboardStatus.error;
  bool get hasData => status.value == DashboardStatus.success;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  @override
  void onClose() {
    _streamSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchDashboardData() async {
    if (isLoading) return;

    status.value = DashboardStatus.loading;
    errorMessage.value = '';

    final stopwatch = Stopwatch()..start();
    final buffer = StringBuffer();
    final completer = Completer<void>();

    _streamSubscription = _apiService.postStream('chat-stream/', {
      'prompt': 'Forneça um resumo operacional em texto Markdown, com tabelas onde aplicável. Ao final, detecte possíveis anomalias.',
      'use_rag': false,
    }).listen(
      (event) {
        final content = ApiService.extractContent(event);

        if (event['type'] == 'error') {
          errorMessage.value = event['content'] as String? ?? 'Erro ao consultar IA.';
          status.value = DashboardStatus.error;
          if (!completer.isCompleted) completer.complete();
          return;
        }

        if (content != null && content.isNotEmpty) {
          buffer.write(content);
        }
      },
      onError: (e) {
        errorMessage.value = 'Erro na transmissão dos dados.';
        status.value = DashboardStatus.error;
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        stopwatch.stop();
        responseTime.value = _formatResponseTime(stopwatch.elapsedMilliseconds);

        String rawResult = buffer.toString().trim();
        
        if (rawResult.isEmpty) {
          errorMessage.value = 'Resposta vazia da IA.';
          status.value = DashboardStatus.error;
          if (!completer.isCompleted) completer.complete();
          return;
        }

        // Tenta decodificar o resultado como JSON se for um JSON string
        dynamic decoded;
        try {
          if (rawResult.startsWith('{') || rawResult.startsWith('[')) {
            decoded = jsonDecode(rawResult);
          }
        } catch (e) {
          // Se falhar ao decodificar, trata como texto puro
        }

        // Constrói o modelo com tratamento seguro
        if (decoded is Map<String, dynamic>) {
          modelResponse.value = ResumoModelX.fromJson(decoded);
        } else {
          // Se não foi um JSON válido, ou era um tipo inesperado, usa rawResult
          modelResponse.value = ResumoModel(resposta: rawResult);
        }
        
        lastUpdated.value = DateTime.now();
        status.value = DashboardStatus.success;

        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }

  String _formatResponseTime(int ms) {
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }

  @override
  void refresh() => fetchDashboardData();
}
