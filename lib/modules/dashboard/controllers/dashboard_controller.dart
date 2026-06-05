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
  final thoughtContent = ''.obs;
  final metricsData = RxMap<String, dynamic>();

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
    thoughtContent.value = '';
    metricsData.clear();
    modelResponse.value = null;

    final stopwatch = Stopwatch()..start();
    final completer = Completer<void>();
    var fullResponse = '';

    Map<String, dynamic>? contexto;
    try {
      contexto = await _apiService.fetchContext();
    } catch (_) {}

    final prompt = contexto != null
        ? '<contexto_operacional>\n${jsonEncode(contexto)}\n</contexto_operacional>\n\n'
          'Com base no contexto operacional acima, analise os dados e faça um resumo.'
        : 'oi';

    _streamSubscription = _apiService.postStream('chat-stream/', {
      'prompt': prompt,
      'use_rag': false,
    }).listen(
      (event) {
        final eventType = event['event'] as String?;

        switch (eventType) {
          case 'message':
            final data = event['data'] as String?;
            if (data != null && data.isNotEmpty) {
              fullResponse += data;
              modelResponse.value = ResumoModel(resposta: fullResponse);
            }
            break;
          case 'thought':
            final data = event['data'] as String?;
            if (data != null && data.isNotEmpty) {
              thoughtContent.value = data;
            }
            break;
          case 'metrics':
            final data = event['data'];
            if (data is Map) {
              metricsData.assignAll(Map<String, dynamic>.from(data));
            }
            break;
          case 'error':
            errorMessage.value = event['data'] as String? ?? 'Erro ao consultar IA.';
            status.value = DashboardStatus.error;
            if (!completer.isCompleted) completer.complete();
            break;
          case 'done':
            break;
          default:
            final content = ApiService.extractContent(event);
            if (content != null && content.isNotEmpty) {
              fullResponse += content;
              modelResponse.value = ResumoModel(resposta: fullResponse);
            }
            if (event['type'] == 'error') {
              errorMessage.value = event['content'] as String? ?? 'Erro ao consultar IA.';
              status.value = DashboardStatus.error;
              if (!completer.isCompleted) completer.complete();
            }
            break;
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
