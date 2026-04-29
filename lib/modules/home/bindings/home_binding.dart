import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../farm_management/controllers/farm_management_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FarmManagementController>(() => FarmManagementController());
  }
}
