class Message {
  const Message({
    required this.id,
    required this.text,
    required this.isSender,
    this.timestamp,
  });

  final String id;
  final String text;
  final bool isSender;
  final DateTime? timestamp;

  Message copyWith({
    String? id,
    String? text,
    bool? isSender,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isSender: isSender ?? this.isSender,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
