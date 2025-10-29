import 'package:flutter/foundation.dart';

@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.scheduledAt,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;

  bool get isPending => DateTime.now().isBefore(scheduledAt);

  Reminder copyWith({String? id, String? title, DateTime? scheduledAt}) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Reminder &&
        other.id == id &&
        other.title == title &&
        other.scheduledAt == scheduledAt;
  }

  @override
  int get hashCode => Object.hash(id, title, scheduledAt);
}
