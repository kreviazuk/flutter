import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

// 导入openAppSettings函数
import 'package:permission_handler/permission_handler.dart' as permission_handler;

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
      if (Platform.isAndroid) {
        // Android 13+ (API 33+) 使用新的权限模型
        final photosStatus = await Permission.photos.status;
        final storageStatus = await Permission.storage.status;

        // 如果photos权限已授权，就认为存储权限OK
        if (photosStatus.isGranted) {
          return true;
        }

        // 否则检查传统的存储权限
        return storageStatus.isGranted || storageStatus.isLimited;
      }

      // iOS 默认允许
      return true;
    } catch (e) {
      print('检查存储权限失败: $e');
      return false;
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
      if (Platform.isAndroid) {
        // 先尝试申请photos权限
        final photosResult = await Permission.photos.request();
        if (photosResult.isGranted) {
          return true;
        }

        // 如果photos权限被拒绝，尝试传统存储权限
        final storageResult = await Permission.storage.request();
        if (storageResult.isGranted || storageResult.isLimited) {
          return true;
        }

        // 如果基础权限都被拒绝，返回false
        // 图片保存功能会使用fallback方案
        print('基础存储权限被拒绝，图片将保存到应用内部目录');
        return false;
      }

      // iOS 默认允许
      return true;
    } catch (e) {
      print('申请存储权限失败: $e');
      return false;
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

    // 存储权限（可选但推荐）
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

  /// 检查是否所有推荐权限都已授权
  static Future<bool> hasAllRecommendedPermissions() async {
    final permissions = await checkAllPermissions();
    // 位置权限是必需的，存储权限是推荐的
    return permissions['location'] == true && permissions['storage'] == true;
  }

  /// 获取缺失的权限列表
  static Future<List<String>> getMissingPermissions() async {
    final permissions = await checkAllPermissions();
    final missing = <String>[];

    if (permissions['location'] != true) {
      missing.add('location');
    }
    if (permissions['storage'] != true) {
      missing.add('storage');
    }
    if (permissions['notification'] != true) {
      missing.add('notification');
    }

    return missing;
  }

  /// 打开应用设置页面
  static Future<bool> openAppSettings() async {
    return await permission_handler.openAppSettings();
  }
}
