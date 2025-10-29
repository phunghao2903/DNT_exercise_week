import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../utils/formatters.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = expense.category.color;
    final avatarAlpha =
        (categoryColor.a * 0.15 * 255).clamp(0.0, 255.0).round();
    final avatarBackground = categoryColor.withAlpha(avatarAlpha);

    return ListTile(
      onTap: onEdit,
      onLongPress: onEdit,
      leading: CircleAvatar(
        backgroundColor: avatarBackground,
        foregroundColor: categoryColor,
        child: Icon(expense.category.icon),
      ),
      title: Text(
        expense.title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLong(expense.date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (expense.note != null && expense.note!.isNotEmpty)
            Text(
              expense.note!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
      horizontalTitleGap: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: colorScheme.surfaceContainerHighest,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency(expense.amount),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                expense.category.label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          PopupMenuButton<_ExpenseMenuAction>(
            onSelected: (action) {
              switch (action) {
                case _ExpenseMenuAction.edit:
                  onEdit();
                  break;
                case _ExpenseMenuAction.delete:
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ExpenseMenuAction.edit,
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: _ExpenseMenuAction.delete,
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ExpenseMenuAction {
  edit,
  delete,
}
