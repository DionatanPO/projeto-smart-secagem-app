import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

enum DashboardStatus { idle, loading, success, error }

class DashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final status = DashboardStatus.idle.obs;
  final responseTime = ''.obs;
  final modelResponse = ''.obs;
  final errorMessage = ''.obs;
  final lastUpdated = Rxn<DateTime>();

  bool get isLoading => status.value == DashboardStatus.loading;
  bool get hasError => status.value == DashboardStatus.error;
  bool get hasData => status.value == DashboardStatus.success;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    if (isLoading) return;

    status.value = DashboardStatus.loading;
    errorMessage.value = '';

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _apiService.dio.post('chat/', data: {
        'prompt': 'Forneça um resumo operacional do dia em texto livre, sem formatação JSON. Ao final, detecte possíveis anomalias com base nos dados disponíveis.',
        'use_rag': false,
      });

      stopwatch.stop();
      responseTime.value = _formatResponseTime(stopwatch.elapsedMilliseconds);

      if (response.statusCode == 200) {
        final data = response.data;

        modelResponse.value =
            data['response'] as String? ??
            data['message'] as String? ??
            data['text'] as String? ??
            'Resposta não disponível.';

        lastUpdated.value = DateTime.now();
        status.value = DashboardStatus.success;
      } else {
        throw Exception('Status inesperado: ${response.statusCode}');
      }
    } on DioException catch (e) {
      stopwatch.stop();
      errorMessage.value = _handleDioError(e);
      status.value = DashboardStatus.error;
    } catch (e) {
      stopwatch.stop();
      errorMessage.value = 'Erro inesperado. Tente novamente.';
      status.value = DashboardStatus.error;
    }
  }

  String _formatResponseTime(int ms) {
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão esgotado. Verifique sua rede.';
      case DioExceptionType.connectionError:
        return 'Sem conexão com o servidor.';
      case DioExceptionType.badResponse:
        return 'Erro no servidor (${e.response?.statusCode}).';
      default:
        return 'Erro de comunicação com a API.';
    }
  }

  Future<void> refresh() => fetchDashboardData();
}
