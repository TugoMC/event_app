import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String type;
  final IconData icon;

  Activity({
    required this.id,
    required this.type,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'icon': icon.codePoint,
        'icon_family': icon.fontFamily,
      };

  factory Activity.fromJson(Map<String, dynamic> json, [String? documentId]) =>
      Activity(
        id: documentId ??
            json['id'] ??
            '', // Utiliser documentId s'il est fourni
        type: json['type'] as String,
        icon: IconData(
          json['icon'] as int,
          fontFamily: json['icon_family'] as String? ?? 'MaterialIcons',
        ),
      );

  Activity copyWith({
    String? id,
    String? type,
    IconData? icon,
  }) {
    return Activity(
      id: id ?? this.id,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
