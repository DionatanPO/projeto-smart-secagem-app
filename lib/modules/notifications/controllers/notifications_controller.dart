import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  // Mock data for notifications/logs
  final notifications = <Map<String, dynamic>>[
    {
      'id': '1',
      'title': 'Hotspot Detectado',
      'description':
          'O Silo 04 apresentou uma diferença de temperatura de 5.8°C entre o meio e a base.',
      'time': '5 min atrás',
      'type': 'Critical', // Critical, Warning, Info, System
      'icon': Icons.report_problem_rounded,
      'color': Colors.red,
      'isRead': false,
      'target': 'Silo 04',
    },
    {
      'id': '2',
      'title': 'Aeração Iniciada',
      'description':
          'O sistema de ventilação do Silo 01 foi acionado manualmente.',
      'time': '12 min atrás',
      'type': 'Info',
      'icon': Icons.air_rounded,
      'color': Colors.blue,
      'isRead': true,
      'target': 'Silo 01',
    },
    {
      'id': '3',
      'title': 'Bateria Baixa',
      'description': 'O sensor SN-LVL-01 (Silo 01) está com 15% de bateria.',
      'time': '1 hora atrás',
      'type': 'Warning',
      'icon': Icons.battery_alert_rounded,
      'color': Colors.orange,
      'isRead': false,
      'target': 'Dispositivos',
    },
    {
      'id': '4',
      'title': 'Hub Offline',
      'description': 'A Central de Secagem B perdeu a conexão com o servidor.',
      'time': '2 horas atrás',
      'type': 'Critical',
      'icon': Icons.router_rounded,
      'color': Colors.red,
      'isRead': false,
      'target': 'HUBS',
    },
    {
      'id': '5',
      'title': 'Aeração Automática',
      'description':
          'O sistema desligou a aeração do Silo 02 após atingir o setpoint de umidade.',
      'time': '4 horas atrás',
      'type': 'System',
      'icon': Icons.settings_suggest_rounded,
      'color': Colors.green,
      'isRead': true,
      'target': 'Silo 02',
    },
  ].obs;

  final selectedFilter = 'Todos'.obs;
  final filters = ['Todos', 'Críticos', 'Alertas', 'Sistema'];

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter.value == 'Todos') return notifications;
    if (selectedFilter.value == 'Críticos')
      return notifications.where((n) => n['type'] == 'Critical').toList();
    if (selectedFilter.value == 'Alertas')
      return notifications.where((n) => n['type'] == 'Warning').toList();
    if (selectedFilter.value == 'Sistema')
      return notifications
          .where((n) => n['type'] == 'System' || n['type'] == 'Info')
          .toList();
    return notifications;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(notifications[index]);
      updated['isRead'] = true;
      notifications[index] = updated;
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      if (!(notifications[i]['isRead'] as bool)) {
        final updated = Map<String, dynamic>.from(notifications[i]);
        updated['isRead'] = true;
        notifications[i] = updated;
      }
    }
  }

  void clearAll() {
    notifications.clear();
  }
}
