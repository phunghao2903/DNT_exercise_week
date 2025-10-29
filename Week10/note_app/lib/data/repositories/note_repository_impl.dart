import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._localDataSource);

  final NoteLocalDataSource _localDataSource;

  @override
  Future<List<Note>> getAllNotes() async {
    final models = await _localDataSource.getAllNotes();
    return models.map((note) => note.toEntity()).toList(growable: false);
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final model = await _localDataSource.getNoteById(id);
    return model?.toEntity();
  }

  @override
  Future<Note> addNote({
    required String title,
    required String content,
  }) async {
    final model = await _localDataSource.addNote(title: title, content: content);
    return model.toEntity();
  }

  @override
  Future<Note?> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final model = await _localDataSource.updateNote(
      id: id,
      title: title,
      content: content,
    );
    return model?.toEntity();
  }

  @override
  Future<bool> deleteNote(String id) async {
    return _localDataSource.deleteNote(id);
  }
}
