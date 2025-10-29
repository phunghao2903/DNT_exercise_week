import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

import '../models/photo_item.dart';
import '../services/gallery_storage.dart';
import '../services/permissions_service.dart';
import '../services/photo_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_view.dart';
import '../widgets/photo_grid.dart';
import '../widgets/save_toggle.dart';
import 'photo_viewer_screen.dart';

enum _GalleryMenuAction {
  pickFromGallery,
  clearSaved,
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    required this.galleryStorage,
    required this.permissionsService,
    required this.photoPicker,
  });

  final GalleryStorage galleryStorage;
  final PermissionsService permissionsService;
  final PhotoPicker photoPicker;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _initializing = true;
  bool _isProcessing = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    if (mounted) {
      setState(() {
        _initializing = true;
        _initError = null;
      });
    }
    try {
      await widget.galleryStorage.init();
    } catch (error) {
      if (mounted) {
        setState(() {
          _initError = 'Failed to load gallery';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.camera_alt_outlined),
          tooltip: 'Capture photo',
          onPressed: _initializing || _isProcessing
              ? null
              : () => _handleCameraAction(),
        ),
        title: const Text('Photo Gallery'),
        actions: [
          SaveToggle(
            notifier: widget.galleryStorage.saveLocally,
            onChanged: (value) => _handleSaveToggle(value, context),
          ),
          PopupMenuButton<_GalleryMenuAction>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => const [
              PopupMenuItem<_GalleryMenuAction>(
                value: _GalleryMenuAction.pickFromGallery,
                child: Text('Pick from gallery'),
              ),
              PopupMenuItem<_GalleryMenuAction>(
                value: _GalleryMenuAction.clearSaved,
                child: Text('Clear saved'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: AppTheme.screenPadding,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_initError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _initError!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadGallery,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ValueListenableBuilder<List<PhotoItem>>(
      valueListenable: widget.galleryStorage.photos,
      builder: (context, photos, _) {
        if (photos.isEmpty) {
          return const EmptyView();
        }

        return PhotoGrid(
          photos: photos,
          onPhotoTap: _openViewer,
        );
      },
    );
  }

  Future<void> _handleCameraAction() async {
    if (_isProcessing) {
      return;
    }
    setState(() {
      _isProcessing = true;
    });

    try {
      final status =
          await widget.permissionsService.ensureCameraPermission();
      final allowed = _handlePermissionStatus(
        status,
        'Camera access is required to capture photos.',
      );
      if (!allowed || !mounted) {
        return;
      }

      final file = await widget.photoPicker.pickFromCamera();
      if (file == null) {
        return;
      }

      await _storePhoto(file);
      if (!mounted) {
        return;
      }
      _showSnackBar('Photo captured');
    } catch (_) {
      if (mounted) {
        _showSnackBar('Unable to capture photo');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handlePickFromGallery() async {
    if (_isProcessing) {
      return;
    }
    setState(() {
      _isProcessing = true;
    });

    try {
      final status =
          await widget.permissionsService.ensureGalleryPermission();
      final allowed = _handlePermissionStatus(
        status,
        'Gallery access is required to pick photos.',
      );
      if (!allowed || !mounted) {
        return;
      }

      final file = await widget.photoPicker.pickFromGallery();
      if (file == null) {
        return;
      }

      await _storePhoto(file);
      if (!mounted) {
        return;
      }
      _showSnackBar('Photo added from gallery');
    } catch (_) {
      if (mounted) {
        _showSnackBar('Unable to pick photo');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _storePhoto(XFile file) async {
    final persist = widget.galleryStorage.saveLocally.value;
    var targetPath = file.path;

    if (persist) {
      try {
        targetPath = await widget.galleryStorage.copyToAppDir(file);
      } catch (_) {
        if (mounted) {
          _showSnackBar('Failed to save photo locally');
        }
        return;
      }
    }

    final item = PhotoItem(
      id: targetPath,
      filePath: targetPath,
      createdAt: DateTime.now(),
    );

    await widget.galleryStorage.addPhoto(
      item,
      persist: persist,
    );
  }

  Future<void> _openViewer(PhotoItem photo) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          photo: photo,
          galleryStorage: widget.galleryStorage,
        ),
      ),
    );
    if (deleted == true && mounted) {
      _showSnackBar('Photo deleted');
    }
  }

  void _handleMenuAction(_GalleryMenuAction action) {
    switch (action) {
      case _GalleryMenuAction.pickFromGallery:
        _handlePickFromGallery();
        break;
      case _GalleryMenuAction.clearSaved:
        _clearSavedPhotos();
        break;
    }
  }

  void _handleSaveToggle(bool value, BuildContext context) {
    unawaited(widget.galleryStorage.setSaveLocally(value));
    final message = value
        ? 'New photos will be saved locally'
        : 'New photos will only be stored for this session';
    _showSnackBar(message);
  }

  Future<void> _clearSavedPhotos() async {
    await widget.galleryStorage.clearAllPersisted();
    if (!mounted) {
      return;
    }
    _showSnackBar('Saved photos cleared');
  }

  bool _handlePermissionStatus(
    permission_handler.PermissionStatus status,
    String message,
  ) {
    if (widget.permissionsService.isGranted(status)) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    final messenger = ScaffoldMessenger.of(context);
    SnackBarAction? action;

    if (widget.permissionsService.isPermanentlyDenied(status)) {
      action = SnackBarAction(
        label: 'Settings',
        onPressed: widget.permissionsService.openAppSettings,
      );
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
      ),
    );
    return false;
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
