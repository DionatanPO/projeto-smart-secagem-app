import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController(text: 'João Silva');
  final emailController = TextEditingController(text: 'joao.silva@fazenda.com');
  final phoneController = TextEditingController(text: '(11) 99999-9999');

  final role = 'Administrador do Sistema'.obs;
  final notificationsEnabled = true.obs;
  final twoFactorAuth = false.obs;

  final isSaving = false.obs;

  void saveProfile() async {
    isSaving.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simula requisição
    isSaving.value = false;

    Get.snackbar(
      'Atualizado',
      'As informações do seu perfil foram salvas com sucesso.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green[800],
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
    );
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void toggle2FA(bool value) {
    twoFactorAuth.value = value;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
