import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static const String _cameraPermissionMessage =
      'Camera access is needed to take photos of medical documents. You can continue without uploading photos if you prefer.';

  static const String _photoLibraryPermissionMessage =
      'Photo library access is needed to select medical documents from your gallery. You can continue without uploading photos if you prefer.';

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if photo library permission is granted
  static Future<bool> isPhotoLibraryPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Request camera permission with user-friendly dialog
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      return await _showPermissionDialog(
        context,
        'Camera Permission Required',
        _cameraPermissionMessage,
        true, // Show "Open Settings" button
      );
    }

    return await _showPermissionDialog(
      context,
      'Camera Permission Required',
      _cameraPermissionMessage,
      false, // Don't show "Open Settings" button
    );
  }

  /// Request photo library permission with user-friendly dialog
  static Future<bool> requestPhotoLibraryPermission(
    BuildContext context,
  ) async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();
      if (result.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      return await _showPermissionDialog(
        context,
        'Photo Library Permission Required',
        _photoLibraryPermissionMessage,
        true, // Show "Open Settings" button
      );
    }

    return await _showPermissionDialog(
      context,
      'Photo Library Permission Required',
      _photoLibraryPermissionMessage,
      false, // Don't show "Open Settings" button
    );
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    bool showOpenSettings,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              if (showOpenSettings)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Open app settings for permission management
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Check if we can access camera (permission granted)
  static Future<bool> canAccessCamera() async {
    return await isCameraPermissionGranted();
  }

  /// Check if we can access photo library (permission granted)
  static Future<bool> canAccessPhotoLibrary() async {
    return await isPhotoLibraryPermissionGranted();
  }
}
