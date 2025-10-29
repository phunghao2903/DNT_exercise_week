import '../../domain/entities/note.dart';

/// Data representation of a note stored in-memory.
class NoteModel {
  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NoteModel.newNote({
    required String title,
    required String content,
  }) {
    final now = DateTime.now();
    return NoteModel(
      id: _generateId(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  NoteModel copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _generateId() {
    // Combines timestamp with a counter-esque suffix for uniqueness.
    final now = DateTime.now();
    final millis = now.millisecondsSinceEpoch.toString();
    final micros = now.microsecondsSinceEpoch.remainder(1000).toString().padLeft(3, '0');
    return '$millis$micros';
  }

  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}
