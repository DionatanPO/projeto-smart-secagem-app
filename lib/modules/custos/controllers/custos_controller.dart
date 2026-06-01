import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/processo_model.dart';
import '../../../core/models/batch_model.dart';
import '../../../core/models/secador_model.dart';
import '../../../core/models/custo_processo_model.dart';

class CustosController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final processos = <CustoProcessoModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  Future<void> carregarDados() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _apiService.dio.get('processos/'),
        _apiService.dio.get('lotes/'),
        _apiService.dio.get('secadores/'),
      ]);

      final processosRaw = results[0].data as List;
      final lotesRaw = results[1].data as List;
      final secadoresRaw = results[2].data as List;

      final lotesMap = <int, BatchModel>{};
      for (final l in lotesRaw) {
        final b = BatchModel.fromJson(l);
        if (b.id != null) lotesMap[b.id!] = b;
      }

      final secadoresMap = <int, SecadorModel>{};
      for (final s in secadoresRaw) {
        final sec = SecadorModel.fromJson(s);
        if (sec.id != null) secadoresMap[sec.id!] = sec;
      }

      processos.assignAll(
        processosRaw.map((pJson) {
          final p = ProcessoModel.fromJson(pJson);
          return CustoProcessoModel(
            processo: p,
            lote: p.loteId != null ? lotesMap[p.loteId] : null,
            secador: p.secadorId != null ? secadoresMap[p.secadorId] : null,
          );
        }),
      );
    } on DioException catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar dados: ${e.message}');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar dados');
    } finally {
      isLoading.value = false;
    }
  }

}
