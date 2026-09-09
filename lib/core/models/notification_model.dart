import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final String type;
  final IconData icon;
  final Color color;
  final bool isRead;
  final String target;
  final String dedupKey;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.icon,
    required this.color,
    this.isRead = false,
    required this.target,
    required this.dedupKey,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      description: description,
      time: time,
      type: type,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
      target: target,
      dedupKey: dedupKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': timeAgo(time),
      'type': type,
      'icon': icon,
      'color': color,
      'isRead': isRead,
      'target': target,
    };
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }
}