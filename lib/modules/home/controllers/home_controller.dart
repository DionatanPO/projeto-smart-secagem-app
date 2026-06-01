import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final accountType = ''.obs;
  final currentUserFarmId = Rx<int?>(null);

  final ApiService _api = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final response = await _api.dio.get('me/');
      accountType.value = response.data['account_type'] ?? '';
      currentUserFarmId.value = response.data['unidade_armazenadora'] as int?;
    } catch (_) {}
  }

  bool get isSuperAdmin => accountType.value == 'super_admin';
  bool get isAdmin => accountType.value == 'admin' || accountType.value == 'super_admin';
  bool get isOperator => accountType.value == 'operador';
  bool get isViewer => accountType.value == 'visualizador';
  bool get canManageUsers => isAdmin;

  void changePage(int index) {
    if (index == 7 && !canManageUsers) return;
    selectedIndex.value = index;
  }

  void logout() async {
    final authService = Get.find<AuthService>();
    await authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
