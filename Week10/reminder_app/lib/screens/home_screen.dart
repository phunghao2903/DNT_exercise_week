import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../repositories/reminder_repository.dart';
import '../services/notification_service.dart';
import '../widgets/empty_view.dart';
import '../widgets/reminder_form_sheet.dart';
import '../widgets/reminder_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final ReminderRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReminderRepository get _repository => widget.repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: <Widget>[
          ValueListenableBuilder<List<Reminder>>(
            valueListenable: _repository.reminders,
            builder: (BuildContext context, List<Reminder> reminders, _) {
              final bool hasItems = reminders.isNotEmpty;
              return IconButton(
                onPressed: hasItems ? _clearAll : null,
                tooltip: 'Clear All',
                icon: const Icon(Icons.delete_sweep_outlined),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Reminder>>(
        valueListenable: _repository.reminders,
        builder: (BuildContext context, List<Reminder> reminders, _) {
          if (reminders.isEmpty) {
            return const EmptyView();
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (BuildContext context, int index) {
              final Reminder reminder = reminders[index];
              return ReminderTile(
                reminder: reminder,
                onEdit: () => _openReminderSheet(reminder: reminder),
                onDelete: () => _removeReminder(reminder),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openReminderSheet,
        tooltip: 'Add Reminder',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openReminderSheet({Reminder? reminder}) async {
    final ReminderFormResult? result =
        await showModalBottomSheet<ReminderFormResult>(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (BuildContext context) =>
              ReminderFormSheet(repository: _repository, reminder: reminder),
        );

    if (result == null) {
      return;
    }

    final String message = result == ReminderFormResult.created
        ? 'Reminder scheduled'
        : 'Reminder updated';
    _showSnackBar(message);
  }

  Future<void> _removeReminder(Reminder reminder) async {
    await NotificationService.instance.cancelReminder(reminder.id);
    _repository.remove(reminder.id);
    _showSnackBar('Reminder deleted');
  }

  Future<void> _clearAll() async {
    await NotificationService.instance.cancelAll();
    _repository.clear();
    _showSnackBar('All reminders cleared');
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
