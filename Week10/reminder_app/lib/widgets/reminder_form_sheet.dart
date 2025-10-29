import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../repositories/reminder_repository.dart';
import '../services/notification_service.dart';
import '../utils/formatters.dart';

enum ReminderFormResult { created, updated }

class ReminderFormSheet extends StatefulWidget {
  const ReminderFormSheet({super.key, required this.repository, this.reminder});

  final ReminderRepository repository;
  final Reminder? reminder;

  @override
  State<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<ReminderFormSheet> {
  late final TextEditingController _titleController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.reminder?.title ?? '',
    );

    final DateTime now = DateTime.now().add(const Duration(minutes: 5));
    if (widget.reminder != null) {
      final DateTime scheduled = widget.reminder!.scheduledAt;
      _selectedDate = DateUtils.dateOnly(scheduled);
      _selectedTime = TimeOfDay.fromDateTime(scheduled);
    } else {
      _selectedDate = DateUtils.dateOnly(now);
      _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
    final bool isEditing = widget.reminder != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Reminder' : 'New Reminder',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Meeting with product team',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(_dateLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(_timeLabel(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Schedule Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        _selectedDate ??
        DateUtils.dateOnly(now.add(const Duration(minutes: 5)));
    final DateTime firstDate = DateUtils.dateOnly(now);
    final DateTime lastDate = DateTime(now.year + 5);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay initialTime =
        _selectedTime ??
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 5)));
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('Title cannot be empty.');
      return;
    }

    final DateTime? combined = _combinedDateTime();
    if (combined == null) {
      _showError('Please choose both a date and a time.');
      return;
    }

    if (!combined.isAfter(DateTime.now())) {
      _showError('Pick a time in the future to schedule this reminder.');
      return;
    }

    final bool isEditing = widget.reminder != null;
    final Reminder? original = widget.reminder;
    final Reminder reminder =
        (original ??
                Reminder(
                  id: _generateId(),
                  title: title,
                  scheduledAt: combined,
                ))
            .copyWith(title: title, scheduledAt: combined);

    setState(() => _saving = true);

    try {
      if (original != null) {
        await NotificationService.instance.cancelReminder(original.id);
      }

      await NotificationService.instance.scheduleReminder(
        id: reminder.id,
        title: reminder.title,
        when: reminder.scheduledAt,
      );

      if (isEditing) {
        widget.repository.update(reminder);
      } else {
        widget.repository.add(reminder);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        isEditing ? ReminderFormResult.updated : ReminderFormResult.created,
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to schedule reminder: $error\n$stackTrace');
      if (original != null) {
        try {
          await NotificationService.instance.scheduleReminder(
            id: original.id,
            title: original.title,
            when: original.scheduledAt,
          );
          widget.repository.update(original);
        } catch (rescheduleError) {
          debugPrint('Failed to restore original reminder: $rescheduleError');
        }
      }
      _showError('Could not schedule the reminder. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  DateTime? _combinedDateTime() {
    final DateTime? date = _selectedDate;
    final TimeOfDay? time = _selectedTime;
    if (date == null || time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String get _dateLabel {
    final DateTime? date = _selectedDate;
    if (date == null) {
      return 'Select date';
    }
    return dateLong(date);
  }

  String _timeLabel(BuildContext context) {
    final TimeOfDay? time = _selectedTime;
    if (time == null) {
      return 'Select time';
    }
    return time.format(context);
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}
