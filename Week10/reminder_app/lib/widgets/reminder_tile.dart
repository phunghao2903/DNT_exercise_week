import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../utils/formatters.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
  });

  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isPending = reminder.isPending;
    final String statusLabel = isPending ? 'Scheduled' : 'Past';
    final Color statusColor = isPending
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return Card(
      child: ListTile(
        title: Text(
          reminder.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                dateTimeReadable(reminder.scheduledAt),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<_ReminderMenuAction>(
          onSelected: (_ReminderMenuAction action) {
            if (action == _ReminderMenuAction.edit) {
              onEdit();
            } else {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<_ReminderMenuAction>>[
                const PopupMenuItem<_ReminderMenuAction>(
                  value: _ReminderMenuAction.edit,
                  child: Text('Edit'),
                ),
                const PopupMenuItem<_ReminderMenuAction>(
                  value: _ReminderMenuAction.delete,
                  child: Text('Delete'),
                ),
              ],
        ),
      ),
    );
  }
}

enum _ReminderMenuAction { edit, delete }
