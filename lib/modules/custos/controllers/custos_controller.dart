import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/custo_processo_model.dart';
import '../../../core/models/secador_model.dart';

class CustosController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final processos = <CustoProcessoModel>[].obs;
  final filtered = <CustoProcessoModel>[].obs;
  final isLoading = false.obs;

  // Filters
  final selectedSecadorId = Rx<int?>(null);
  final dataInicio = Rx<DateTime?>(null);
  final dataFim = Rx<DateTime?>(null);

  // Secadores for filter dropdown
  final secadores = <SecadorModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  Future<void> carregarDados() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _apiService.dio.get('custos/secagem/'),
        _apiService.dio.get('secadores/'),
      ]);

      final raw = results[0].data as List;
      processos.assignAll(raw.map((j) => CustoProcessoModel.fromJson(j)));

      final secRaw = results[1].data as List;
      secadores.assignAll(secRaw.map((j) => SecadorModel.fromJson(j)));

      aplicarFiltros();
    } on DioException catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar dados: ${e.message}');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar dados');
    } finally {
      isLoading.value = false;
    }
  }

  void aplicarFiltros() {
    filtered.assignAll(processos.where((p) {
      if (selectedSecadorId.value != null && p.secadorId != selectedSecadorId.value) {
        return false;
      }
      if (dataInicio.value != null && p.dataInicio.isBefore(dataInicio.value!)) {
        return false;
      }
      if (dataFim.value != null && p.dataInicio.isAfter(dataFim.value!)) {
        return false;
      }
      return true;
    }));
  }

  void setSecador(int? id) {
    selectedSecadorId.value = id;
    aplicarFiltros();
  }

  void setDataInicio(DateTime? d) {
    dataInicio.value = d;
    aplicarFiltros();
  }

  void setDataFim(DateTime? d) {
    dataFim.value = d;
    aplicarFiltros();
  }

  void limparFiltros() {
    selectedSecadorId.value = null;
    dataInicio.value = null;
    dataFim.value = null;
    aplicarFiltros();
  }

  // Aggregated totals
  double get totalGeral => filtered.fold(0, (sum, p) => sum + p.custoTotal);
  double get totalCombustivel => filtered.fold(0, (sum, p) => sum + p.custoCombustivel);
  double get totalEnergia => filtered.fold(0, (sum, p) => sum + p.custoEnergia);
  double get totalMaoObra => filtered.fold(0, (sum, p) => sum + p.custoMaoObra);
  double get totalManutencao => filtered.fold(0, (sum, p) => sum + p.custoManutencao);
  double get totalDepreciacao => filtered.fold(0, (sum, p) => sum + p.custoDepreciacao);
  double get totalHoras => filtered.fold(0, (sum, p) => sum + p.duracaoHoras);
  int get totalProcessos => filtered.length;
}
