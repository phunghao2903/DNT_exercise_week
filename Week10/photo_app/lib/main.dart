import 'package:flutter/material.dart';

import 'screens/gallery_screen.dart';
import 'services/gallery_storage.dart';
import 'services/permissions_service.dart';
import 'services/photo_picker.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final galleryStorage = GalleryStorage();
  final permissionsService = PermissionsService();
  final photoPicker = PhotoPicker();

  runApp(
    PhotoGalleryApp(
      galleryStorage: galleryStorage,
      permissionsService: permissionsService,
      photoPicker: photoPicker,
    ),
  );
}

class PhotoGalleryApp extends StatelessWidget {
  const PhotoGalleryApp({
    super.key,
    required this.galleryStorage,
    required this.permissionsService,
    required this.photoPicker,
  });

  final GalleryStorage galleryStorage;
  final PermissionsService permissionsService;
  final PhotoPicker photoPicker;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: GalleryScreen(
        galleryStorage: galleryStorage,
        permissionsService: permissionsService,
        photoPicker: photoPicker,
      ),
    );
  }
}
