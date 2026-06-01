import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/bindings/dashboard_binding.dart';
import '../../unidade_armazenadora_management/controllers/unidade_armazenadora_management_controller.dart';
import '../../batch_management/controllers/batch_management_controller.dart';
import '../../silo_management/controllers/silo_management_controller.dart';
import '../../secagem/controllers/secagem_controller.dart';
import '../../processos/controllers/processos_controller.dart';
import '../../clientes/controllers/clientes_controller.dart';
import '../../custos/controllers/custos_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<UnidadeArmazenadoraManagementController>(() => UnidadeArmazenadoraManagementController());
    Get.lazyPut<BatchManagementController>(() => BatchManagementController());
    Get.lazyPut<SiloManagementController>(() => SiloManagementController());
    Get.lazyPut<SecagemController>(() => SecagemController());
    Get.lazyPut<ProcessosController>(() => ProcessosController());
    Get.lazyPut<ClientesController>(() => ClientesController());
    Get.lazyPut<CustosController>(() => CustosController());
    DashboardBinding().dependencies();
  }
}
