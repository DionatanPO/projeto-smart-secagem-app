import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'api_service.dart';

class AuthService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final _storage = const FlutterSecureStorage();
  
  final isAuthenticated = false.obs;

  Future<AuthService> init() async {
    final token = await _storage.read(key: 'token');
    isAuthenticated.value = token != null;
    return this;
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.dio.post(
        'login/',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'token', value: token);
        isAuthenticated.value = true;
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errorMessage = 'Erro ao realizar login';
      if (e.response != null) {
        errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      throw errorMessage;
    } catch (e) {
      throw 'Ocorreu um erro inesperado';
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.dio.post('logout/');
    } catch (_) {
    } finally {
      await _storage.delete(key: 'token');
      isAuthenticated.value = false;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}
