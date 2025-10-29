import '../repositories/note_repository.dart';

class DeleteNote {
  DeleteNote(this._repository);

  final NoteRepository _repository;

  Future<bool> call(String id) {
    return _repository.deleteNote(id);
  }
}
