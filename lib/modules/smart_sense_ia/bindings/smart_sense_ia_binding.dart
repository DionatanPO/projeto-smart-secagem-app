import 'package:get/get.dart';
import '../controllers/smart_sense_ia_controller.dart';

class SmartSenseIABinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SmartSenseIAController>(() => SmartSenseIAController());
  }
}
