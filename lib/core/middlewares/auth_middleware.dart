import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthService>()) {
      return null;
    }
    try {
      final authService = Get.find<AuthService>();
      if (!authService.isAuthenticated.value) {
        return const RouteSettings(name: Routes.login);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
