import 'package:get/get.dart';
import '../controllers/custos_de_producao_controller.dart';

class CustosDeProducaoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustosDeProducaoController>(
      () => CustosDeProducaoController(),
    );
  }
}
