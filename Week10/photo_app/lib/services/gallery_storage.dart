import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/photo_item.dart';

class GalleryStorage {
  GalleryStorage();

  static const _savedPathsKey = 'saved_photo_paths';
  static const _saveToggleKey = 'save_locally_toggle';

  final ValueNotifier<List<PhotoItem>> photos =
      ValueNotifier<List<PhotoItem>>(<PhotoItem>[]);
  final ValueNotifier<bool> saveLocally =
      ValueNotifier<bool>(false);

  SharedPreferences? _prefs;
  bool _initialized = false;
  final Set<String> _persistedPaths = <String>{};

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    await _ensurePrefs();
    saveLocally.value = _prefs!.getBool(_saveToggleKey) ?? false;

    final savedPaths = _prefs!.getStringList(_savedPathsKey) ?? <String>[];
    final stalePaths = <String>[];
    final loaded = <PhotoItem>[];

    for (final path in savedPaths) {
      final file = File(path);
      final exists = await file.exists();
      if (!exists) {
        stalePaths.add(path);
        continue;
      }

      try {
        final stat = await file.stat();
        final createdAt = stat.modified;
        final item = PhotoItem(
          id: path,
          filePath: path,
          createdAt: createdAt,
        );
        loaded.add(item);
        _persistedPaths.add(path);
      } on FileSystemException {
        stalePaths.add(path);
      }
    }

    if (stalePaths.isNotEmpty) {
      final cleaned =
          savedPaths.where((path) => !stalePaths.contains(path)).toList();
      unawaited(_prefs!.setStringList(_savedPathsKey, cleaned));
    }

    loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    photos.value = loaded;
    _initialized = true;
  }

  Future<void> setSaveLocally(bool value) async {
    await _ensurePrefs();
    saveLocally.value = value;
    await _prefs!.setBool(_saveToggleKey, value);
  }

  Future<String> copyToAppDir(XFile file) async {
    final directory = await getApplicationDocumentsDirectory();
    final extension = _extensionFor(file.path);
    final filename =
        'photo_${DateTime.now().millisecondsSinceEpoch}$extension';
    final newPath = '${directory.path}${Platform.pathSeparator}$filename';
    await file.saveTo(newPath);
    return newPath;
  }

  Future<void> addPhoto(PhotoItem item, {required bool persist}) async {
    final updated = List<PhotoItem>.from(photos.value)..add(item);
    updated.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    photos.value = updated;

    if (persist) {
      await _ensurePrefs();
      _persistedPaths.add(item.filePath);
      final current = _prefs!.getStringList(_savedPathsKey) ?? <String>[];
      if (!current.contains(item.filePath)) {
        current.add(item.filePath);
        await _prefs!.setStringList(_savedPathsKey, current);
      }
    }
  }

  Future<void> removePhoto(
    PhotoItem item, {
    bool deleteFile = true,
  }) async {
    final updated = List<PhotoItem>.from(photos.value)
      ..removeWhere((photo) => photo.id == item.id);
    photos.value = updated;

    final wasPersisted = _persistedPaths.remove(item.filePath);
    if (wasPersisted) {
      await _ensurePrefs();
      final current = _prefs!.getStringList(_savedPathsKey) ?? <String>[];
      current.remove(item.filePath);
      await _prefs!.setStringList(_savedPathsKey, current);
    }

    if (!deleteFile) {
      return;
    }

    final file = File(item.filePath);
    if (await file.exists()) {
      try {
        await file.delete();
      } on FileSystemException {
        // Ignore deletion errors.
      }
    }
  }

  Future<void> clearAllPersisted() async {
    final persisted = Set<String>.from(_persistedPaths);
    if (persisted.isEmpty) {
      return;
    }

    final remaining = photos.value
        .where((photo) => !persisted.contains(photo.filePath))
        .toList();
    photos.value = remaining;

    for (final path in persisted) {
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
        } on FileSystemException {
          // Ignore cleanup errors.
        }
      }
    }

    _persistedPaths.clear();
    await _ensurePrefs();
    await _prefs!.remove(_savedPathsKey);
  }

  String _extensionFor(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) {
      return '';
    }
    return path.substring(dotIndex);
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
