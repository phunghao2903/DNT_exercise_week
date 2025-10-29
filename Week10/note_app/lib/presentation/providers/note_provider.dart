import 'package:flutter/foundation.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_all_notes.dart';
import '../../domain/usecases/get_note_by_id.dart';
import '../../domain/usecases/update_note.dart';

class NoteProvider extends ChangeNotifier {
  NoteProvider({
    required GetAllNotes getAllNotes,
    required AddNote addNote,
    required UpdateNote updateNote,
    required DeleteNote deleteNote,
    required GetNoteById getNoteById,
  })  : _getAllNotes = getAllNotes,
        _addNote = addNote,
        _updateNote = updateNote,
        _deleteNote = deleteNote,
        _getNoteById = getNoteById {
    _initialize();
  }

  final GetAllNotes _getAllNotes;
  final AddNote _addNote;
  final UpdateNote _updateNote;
  final DeleteNote _deleteNote;
  final GetNoteById _getNoteById;

  List<Note> _notes = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Note> getAllNotes() => List.unmodifiable(_notes);

  Future<void> refresh() => _initialize();

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    final notes = await _getAllNotes();
    _notes = notes;

    _isLoading = false;
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Note?> fetchNoteById(String id) async {
    final local = getNoteById(id);
    if (local != null) {
      return local;
    }
    final note = await _getNoteById(id);
    if (note != null) {
      _notes = [
        note,
        ..._notes.where((item) => item.id != note.id),
      ];
      notifyListeners();
    }
    return note;
  }

  Future<Note> addNote({
    required String title,
    required String content,
  }) async {
    final note = await _addNote(
      AddNoteParams(
        title: title,
        content: content,
      ),
    );
    _notes = [note, ..._notes];
    notifyListeners();
    return note;
  }

  Future<Note?> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final note = await _updateNote(
      UpdateNoteParams(
        id: id,
        title: title,
        content: content,
      ),
    );

    if (note == null) {
      return null;
    }

    final index = _notes.indexWhere((item) => item.id == note.id);
    if (index == -1) {
      _notes = [note, ..._notes];
    } else {
      _notes[index] = note;
    }

    notifyListeners();
    return note;
  }

  Future<void> deleteNote(String id) async {
    final deleted = await _deleteNote(id);
    if (deleted) {
      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
    }
  }
}
