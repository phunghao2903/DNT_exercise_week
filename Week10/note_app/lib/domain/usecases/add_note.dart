import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote {
  AddNote(this._repository);

  final NoteRepository _repository;

  Future<Note> call(AddNoteParams params) {
    return _repository.addNote(
      title: params.title,
      content: params.content,
    );
  }
}

class AddNoteParams {
  AddNoteParams({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}
