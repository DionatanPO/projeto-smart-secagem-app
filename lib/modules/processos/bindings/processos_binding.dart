import 'package:get/get.dart';
import '../controllers/processos_controller.dart';

class ProcessosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcessosController>(() => ProcessosController());
  }
}
