import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

/// 🔐 权限管理服务
class PermissionService {
  /// 检查所有必需权限状态
  static Future<Map<String, bool>> checkAllPermissions() async {
    final permissions = {
      'location': await _checkLocationPermission(),
      'storage': await _checkStoragePermission(),
      'notification': await _checkNotificationPermission(),
    };

    return permissions;
  }

  /// 检查位置权限
  static Future<bool> _checkLocationPermission() async {
    try {
      // 检查位置服务是否开启
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // 检查位置权限
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// 检查存储权限
  static Future<bool> _checkStoragePermission() async {
    try {
      // Android 13+ 不需要存储权限，直接返回true
      final status = await Permission.storage.status;
      return status.isGranted || status.isLimited;
    } catch (e) {
      return true; // 如果检查失败，假设已授权
    }
  }

  /// 检查通知权限
  static Future<bool> _checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      return true; // 通知权限不是必需的
    }
  }

  /// 申请位置权限
  static Future<bool> requestLocationPermission() async {
    try {
      // 先检查位置服务
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // 可以提示用户打开位置服务
        return false;
      }

      // 申请权限
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// 申请存储权限
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted || status.isLimited;
    } catch (e) {
      return true;
    }
  }

  /// 申请通知权限
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      return true;
    }
  }

  /// 申请所有必需权限
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    // 位置权限（必需）
    results['location'] = await requestLocationPermission();

    // 存储权限（可选）
    results['storage'] = await requestStoragePermission();

    // 通知权限（可选）
    results['notification'] = await requestNotificationPermission();

    return results;
  }

  /// 检查是否所有必需权限都已授权
  static Future<bool> hasAllRequiredPermissions() async {
    final permissions = await checkAllPermissions();
    // 只有位置权限是必需的
    return permissions['location'] == true;
  }

  /// 打开应用设置页面
  static Future<void> openAppSettings() async {
    await Permission.storage.request().then((_) => openAppSettings());
  }
}
