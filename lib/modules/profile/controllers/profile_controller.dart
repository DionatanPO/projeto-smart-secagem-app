import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();

  final role = ''.obs;
  final notificationsEnabled = true.obs;
  final twoFactorAuth = false.obs;

  final isLoading = true.obs;
  final isSaving = false.obs;

  String get displayName {
    final full = '${firstNameController.text} ${lastNameController.text}'.trim();
    if (full.isNotEmpty) return full;
    return usernameController.text;
  }
  String get initials {
    final first = firstNameController.text.isNotEmpty
        ? firstNameController.text[0]
        : '';
    final last = lastNameController.text.isNotEmpty
        ? lastNameController.text[0]
        : '';
    if (first.isNotEmpty && last.isNotEmpty) return '$first$last'.toUpperCase();
    final u = usernameController.text;
    return u.isNotEmpty ? u[0].toUpperCase() : '?';
  }

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  Future<void> getProfile() async {
    isLoading.value = true;
    try {
      final response = await _api.dio.get('me/');
      final data = response.data;
      usernameController.text = data['username'] ?? '';
      firstNameController.text = data['first_name'] ?? '';
      lastNameController.text = data['last_name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['telefone'] ?? '';
      role.value = data['account_type'] ?? 'Usuário';
    } catch (_) {
      usernameController.text = 'Usuário';
      firstNameController.text = '';
      lastNameController.text = '';
      emailController.text = '';
      phoneController.text = '';
      role.value = 'Usuário';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    isSaving.value = true;
    try {
      await _api.dio.patch('me/', data: {
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'email': emailController.text,
        'telefone': phoneController.text,
      });
      Get.snackbar(
        'Atualizado',
        'As informações do seu perfil foram salvas com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível salvar as alterações.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_rounded, color: Colors.red),
      );
    } finally {
      isSaving.value = false;
    }
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void toggle2FA(bool value) {
    twoFactorAuth.value = value;
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
