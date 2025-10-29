import '../entities/note.dart';
import '../repositories/note_repository.dart';

class UpdateNote {
  UpdateNote(this._repository);

  final NoteRepository _repository;

  Future<Note?> call(UpdateNoteParams params) {
    return _repository.updateNote(
      id: params.id,
      title: params.title,
      content: params.content,
    );
  }
}

class UpdateNoteParams {
  UpdateNoteParams({
    required this.id,
    required this.title,
    required this.content,
  });

  final String id;
  final String title;
  final String content;
}
