import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

/// 🖼️ 路径图片生成服务
class RouteImageService {
  /// 生成并保存跑步路径图片
  static Future<String?> generateAndSaveRouteImage({
    required BuildContext context,
    required List<LatLng> routePoints,
    required double totalDistance,
    required int elapsedTime,
    required double averageSpeed,
    required int calories,
    required bool isSimulated,
  }) async {
    try {
      // 检查权限
      if (!await _checkPermissions(context)) {
        return null;
      }

      // 生成图片
      final imageBytes = await _generateRouteImage(
        routePoints: routePoints,
        totalDistance: totalDistance,
        elapsedTime: elapsedTime,
        averageSpeed: averageSpeed,
        calories: calories,
        isSimulated: isSimulated,
      );

      if (imageBytes == null) {
        throw Exception('图片生成失败');
      }

      // 保存到设备
      return await _saveImageToDevice(imageBytes);
    } catch (e) {
      print('生成保存路径图片失败: $e');
      rethrow;
    }
  }

  /// 检查存储权限，如果没有权限则显示申请对话框
  static Future<bool> _checkPermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        // 首次检查权限状态
        bool hasPermission = await _hasStoragePermission();

        if (hasPermission) {
          print('存储权限已授权');
          return true;
        }

        print('存储权限未授权，开始申请流程');

        // 显示权限申请对话框
        final shouldRequest = await _showPermissionDialog(context);
        if (!shouldRequest) {
          print('用户取消权限申请');
          return false;
        }

        // 尝试申请权限
        hasPermission = await _requestStoragePermission();

        if (hasPermission) {
          print('存储权限申请成功');
          return true;
        }

        // 如果申请失败，检查具体原因
        final isPermanentlyDenied = await _isPermissionPermanentlyDenied();

        if (isPermanentlyDenied) {
          print('存储权限被永久拒绝，提示前往设置');
          final shouldGoToSettings = await _showSettingsDialog(context);

          if (shouldGoToSettings) {
            await openAppSettings();
            // 给用户时间去设置后再次检查
            await Future.delayed(const Duration(seconds: 2));
            return await _hasStoragePermission();
          }
        } else {
          print('存储权限被临时拒绝');
          // 提供降级保存方案
          return await _showFallbackSaveDialog(context);
        }

        return false;
      } catch (e) {
        print('权限检查失败: $e');
        // 权限检查失败时，尝试降级保存
        return await _showFallbackSaveDialog(context);
      }
    } else if (Platform.isIOS) {
      // iOS处理
      try {
        final photosStatus = await Permission.photos.status;

        if (photosStatus.isGranted) {
          return true;
        }

        // 显示权限申请对话框
        final shouldRequest = await _showPermissionDialog(context);
        if (!shouldRequest) {
          return false;
        }

        final photosResult = await Permission.photos.request();

        if (photosResult.isGranted) {
          return true;
        } else if (photosResult.isPermanentlyDenied) {
          final shouldGoToSettings = await _showSettingsDialog(context);
          if (shouldGoToSettings) {
            await openAppSettings();
          }
        }

        // iOS降级方案：保存到应用沙盒
        return await _showFallbackSaveDialog(context);
      } catch (e) {
        print('iOS权限检查失败: $e');
        return await _showFallbackSaveDialog(context);
      }
    }

    // 其他平台默认允许
    return true;
  }

  /// 检查是否有存储权限
  static Future<bool> _hasStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 检查多种权限
      final photosStatus = await Permission.photos.status;
      final storageStatus = await Permission.storage.status;

      print('Photos permission: $photosStatus');
      print('Storage permission: $storageStatus');

      return photosStatus.isGranted || storageStatus.isGranted;
    } else if (Platform.isIOS) {
      final photosStatus = await Permission.photos.status;
      return photosStatus.isGranted;
    }

    return true;
  }

  /// 申请存储权限
  static Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        // Android: 尝试多种权限策略

        // 策略1: 先尝试photos权限（Android 13+推荐）
        final photosResult = await Permission.photos.request();
        print('Photos permission request result: $photosResult');

        if (photosResult.isGranted) {
          return true;
        }

        // 策略2: 尝试传统存储权限
        final storageResult = await Permission.storage.request();
        print('Storage permission request result: $storageResult');

        if (storageResult.isGranted) {
          return true;
        }

        // 策略3: 尝试外部存储管理权限（Android 11+）
        try {
          final manageStorageResult = await Permission.manageExternalStorage.request();
          print('ManageExternalStorage permission request result: $manageStorageResult');

          return manageStorageResult.isGranted;
        } catch (e) {
          print('ManageExternalStorage权限不可用: $e');
          return false;
        }
      } else if (Platform.isIOS) {
        final photosResult = await Permission.photos.request();
        return photosResult.isGranted;
      }

      return true;
    } catch (e) {
      print('权限申请失败: $e');
      return false;
    }
  }

  /// 检查权限是否被永久拒绝
  static Future<bool> _isPermissionPermanentlyDenied() async {
    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.status;
      final storageStatus = await Permission.storage.status;

      return photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied;
    } else if (Platform.isIOS) {
      final photosStatus = await Permission.photos.status;
      return photosStatus.isPermanentlyDenied;
    }

    return false;
  }

  /// 显示降级保存对话框
  static Future<bool> _showFallbackSaveDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('无法保存到下载文件夹'),
          ],
        ),
        content: const Text(
          '无法获取存储权限，无法保存到公共下载文件夹。\n\n'
          '但可以将图片保存到应用内部文件夹，您可以通过文件管理器在应用数据目录中找到图片。\n\n'
          '是否继续保存到应用内部文件夹？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('保存到应用文件夹'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示权限申请对话框
  static Future<bool> _showPermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.save_alt, color: Colors.blue),
            SizedBox(width: 8),
            Text('需要存储权限'),
          ],
        ),
        content: const Text(
          '为了保存跑步路径图片，需要访问您的存储空间。\n\n'
          '这将帮助您保存和分享跑步成果。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('授予权限'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示设置对话框
  static Future<bool> _showSettingsDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('权限被拒绝'),
          ],
        ),
        content: const Text(
          '存储权限已被永久拒绝，无法保存图片。\n\n'
          '请前往设置页面手动开启存储权限。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('前往设置'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 生成路径图片
  static Future<Uint8List?> _generateRouteImage({
    required List<LatLng> routePoints,
    required double totalDistance,
    required int elapsedTime,
    required double averageSpeed,
    required int calories,
    required bool isSimulated,
  }) async {
    if (routePoints.isEmpty) return null;

    const double imageWidth = 800;
    const double imageHeight = 600;
    const double padding = 40;
    const double statsHeight = 120;
    const double mapHeight = imageHeight - statsHeight - padding * 2;

    // 创建图片画布
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 绘制背景
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, imageWidth, imageHeight),
      Paint()..color = Colors.white,
    );

    // 计算路径边界
    final bounds = _calculateBounds(routePoints);

    // 绘制路径
    _drawRoute(canvas, routePoints, bounds, padding, padding, imageWidth - padding * 2, mapHeight);

    // 绘制统计信息
    _drawStats(canvas, totalDistance, elapsedTime, averageSpeed, calories, isSimulated, padding,
        mapHeight + padding * 1.5, imageWidth - padding * 2, statsHeight);

    // 绘制标题
    _drawTitle(canvas, imageWidth, padding);

    // 转换为图片
    final picture = recorder.endRecording();
    final image = await picture.toImage(imageWidth.toInt(), imageHeight.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return bytes?.buffer.asUint8List();
  }

  /// 计算路径边界
  static _Bounds _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return _Bounds(0, 0, 0, 0);
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    // 添加一些边距
    const margin = 0.001;
    return _Bounds(
      minLat - margin,
      maxLat + margin,
      minLng - margin,
      maxLng + margin,
    );
  }

  /// 绘制路径
  static void _drawRoute(Canvas canvas, List<LatLng> points, _Bounds bounds, double offsetX,
      double offsetY, double width, double height) {
    if (points.length < 2) return;

    final path = Path();
    final paint = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 转换第一个点
    final firstPoint = _convertLatLngToPixel(points.first, bounds, width, height);
    path.moveTo(offsetX + firstPoint.dx, offsetY + firstPoint.dy);

    // 添加路径点
    for (int i = 1; i < points.length; i++) {
      final point = _convertLatLngToPixel(points[i], bounds, width, height);
      path.lineTo(offsetX + point.dx, offsetY + point.dy);
    }

    canvas.drawPath(path, paint);

    // 绘制起点和终点标记
    _drawMarkers(canvas, points, bounds, offsetX, offsetY, width, height);
  }

  /// 转换经纬度到像素坐标
  static Offset _convertLatLngToPixel(LatLng latLng, _Bounds bounds, double width, double height) {
    final x = (latLng.longitude - bounds.minLng) / (bounds.maxLng - bounds.minLng) * width;
    final y =
        height - ((latLng.latitude - bounds.minLat) / (bounds.maxLat - bounds.minLat) * height);
    return Offset(x, y);
  }

  /// 绘制起点和终点标记
  static void _drawMarkers(Canvas canvas, List<LatLng> points, _Bounds bounds, double offsetX,
      double offsetY, double width, double height) {
    if (points.isEmpty) return;

    // 起点 (绿色)
    final startPoint = _convertLatLngToPixel(points.first, bounds, width, height);
    canvas.drawCircle(
      Offset(offsetX + startPoint.dx, offsetY + startPoint.dy),
      8,
      Paint()..color = Colors.green,
    );

    // 终点 (红色)
    if (points.length > 1) {
      final endPoint = _convertLatLngToPixel(points.last, bounds, width, height);
      canvas.drawCircle(
        Offset(offsetX + endPoint.dx, offsetY + endPoint.dy),
        8,
        Paint()..color = Colors.red,
      );
    }
  }

  /// 绘制统计信息
  static void _drawStats(Canvas canvas, double totalDistance, int elapsedTime, double averageSpeed,
      int calories, bool isSimulated, double offsetX, double offsetY, double width, double height) {
    const textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    const titleStyle = TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    // 格式化数据
    final distance = '${(totalDistance / 1000).toStringAsFixed(2)} km';
    final time = _formatTime(elapsedTime);
    final speed = '${(averageSpeed * 3.6).toStringAsFixed(1)} km/h';
    final cal = '$calories kcal';

    // 绘制统计标题
    _drawText(canvas, '🏃‍♂️ 跑步统计', offsetX, offsetY, titleStyle);

    // 绘制统计数据 (两列布局)
    const double rowHeight = 25;
    final double colWidth = width / 2;

    _drawText(canvas, '📍 距离: $distance', offsetX, offsetY + 30, textStyle);
    _drawText(canvas, '⏱️ 时间: $time', offsetX + colWidth, offsetY + 30, textStyle);
    _drawText(canvas, '💨 速度: $speed', offsetX, offsetY + 30 + rowHeight, textStyle);
    _drawText(canvas, '🔥 卡路里: $cal', offsetX + colWidth, offsetY + 30 + rowHeight, textStyle);

    // 数据类型标识
    final dataType = isSimulated ? '📱 模拟GPS数据' : '📍 真实GPS数据';
    _drawText(canvas, dataType, offsetX, offsetY + 80,
        textStyle.copyWith(fontSize: 14, color: Colors.grey[600]));
  }

  /// 绘制标题
  static void _drawTitle(Canvas canvas, double width, double padding) {
    const titleStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    _drawText(canvas, '🏃‍♂️ 跑步路径记录', padding, padding - 10, titleStyle);

    // 绘制时间戳
    final dateTime = DateTime.now();
    final timestamp =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    const timeStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
    );

    _drawText(canvas, timestamp, width - 200, padding - 10, timeStyle);
  }

  /// 绘制文本
  static void _drawText(Canvas canvas, String text, double x, double y, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  /// 格式化时间
  static String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// 保存图片到设备
  static Future<String> _saveImageToDevice(Uint8List imageBytes) async {
    try {
      // 生成文件名
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = '跑步记录_${dateStr}_$timeStr.png';

      // 检查权限
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final requestResult = await Gal.requestAccess();
        if (!requestResult) {
          print('⚠️ 相册权限被拒绝，保存到应用目录');
          return await _saveImageToAppDirectory(imageBytes);
        }
      }

      // 使用 gal 直接保存到系统相册
      await Gal.putImageBytes(imageBytes, name: fileName);

      print('✅ 图片已保存到系统相册');
      return '已保存到系统相册';
    } catch (e) {
      print('保存图片失败: $e');
      // fallback：保存到应用内部
      return await _saveImageToAppDirectory(imageBytes);
    }
  }

  // 已改用系统相册保存，不再需要目录写入检查

  /// 保存到应用内部目录（fallback方案）
  static Future<String> _saveImageToAppDirectory(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();

    // 创建跑步记录文件夹
    final runningDir = Directory('${directory.path}/running_records');
    if (!await runningDir.exists()) {
      await runningDir.create(recursive: true);
    }

    // 生成文件名
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final fileName = '跑步记录_${dateStr}_$timeStr.png';
    final filePath = '${runningDir.path}/$fileName';

    // 保存文件
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    print('⚠️ 图片已保存到应用内部目录: $filePath');
    return filePath;
  }
}

/// 边界类
class _Bounds {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  _Bounds(this.minLat, this.maxLat, this.minLng, this.maxLng);
}
