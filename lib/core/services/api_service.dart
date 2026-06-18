import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../../routes/app_routes.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  static const String baseUrl = 'http://localhost:8000/api/';
  static const String baseUrlAI = 'https://ai.secagemdigital.com/api/';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
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
  }

  Dio get dio => _dio;

  Future<Map<String, dynamic>> fetchContext() async {
    final response = await _dio.get('contexto/');
    return response.data as Map<String, dynamic>;
  }

  static String extractRespostaOuResumo(String raw) {
    raw = raw.trim();

    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map) {
        final v = parsed['resposta'] ?? parsed['resumo'];
        if (v is String) return v;
      }
    } catch (_) {}

    for (final key in ['resposta', 'resumo']) {
      final keyIdx = raw.indexOf('"$key"');
      if (keyIdx == -1) continue;
      final colonIdx = raw.indexOf(':', keyIdx);
      if (colonIdx == -1) continue;
      final valStart = raw.indexOf('"', colonIdx);
      if (valStart == -1) continue;

      bool escaped = false;
      for (int i = valStart + 1; i < raw.length; i++) {
        if (escaped) { escaped = false; continue; }
        if (raw[i] == '\\') { escaped = true; continue; }
        if (raw[i] == '"') {
          return raw.substring(valStart + 1, i)
              .replaceAll('\\n', '\n')
              .replaceAll('\\"', '"')
              .replaceAll('\\\\', '\\');
        }
      }
    }
    return raw;
  }

  static String? extractContent(Map<String, dynamic> event) {
    if (event['data'] is String) return event['data'] as String;
    if (event['resposta'] is String) return event['resposta'] as String;
    if (event['content'] is String) return event['content'] as String;
    if (event['response'] is String) return event['response'] as String;
    if (event['text'] is String) return event['text'] as String;
    if (event['message'] is String) return event['message'] as String;
    if (event['choices'] is List) {
      final choices = event['choices'] as List;
      if (choices.isNotEmpty && choices[0] is Map) {
        final choice = choices[0] as Map;
        if (choice['delta'] is Map) {
          final delta = choice['delta'] as Map;
          if (delta['content'] is String) return delta['content'] as String;
        }
        if (choice['text'] is String) return choice['text'] as String;
      }
    }
    return null;
  }

  Stream<Map<String, dynamic>> postStream(String endpoint, Map<String, dynamic> data) async* {
    final url = Uri.parse(baseUrlAI + endpoint);
    final client = http.Client();

    try {
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(data);

      final response = await client.send(request);

      if (response.statusCode == 200) {
        await for (final line in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
          if (line.trim().isEmpty) continue;
          String cleaned = line.trim();
          if (cleaned.startsWith('data:')) {
            cleaned = cleaned.substring(5).trim();
          }
          if (cleaned == '[DONE]') continue;
          try {
            yield jsonDecode(cleaned) as Map<String, dynamic>;
          } catch (e) {
            yield {"type": "error", "content": "Erro ao decodificar JSON"};
          }
        }
      } else {
        yield {"type": "error", "content": "Erro na conexão: ${response.statusCode}"};
      }
    } finally {
      client.close();
    }
  }
}
