import '../models/note_model.dart';

class NoteLocalDataSource {
  final List<NoteModel> _storage = [];

  Future<List<NoteModel>> getAllNotes() async {
    return List<NoteModel>.unmodifiable(_storage);
  }

  Future<NoteModel?> getNoteById(String id) async {
    try {
      return _storage.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<NoteModel> addNote({
    required String title,
    required String content,
  }) async {
    final note = NoteModel.newNote(title: title, content: content);
    _storage.insert(0, note);
    return note;
  }

  Future<NoteModel?> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final index = _storage.indexWhere((note) => note.id == id);
    if (index == -1) {
      return null;
    }

    final updated = _storage[index].copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    _storage[index] = updated;
    return updated;
  }

  Future<bool> deleteNote(String id) async {
    final initialLength = _storage.length;
    _storage.removeWhere((note) => note.id == id);
    return _storage.length != initialLength;
  }
}
