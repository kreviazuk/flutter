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
    const double imageHeight = 1200;
    const double padding = 40;
    const double mapHeight = 720;
    const double userInfoHeight = 160;
    const double statsHeight = 280;

    // 创建图片画布
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 绘制背景
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, imageWidth, imageHeight),
      Paint()..color = const Color(0xFFF8F9FA),
    );

    // 计算路径边界
    final bounds = _calculateBounds(routePoints);

    // 绘制地图区域（带圆角背景）
    final mapRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(padding, padding, imageWidth - padding * 2, mapHeight),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      mapRect,
      Paint()..color = Colors.white,
    );

    // 绘制路径
    _drawModernRoute(canvas, routePoints, bounds, padding + 10, padding + 10,
        imageWidth - padding * 2 - 20, mapHeight - 20);

    // 绘制用户信息
    _drawUserInfo(
        canvas, padding, mapHeight + padding + 10, imageWidth - padding * 2, userInfoHeight);

    // 绘制现代化统计数据
    _drawModernStats(canvas, totalDistance, elapsedTime, averageSpeed, padding,
        mapHeight + userInfoHeight + padding + 30, imageWidth - padding * 2, statsHeight);

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

    // 计算当前范围
    double latRange = maxLat - minLat;
    double lngRange = maxLng - minLng;

    // 确保最小范围，避免点过于集中导致显示问题
    const double minRange = 0.002; // 大约200米的范围
    if (latRange < minRange) {
      final center = (minLat + maxLat) / 2;
      minLat = center - minRange / 2;
      maxLat = center + minRange / 2;
      latRange = minRange;
    }

    if (lngRange < minRange) {
      final center = (minLng + maxLng) / 2;
      minLng = center - minRange / 2;
      maxLng = center + minRange / 2;
      lngRange = minRange;
    }

    // 添加边距 (10%的范围作为边距)
    final latMargin = latRange * 0.1;
    final lngMargin = lngRange * 0.1;

    print('📊 路径边界：纬度 $minLat ~ $maxLat, 经度 $minLng ~ $maxLng');
    print('📏 范围：纬度 ${latRange.toStringAsFixed(6)}, 经度 ${lngRange.toStringAsFixed(6)}');

    return _Bounds(
      minLat - latMargin,
      maxLat + latMargin,
      minLng - lngMargin,
      maxLng + lngMargin,
    );
  }

  /// 绘制现代化路径
  static void _drawModernRoute(Canvas canvas, List<LatLng> points, _Bounds bounds, double offsetX,
      double offsetY, double width, double height) {
    // 绘制地图背景网格（总是绘制，即使没有路径）
    _drawMapGrid(canvas, offsetX, offsetY, width, height);

    // 如果没有足够的点，显示提示信息
    if (points.isEmpty) {
      _drawCenteredText(
        canvas,
        '暂无路径数据',
        offsetX + width / 2,
        offsetY + height / 2,
        const TextStyle(
          fontSize: 64,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
      );
      return;
    }

    // 如果只有一个点，绘制单点标记
    if (points.length == 1) {
      final point = _convertLatLngToPixel(points.first, bounds, width, height);
      canvas.drawCircle(
        Offset(offsetX + point.dx, offsetY + point.dy),
        8,
        Paint()..color = const Color(0xFF10B981),
      );
      canvas.drawCircle(
        Offset(offsetX + point.dx, offsetY + point.dy),
        4,
        Paint()..color = Colors.white,
      );
      return;
    }

    final path = Path();
    final paint = Paint()
      ..color = const Color(0xFFFF6B35) // 橙色路径
      ..strokeWidth = 6 // 增加线宽以适应高分辨率
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 转换第一个点
    final firstPoint = _convertLatLngToPixel(points.first, bounds, width, height);
    path.moveTo(offsetX + firstPoint.dx, offsetY + firstPoint.dy);

    print('🗺️ 绘制路径：共 ${points.length} 个点');
    print('📍 起点：${points.first.latitude}, ${points.first.longitude}');
    print('📐 像素坐标：${firstPoint.dx}, ${firstPoint.dy}');

    // 添加路径点
    for (int i = 1; i < points.length; i++) {
      final point = _convertLatLngToPixel(points[i], bounds, width, height);
      path.lineTo(offsetX + point.dx, offsetY + point.dy);
    }

    canvas.drawPath(path, paint);

    // 绘制现代化的起点和终点标记
    _drawModernMarkers(canvas, points, bounds, offsetX, offsetY, width, height);
  }

  /// 绘制地图网格背景
  static void _drawMapGrid(
      Canvas canvas, double offsetX, double offsetY, double width, double height) {
    // 绘制背景色
    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, width, height),
      Paint()..color = const Color(0xFFF8FAFC),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.8)
      ..strokeWidth = 1.5;

    // 绘制垂直线 (间距调整为适应高分辨率)
    for (double x = offsetX; x <= offsetX + width; x += 40) {
      canvas.drawLine(
        Offset(x, offsetY),
        Offset(x, offsetY + height),
        gridPaint,
      );
    }

    // 绘制水平线
    for (double y = offsetY; y <= offsetY + height; y += 40) {
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(offsetX + width, y),
        gridPaint,
      );
    }

    // 绘制地图边框
    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, width, height),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  /// 绘制现代化标记
  static void _drawModernMarkers(Canvas canvas, List<LatLng> points, _Bounds bounds, double offsetX,
      double offsetY, double width, double height) {
    if (points.isEmpty) return;

    // 起点 (绿色圆点) - 适应高分辨率
    final startPoint = _convertLatLngToPixel(points.first, bounds, width, height);
    canvas.drawCircle(
      Offset(offsetX + startPoint.dx, offsetY + startPoint.dy),
      12,
      Paint()..color = const Color(0xFF10B981),
    );
    canvas.drawCircle(
      Offset(offsetX + startPoint.dx, offsetY + startPoint.dy),
      6,
      Paint()..color = Colors.white,
    );

    // 终点 (红色圆点) - 适应高分辨率
    if (points.length > 1) {
      final endPoint = _convertLatLngToPixel(points.last, bounds, width, height);
      canvas.drawCircle(
        Offset(offsetX + endPoint.dx, offsetY + endPoint.dy),
        12,
        Paint()..color = const Color(0xFFEF4444),
      );
      canvas.drawCircle(
        Offset(offsetX + endPoint.dx, offsetY + endPoint.dy),
        6,
        Paint()..color = Colors.white,
      );
    }
  }

  /// 转换经纬度到像素坐标
  static Offset _convertLatLngToPixel(LatLng latLng, _Bounds bounds, double width, double height) {
    final x = (latLng.longitude - bounds.minLng) / (bounds.maxLng - bounds.minLng) * width;
    final y =
        height - ((latLng.latitude - bounds.minLat) / (bounds.maxLat - bounds.minLat) * height);
    return Offset(x, y);
  }

  /// 绘制用户信息
  static void _drawUserInfo(
      Canvas canvas, double offsetX, double offsetY, double width, double height) {
    // 绘制头像背景 - 适应高分辨率
    canvas.drawCircle(
      Offset(offsetX + 60, offsetY + 60),
      40,
      Paint()..color = const Color(0xFF6B7280),
    );

    // 绘制头像图标
    _drawText(
      canvas,
      '👤',
      offsetX + 40,
      offsetY + 40,
      const TextStyle(
        fontSize: 40,
        color: Colors.white,
      ),
    );

    // 绘制用户名
    _drawText(
      canvas,
      '跑步爱好者',
      offsetX + 120,
      offsetY + 30,
      const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );

    // 绘制时间
    final now = DateTime.now();
    final timeString = _formatDateTime(now);
    _drawText(
      canvas,
      timeString,
      offsetX + 120,
      offsetY + 80,
      const TextStyle(
        fontSize: 28,
        color: Color(0xFF6B7280),
      ),
    );
  }

  /// 绘制现代化统计数据
  static void _drawModernStats(Canvas canvas, double totalDistance, int elapsedTime,
      double averageSpeed, double offsetX, double offsetY, double width, double height) {
    // 计算配速 (分钟/公里)，防止除零错误
    String paceString = '--:--';
    if (totalDistance > 0) {
      final distanceInKm = totalDistance / 1000;
      final paceInMinutesPerKm = elapsedTime / distanceInKm / 60;
      final paceMinutes = paceInMinutesPerKm.floor();
      final paceSeconds = ((paceInMinutesPerKm - paceMinutes) * 60).round();
      paceString = '${paceMinutes}:${paceSeconds.toString().padLeft(2, '0')}';
    }

    // 格式化数据
    final timeString = _formatTime(elapsedTime);
    final distanceString = '${(totalDistance / 1000).toStringAsFixed(2)}';

    // 绘制三列统计数据
    final columnWidth = width / 3;

    // Time 列
    _drawStatColumn(canvas, 'Time', timeString, '', offsetX, offsetY, columnWidth);

    // Distance 列
    _drawStatColumn(
        canvas, 'Distance', distanceString, 'km', offsetX + columnWidth, offsetY, columnWidth);

    // Avg. Pace 列
    _drawStatColumn(
        canvas, 'Avg. Pace', paceString, 'min/km', offsetX + columnWidth * 2, offsetY, columnWidth);
  }

  /// 绘制单个统计列
  static void _drawStatColumn(Canvas canvas, String label, String value, String unit,
      double offsetX, double offsetY, double width) {
    // 绘制标签 - 适应高分辨率
    _drawCenteredText(
      canvas,
      label,
      offsetX + width / 2,
      offsetY,
      const TextStyle(
        fontSize: 28,
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w500,
      ),
    );

    // 绘制数值 - 适应高分辨率
    _drawCenteredText(
      canvas,
      value,
      offsetX + width / 2,
      offsetY + 60,
      const TextStyle(
        fontSize: 64,
        color: Color(0xFF1F2937),
        fontWeight: FontWeight.bold,
      ),
    );

    // 绘制单位 - 适应高分辨率
    if (unit.isNotEmpty) {
      _drawCenteredText(
        canvas,
        unit,
        offsetX + width / 2,
        offsetY + 140,
        const TextStyle(
          fontSize: 24,
          color: Color(0xFF6B7280),
        ),
      );
    }
  }

  // 旧的绘制方法已移除，使用现代化布局

  /// 绘制文本
  static void _drawText(Canvas canvas, String text, double x, double y, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  /// 绘制居中文本
  static void _drawCenteredText(
      Canvas canvas, String text, double centerX, double y, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, y));
  }

  /// 格式化日期时间
  static String _formatDateTime(DateTime dateTime) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$month $day, $year at $displayHour:${minute.toString().padLeft(2, '0')} $ampm';
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
