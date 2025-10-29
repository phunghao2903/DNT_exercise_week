import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/note_detail_page.dart';
import 'presentation/providers/note_provider.dart';
import 'data/datasources/note_local_data_source.dart';
import 'data/repositories/note_repository_impl.dart';
import 'domain/usecases/add_note.dart';
import 'domain/usecases/delete_note.dart';
import 'domain/usecases/get_all_notes.dart';
import 'domain/usecases/get_note_by_id.dart';
import 'domain/usecases/update_note.dart';

final NoteLocalDataSource _noteLocalDataSource = NoteLocalDataSource();
final NoteRepositoryImpl _noteRepository = NoteRepositoryImpl(_noteLocalDataSource);

final GetAllNotes _getAllNotes = GetAllNotes(_noteRepository);
final AddNote _addNote = AddNote(_noteRepository);
final UpdateNote _updateNote = UpdateNote(_noteRepository);
final DeleteNote _deleteNote = DeleteNote(_noteRepository);
final GetNoteById _getNoteById = GetNoteById(_noteRepository);

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NoteProvider>(
          create: (_) => NoteProvider(
            getAllNotes: _getAllNotes,
            addNote: _addNote,
            updateNote: _updateNote,
            deleteNote: _deleteNote,
            getNoteById: _getNoteById,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Note App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/detail': (context) => const NoteDetailPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            return MaterialPageRoute(
              builder: (context) => const NoteDetailPage(),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}
