import 'package:flutter/material.dart';

import '../models/photo_item.dart';
import '../theme/app_theme.dart';
import 'photo_tile.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
  });

  final List<PhotoItem> photos;
  final ValueChanged<PhotoItem> onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTheme.gallerySpacing;
    final crossAxisCount = _computeCrossAxisCount(context);

    return GridView.builder(
      itemCount: photos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoTile(
          photo: photo,
          onTap: () => onPhotoTap(photo),
        );
      },
    );
  }

  int _computeCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 3;
    }
    if (width < 900) {
      return 4;
    }
    return 5;
  }
}
