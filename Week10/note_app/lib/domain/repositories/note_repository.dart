import '../entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getAllNotes();

  Future<Note?> getNoteById(String id);

  Future<Note> addNote({
    required String title,
    required String content,
  });

  Future<Note?> updateNote({
    required String id,
    required String title,
    required String content,
  });

  Future<bool> deleteNote(String id);
}
