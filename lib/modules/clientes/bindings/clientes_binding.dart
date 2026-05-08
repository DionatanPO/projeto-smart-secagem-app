import 'package:get/get.dart';
import '../controllers/clientes_controller.dart';

class ClientesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientesController>(() => ClientesController());
  }
}
