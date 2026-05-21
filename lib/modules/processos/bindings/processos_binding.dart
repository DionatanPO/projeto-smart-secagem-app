import 'package:get/get.dart';
import '../controllers/processos_controller.dart';
import '../../silo_management/controllers/silo_management_controller.dart';
import '../../batch_management/controllers/batch_management_controller.dart';
import '../../secagem/controllers/secagem_controller.dart';

class ProcessosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SiloManagementController>(() => SiloManagementController());
    Get.lazyPut<BatchManagementController>(() => BatchManagementController());
    Get.lazyPut<SecagemController>(() => SecagemController());
    Get.lazyPut<ProcessosController>(() => ProcessosController());
  }
}
