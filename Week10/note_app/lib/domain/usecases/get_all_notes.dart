import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetAllNotes {
  GetAllNotes(this._repository);

  final NoteRepository _repository;

  Future<List<Note>> call() {
    return _repository.getAllNotes();
  }
}
