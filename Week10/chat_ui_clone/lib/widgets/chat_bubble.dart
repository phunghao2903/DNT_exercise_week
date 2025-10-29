import 'package:flutter/material.dart';

import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSender = message.isSender;
    final Color bubbleColor = isSender
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final Color textColor = isSender
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final Alignment alignment =
        isSender ? Alignment.centerRight : Alignment.centerLeft;
    final CrossAxisAlignment crossAxisAlignment =
        isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final DateTime? timestamp = message.timestamp;
    final double maxBubbleWidth = MediaQuery.of(context).size.width * 0.7;
    final Color shadowColor = Colors.black.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.3 : 0.08,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isSender ? 20 : 6),
                    bottomRight: Radius.circular(isSender ? 6 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (timestamp != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTimestamp(timestamp),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final String hours = timestamp.hour.toString().padLeft(2, '0');
    final String minutes = timestamp.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
