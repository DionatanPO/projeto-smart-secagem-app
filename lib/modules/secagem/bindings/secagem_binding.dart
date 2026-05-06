import 'package:get/get.dart';
import '../controllers/secagem_controller.dart';

class SecagemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecagemController>(() => SecagemController());
  }
}
