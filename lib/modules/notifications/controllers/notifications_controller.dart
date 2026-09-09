import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';

class NotificationsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final notifications = <Map<String, dynamic>>[].obs;
  final selectedFilter = 'Todos'.obs;
  final filters = ['Todos', 'Críticos', 'Alertas', 'Sistema'];
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<Map<String, dynamic>> get filteredNotifications {
    final all = notifications;
    if (selectedFilter.value == 'Todos') return all;
    if (selectedFilter.value == 'Críticos')
      return all.where((n) => n['type'] == 'Critical').toList();
    if (selectedFilter.value == 'Alertas')
      return all.where((n) => n['type'] == 'Warning').toList();
    if (selectedFilter.value == 'Sistema')
      return all
          .where((n) => n['type'] == 'System' || n['type'] == 'Info')
          .toList();
    return all;
  }

  int get unreadCount => notifications.where((n) => !(n['isRead'] as bool)).length;

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('notificacoes/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        notifications.assignAll(data.map((json) => {
          'id': json['id'].toString(),
          'title': json['titulo'],
          'description': json['descricao'],
          'time': _formatTime(json['created_at']),
          'type': json['tipo'],
          'icon': _iconFromName(json['icone']),
          'color': _colorFromName(json['cor']),
          'isRead': json['is_read'] ?? false,
          'target': json['target'] ?? '',
        }).toList());
      }
    } catch (e) {
      debugPrint('Erro ao carregar notificacoes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(notifications[index]);
      updated['isRead'] = true;
      notifications[index] = updated;
    }
    try {
      await _apiService.dio.post('notificacoes/marcar_lida/', data: {'id': int.parse(id)});
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < notifications.length; i++) {
      if (!(notifications[i]['isRead'] as bool)) {
        final updated = Map<String, dynamic>.from(notifications[i]);
        updated['isRead'] = true;
        notifications[i] = updated;
      }
    }
    try {
      await _apiService.dio.post('notificacoes/marcar_todas_lidas/');
    } catch (_) {}
  }

  Future<void> clearAll() async {
    notifications.clear();
    try {
      await _apiService.dio.post('notificacoes/limpar/');
    } catch (_) {}
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Agora';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min atrás';
      if (diff.inHours < 24) return '${diff.inHours}h atrás';
      return '${diff.inDays}d atrás';
    } catch (_) {
      return '';
    }
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'local_fire_department_rounded': return Icons.local_fire_department_rounded;
      case 'warning_rounded': return Icons.warning_rounded;
      case 'timer_off_rounded': return Icons.timer_off_rounded;
      case 'play_circle_outline_rounded': return Icons.play_circle_outline_rounded;
      case 'pause_circle_outline_rounded': return Icons.pause_circle_outline_rounded;
      case 'assignment_rounded': return Icons.assignment_rounded;
      case 'bedtime_rounded': return Icons.bedtime_rounded;
      case 'notifications_rounded': return Icons.notifications_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorFromName(String? name) {
    switch (name) {
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'grey': return Colors.grey;
      default: return Colors.blue;
    }
  }
}