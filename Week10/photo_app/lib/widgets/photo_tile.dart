import 'dart:io';

import 'package:flutter/material.dart';

import '../models/photo_item.dart';
import '../theme/app_theme.dart';

class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key,
    required this.photo,
    required this.onTap,
  });

  final PhotoItem photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: photo.id,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.tileBorderRadius,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: AppTheme.tileBorderRadius,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                File(photo.filePath),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
