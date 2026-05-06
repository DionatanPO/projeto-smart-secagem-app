import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../farm_management/controllers/farm_management_controller.dart';
import '../../batch_management/controllers/batch_management_controller.dart';
import '../../silo_management/controllers/silo_management_controller.dart';
import '../../secagem/controllers/secagem_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FarmManagementController>(() => FarmManagementController());
    Get.lazyPut<BatchManagementController>(() => BatchManagementController());
    Get.lazyPut<SiloManagementController>(() => SiloManagementController());
    Get.lazyPut<SecagemController>(() => SecagemController());
  }
}
