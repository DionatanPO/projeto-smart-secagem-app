import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void logout() async {
    final authService = Get.find<AuthService>();
    await authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
