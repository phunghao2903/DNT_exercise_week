import 'dart:io';

import 'package:flutter/material.dart';

import '../models/photo_item.dart';
import '../services/gallery_storage.dart';

class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.photo,
    required this.galleryStorage,
  });

  final PhotoItem photo;
  final GalleryStorage galleryStorage;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final file = File(widget.photo.filePath);
    final exists = file.existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Photo'),
        actions: [
          IconButton(
            tooltip: 'Delete photo',
            icon: _deleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            onPressed: _deleting ? null : _handleDelete,
          ),
        ],
      ),
      body: exists
          ? Center(
              child: Hero(
                tag: widget.photo.id,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                'This photo is no longer available.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() {
      _deleting = true;
    });
    try {
      await widget.galleryStorage.removePhoto(widget.photo);
    } finally {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}
