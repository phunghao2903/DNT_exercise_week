import 'package:flutter/foundation.dart';

import '../models/reminder.dart';

class ReminderRepository {
  ReminderRepository();

  final ValueNotifier<List<Reminder>> _reminders =
      ValueNotifier<List<Reminder>>(<Reminder>[]);

  ValueListenable<List<Reminder>> get reminders => _reminders;

  List<Reminder> all() => List<Reminder>.unmodifiable(_reminders.value);

  void add(Reminder reminder) {
    final List<Reminder> updated = List<Reminder>.from(_reminders.value)
      ..add(reminder);
    _emitSorted(updated);
  }

  void update(Reminder reminder) {
    final List<Reminder> updated = List<Reminder>.from(_reminders.value);
    final int index = updated.indexWhere(
      (Reminder element) => element.id == reminder.id,
    );
    if (index == -1) {
      return;
    }
    updated[index] = reminder;
    _emitSorted(updated);
  }

  void remove(String id) {
    final List<Reminder> updated = List<Reminder>.from(_reminders.value)
      ..removeWhere((Reminder reminder) => reminder.id == id);
    _reminders.value = List<Reminder>.unmodifiable(updated);
  }

  void clear() {
    _reminders.value = const <Reminder>[];
  }

  void dispose() {
    _reminders.dispose();
  }

  void _emitSorted(List<Reminder> reminders) {
    reminders.sort(
      (Reminder a, Reminder b) => a.scheduledAt.compareTo(b.scheduledAt),
    );
    _reminders.value = List<Reminder>.unmodifiable(reminders);
  }
}
