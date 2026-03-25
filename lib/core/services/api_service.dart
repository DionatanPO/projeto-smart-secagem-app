import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import '../../routes/app_routes.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  static const String baseUrlReal = 'https://apismart.secagemdigital.com/api/';
  static const String baseUrlEmulator = 'http://10.0.2.2:8000/api/';
  static const String baseUrlLocal = 'http://localhost:8000/api/';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrlReal,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Token $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            final authService = Get.find<AuthService>();
            authService.logout();
            Get.offAllNamed(Routes.login);
            // Evitar múltiplos snacks se houver várias chamadas falhando
            if (!Get.isSnackbarOpen) {
              Get.snackbar(
                'Sessão Expirada',
                'Por favor, faça login novamente',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Dio get dio => _dio;
}
