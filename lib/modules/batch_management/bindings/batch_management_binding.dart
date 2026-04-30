import 'package:get/get.dart';
import '../controllers/batch_management_controller.dart';

class BatchManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BatchManagementController>(
      () => BatchManagementController(),
    );
  }
}
