import 'package:flutter/foundation.dart';

@immutable
class PhotoItem {
  const PhotoItem({
    required this.id,
    required this.filePath,
    required this.createdAt,
  });

  final String id;
  final String filePath;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
