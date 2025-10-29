import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNoteById {
  GetNoteById(this._repository);

  final NoteRepository _repository;

  Future<Note?> call(String id) {
    return _repository.getNoteById(id);
  }
}
