import '../models/message.dart';

final DateTime _now = DateTime.now();

final List<Message> mockMessages = <Message>[
  Message(
    id: '1',
    text: 'Hey there! How is the project going?',
    isSender: false,
    timestamp: _now.subtract(const Duration(minutes: 12)),
  ),
  Message(
    id: '2',
    text: 'Hi! It is coming along nicely. Just polishing the last bits.',
    isSender: true,
    timestamp: _now.subtract(const Duration(minutes: 11)),
  ),
  Message(
    id: '3',
    text: 'Awesome! Let me know if you need anything.',
    isSender: false,
    timestamp: _now.subtract(const Duration(minutes: 9)),
  ),
  Message(
    id: '4',
    text: 'Will do. Thinking about shipping a new build later today.',
    isSender: true,
    timestamp: _now.subtract(const Duration(minutes: 6)),
  ),
  Message(
    id: '5',
    text: 'Perfect! Ping me when it is ready so I can review it.',
    isSender: false,
    timestamp: _now.subtract(const Duration(minutes: 4)),
  ),
  Message(
    id: '6',
    text: 'Sure thing, thanks!',
    isSender: true,
    timestamp: _now.subtract(const Duration(minutes: 2)),
  ),
];
