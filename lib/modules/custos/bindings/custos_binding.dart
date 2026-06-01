import 'package:get/get.dart';
import '../controllers/custos_controller.dart';

class CustosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustosController>(() => CustosController());
  }
}
