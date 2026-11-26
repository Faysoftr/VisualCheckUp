import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// Abstraction over runtime camera permission checks so screens can be tested
/// deterministically without platform channel dependencies.
abstract class CameraPermissionService {
  Future<CameraPermissionState> checkCamera();
  Future<CameraPermissionState> requestCamera();
  Future<bool> openSettings();
}

class PermissionHandlerCameraService implements CameraPermissionService {
  const PermissionHandlerCameraService();

  @override
  Future<CameraPermissionState> checkCamera() async {
    try {
      final status = await Permission.camera.status;
      return _mapStatus(status);
    } on MissingPluginException {
      // Desktop / unsupported test hosts without permission_handler channel.
      return CameraPermissionState.granted;
    } on UnsupportedError {
      return CameraPermissionState.granted;
    }
  }

  @override
  Future<CameraPermissionState> requestCamera() async {
    try {
      final status = await Permission.camera.request();
      return _mapStatus(status);
    } on MissingPluginException {
      return CameraPermissionState.granted;
    } on UnsupportedError {
      return CameraPermissionState.granted;
    }
  }

  @override
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } on MissingPluginException {
      return false;
    } on UnsupportedError {
      return false;
    }
  }

  CameraPermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return CameraPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return CameraPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) {
      return CameraPermissionState.restricted;
    }
    return CameraPermissionState.denied;
  }
}
