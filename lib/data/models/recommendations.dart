import 'package:event_app/data/models/event_space.dart';

class Recommendations {
  final String id;
  final List<EventSpaceOrder> eventSpaces; // Changement ici
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final int version;
  bool isActive;
  final int order;

  Recommendations({
    String? id,
    required this.eventSpaces,
    DateTime? createdAt,
    this.updatedAt,
    required this.userId,
    this.version = 1,
    this.isActive = false,
    this.order = 0,
  })  : id = id ?? DateTime.now().toIso8601String(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventSpaces':
            eventSpaces.map((es) => es.toJson()).toList(), // Modification
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'userId': userId,
        'version': version,
        'isActive': isActive,
        'order': order,
      };

  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      id: json['id'],
      eventSpaces: (json['eventSpaces'] as List)
          .map((esJson) => EventSpaceOrder.fromJson(esJson))
          .toList(), // Modification
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      userId: json['userId'],
      version: json['version'] ?? 1,
      isActive: json['isActive'] ?? false,
      order: json['order'] ?? 0,
    );
  }

  Recommendations copyWith({
    String? id,
    List<EventSpaceOrder>? eventSpaces, // Modification
    DateTime? updatedAt,
    bool? isActive,
    int? order,
  }) {
    return Recommendations(
      id: id ?? this.id,
      eventSpaces: eventSpaces ?? this.eventSpaces,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      userId: userId,
      version: version + 1,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }
}

// Nouvelle classe pour gérer l'ordre des EventSpaces
class EventSpaceOrder {
  final EventSpace eventSpace;
  final int order;

  EventSpaceOrder({
    required this.eventSpace,
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'eventSpace': eventSpace.toJson(),
        'order': order,
      };

  factory EventSpaceOrder.fromJson(Map<String, dynamic> json) {
    return EventSpaceOrder(
      eventSpace: EventSpace.fromJson(json['eventSpace']),
      order: json['order'] ?? 0,
    );
  }

  EventSpaceOrder copyWith({
    EventSpace? eventSpace,
    int? order,
  }) {
    return EventSpaceOrder(
      eventSpace: eventSpace ?? this.eventSpace,
      order: order ?? this.order,
    );
  }
}
