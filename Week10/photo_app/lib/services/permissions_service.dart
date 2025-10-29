import 'dart:io';

import 'package:permission_handler/permission_handler.dart' as permission_handler;

class PermissionsService {
  Future<permission_handler.PermissionStatus> ensureCameraPermission() async {
    final status = await permission_handler.Permission.camera.status;
    if (status.isGranted) {
      return status;
    }
    return permission_handler.Permission.camera.request();
  }

  Future<permission_handler.PermissionStatus> ensureGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await permission_handler.Permission.photos.status;
      if (_isGrantedOrLimited(status)) {
        return status;
      }
      return permission_handler.Permission.photos.request();
    }

    var status = await permission_handler.Permission.photos.status;
    if (_isGrantedOrLimited(status)) {
      return status;
    }

    if (status.isDenied) {
      status = await permission_handler.Permission.photos.request();
      if (_isGrantedOrLimited(status) || status.isPermanentlyDenied) {
        return status;
      }
    }

    if (status.isPermanentlyDenied) {
      return status;
    }

    var storageStatus = await permission_handler.Permission.storage.status;
    if (storageStatus.isGranted) {
      return storageStatus;
    }
    storageStatus = await permission_handler.Permission.storage.request();
    return storageStatus;
  }

  bool isPermanentlyDenied(permission_handler.PermissionStatus status) =>
      status.isPermanentlyDenied;

  bool isDenied(permission_handler.PermissionStatus status) =>
      status.isDenied || status.isRestricted;

  bool isGranted(permission_handler.PermissionStatus status) =>
      _isGrantedOrLimited(status);

  Future<bool> openAppSettings() => permission_handler.openAppSettings();

  bool _isGrantedOrLimited(permission_handler.PermissionStatus status) =>
      status.isGranted || status.isLimited;
}
