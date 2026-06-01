import 'package:get/get.dart';
import '../controllers/unidade_armazenadora_management_controller.dart';

class UnidadeArmazenadoraManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnidadeArmazenadoraManagementController>(() => UnidadeArmazenadoraManagementController());
  }
}
