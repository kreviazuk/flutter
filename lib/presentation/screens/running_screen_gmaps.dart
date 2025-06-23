import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// 🏃‍♂️ 跑步追踪页面 - 高帧率3D模式
class RunningScreenGMaps extends StatefulWidget {
  final Position? initialPosition;

  const RunningScreenGMaps({
    super.key,
    this.initialPosition,
  });

  @override
  State<RunningScreenGMaps> createState() => _RunningScreenGMapsState();
}

class _RunningScreenGMapsState extends State<RunningScreenGMaps> with TickerProviderStateMixin {
  GoogleMapController? _mapController;

  // 高帧率和3D相关
  late AnimationController _frameController;
  late AnimationController _3dController;
  bool _isHighFrameRate = false;
  bool _is3DMode = true;
  double _currentTilt = 45.0;
  double _currentBearing = 0.0;
  double _targetBearing = 0.0;
  int _currentFPS = 60;

  // GPS和位置数据
  Position? _currentPosition;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isLocationLoaded = false;

  // 模拟跑步相关
  bool _isSimulating = false;
  Timer? _simulationTimer;
  double _simulationAngle = 0;
  double _simulationSpeed = 3.0;
  int _simulationStep = 0;

  // 地图和路线数据
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];

  // 跑步状态
  bool _isRunning = false;
  bool _isPaused = false;
  String _statusMessage = '';

  // 跑步数据
  double _totalDistance = 0.0;
  int _elapsedTime = 0;
  double _currentSpeed = 0.0;
  double _averageSpeed = 0.0;
  int _calories = 0;
  Timer? _timer;

  // 地图初始位置（北京天安门广场）
  static const LatLng _defaultLocation = LatLng(39.909187, 116.397451);

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _frameController = AnimationController(
      duration: const Duration(milliseconds: 16), // 60 FPS
      vsync: this,
    );

    _3dController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 设置高刷新率模式
    _enableHighRefreshRate();

    // 优先使用传入的GPS位置，如果没有则使用默认位置
    if (widget.initialPosition != null) {
      // 使用真实的GPS位置
      _currentPosition = widget.initialPosition;
      setState(() {
        _isLocationLoaded = true;
        _statusMessage = 'GPS就绪，当前位置已锁定！ 🎮 高帧率3D模式';
      });
    } else {
      // 如果没有GPS位置，尝试获取当前位置
      _getCurrentLocation();
    }

    // 等待UI构建完成后更新地图
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mapController != null) {
        _updateMapLocation();
      }
    });
  }

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _statusMessage = '正在获取GPS位置...';
      });

      // 异步更新国际化文本
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          setState(() {
            _statusMessage = l10n.gettingGpsLocation;
          });
        }
      });

      // 检查位置服务是否开启
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _statusMessage = 'GPS服务未开启，使用默认位置';
          _currentPosition = Position(
            latitude: _defaultLocation.latitude,
            longitude: _defaultLocation.longitude,
            timestamp: DateTime.now(),
            accuracy: 5.0,
            altitude: 50.0,
            altitudeAccuracy: 3.0,
            heading: 0.0,
            headingAccuracy: 1.0,
            speed: 0.0,
            speedAccuracy: 1.0,
          );
          _isLocationLoaded = true;
        });

        // 异步更新国际化文本
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            setState(() {
              _statusMessage = l10n.gpsServiceNotEnabled;
            });
          }
        });
        return;
      }

      // 获取当前位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoaded = true;
        _statusMessage = 'GPS就绪，当前位置已锁定！ 🎮 高帧率3D模式';
      });

      // 等待UI构建完成后更新地图
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null) {
          _updateMapLocation();
        }
      });
    } catch (e) {
      print('获取位置失败: $e');
      setState(() {
        _statusMessage = '位置获取失败，使用默认位置';
        _currentPosition = Position(
          latitude: _defaultLocation.latitude,
          longitude: _defaultLocation.longitude,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 50.0,
          altitudeAccuracy: 3.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );
        _isLocationLoaded = true;
      });

      // 异步更新国际化文本
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          setState(() {
            _statusMessage = l10n.locationFailed;
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里可以安全地访问 AppLocalizations
    _updateInitialStatusMessage();
  }

  void _updateInitialStatusMessage() {
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        if (_statusMessage.contains('GPS就绪，当前位置已锁定！ 🎮 高帧率3D模式')) {
          _statusMessage = '${l10n.gpsReady} 🎮 ${l10n.highFrameRate3DMode}';
        }
      });
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    _simulationTimer?.cancel();
    _frameController.dispose();
    _3dController.dispose();
    super.dispose();
  }

  /// 启用高刷新率
  void _enableHighRefreshRate() {
    // 尝试启用高刷新率
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      if (_isHighFrameRate && _isRunning) {
        // 强制重绘以维持高帧率
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  /// 切换帧率模式
  void _toggleFrameRate() {
    setState(() {
      _isHighFrameRate = !_isHighFrameRate;
      _currentFPS = _isHighFrameRate ? 120 : 60;

      // 更新动画控制器持续时间
      _frameController.duration = Duration(
        milliseconds: _isHighFrameRate ? 8 : 16, // 120fps or 60fps
      );

      final l10n = AppLocalizations.of(context)!;
      final modeText = _is3DMode ? l10n.threeDMode : l10n.twoDMode;
      _statusMessage = _isRunning
          ? '${l10n.runningMode}'.replaceAll('{fps}', '$_currentFPS').replaceAll('{mode}', modeText)
          : '${l10n.gpsReadyMode}'
              .replaceAll('{fps}', '$_currentFPS')
              .replaceAll('{mode}', modeText);
    });

    // 显示帧率切换提示
    _showFrameRateToast();
  }

  /// 切换3D模式
  void _toggle3DMode() {
    setState(() {
      _is3DMode = !_is3DMode;
      _currentTilt = _is3DMode ? 45.0 : 0.0;

      final l10n = AppLocalizations.of(context)!;
      final modeText = _is3DMode ? l10n.threeDMode : l10n.twoDMode;
      _statusMessage = _isRunning
          ? '${l10n.runningMode}'.replaceAll('{fps}', '$_currentFPS').replaceAll('{mode}', modeText)
          : '${l10n.gpsReadyMode}'
              .replaceAll('{fps}', '$_currentFPS')
              .replaceAll('{mode}', modeText);
    });

    // 平滑切换3D视角
    _3dController.reset();
    _3dController.forward();

    _updateMapLocation();
    _show3DModeToast();
  }

  /// 显示帧率切换提示
  void _showFrameRateToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isHighFrameRate ? Icons.speed : Icons.refresh,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text('${AppLocalizations.of(context)!.switchToFpsMode}'
                .replaceAll('{fps}', '$_currentFPS')),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示3D模式切换提示
  void _show3DModeToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _is3DMode ? Icons.view_in_ar : Icons.map,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text('${AppLocalizations.of(context)!.switchToViewMode}'.replaceAll(
                '{mode}',
                _is3DMode
                    ? AppLocalizations.of(context)!.threeDMode
                    : AppLocalizations.of(context)!.twoDMode)),
          ],
        ),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 更新地图位置（增强3D效果）
  Future<void> _updateMapLocation() async {
    if (_currentPosition == null || _mapController == null) return;

    final LatLng currentLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // 在3D模式下，根据移动方向动态调整bearing
    if (_is3DMode && _isRunning) {
      _targetBearing = _simulationAngle * 180 / math.pi;
      // 平滑插值bearing变化
      _currentBearing = _currentBearing + (_targetBearing - _currentBearing) * 0.1;
    }

    // 高质量的相机更新
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: _is3DMode ? 19.0 : 18.0, // 3D模式下稍微拉近
          tilt: _currentTilt,
          bearing: _is3DMode ? _currentBearing : 0.0,
        ),
      ),
    );

    // 更新当前位置标记 - 使用更明显的标记
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: AppLocalizations.of(context)!.currentLocation,
            snippet:
                '${_currentFPS}FPS ${_is3DMode ? AppLocalizations.of(context)!.threeDMode : AppLocalizations.of(context)!.twoDMode}${AppLocalizations.of(context)!.mode}',
          ),
        ),
      );
    });
  }

  /// 开始跑步（模拟）
  void _startRunning() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    final l10n = AppLocalizations.of(context)!;
    _updateStatusMessage(l10n);

    // 添加开始标记
    _markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '🏃‍♀️ ${l10n.runningStarted}',
          snippet: l10n.runningStarted,
        ),
      ),
    );

    // 开始模拟位置追踪（更高频率）
    _startSimulatedLocationTracking();

    // 开始计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning && !_isPaused) {
        setState(() {
          _elapsedTime++;
          _updateRunningStats();
        });
      }
    });

    // 震动反馈
    HapticFeedback.lightImpact();
  }

  /// 开始模拟位置追踪（高频率更新）
  void _startSimulatedLocationTracking() {
    // 高帧率模式下更频繁更新位置
    final updateInterval = _isHighFrameRate
        ? const Duration(milliseconds: 500) // 2FPS位置更新
        : const Duration(seconds: 1); // 1FPS位置更新

    _simulationTimer = Timer.periodic(updateInterval, (timer) {
      if (_isRunning && !_isPaused && _isSimulating) {
        _generateNextSimulatedPosition();
      }
    });
  }

  /// 生成下一个模拟位置（优化3D效果）
  void _generateNextSimulatedPosition() {
    if (_currentPosition == null) return;

    _simulationStep++;

    // 模拟更真实的跑步路径
    double distance = 8 + math.Random().nextDouble() * 12; // 8-20米每次更新

    // 更自然的方向变化
    if (_simulationStep % (5 + math.Random().nextInt(8)) == 0) {
      _simulationAngle += (math.Random().nextDouble() - 0.5) * math.pi / 3; // 更小的转向角度
    }

    // 计算新位置
    double latOffset = distance * math.cos(_simulationAngle) / 111000;
    double lonOffset = distance *
        math.sin(_simulationAngle) /
        (111000 * math.cos(_currentPosition!.latitude * math.pi / 180));

    double newLat = _currentPosition!.latitude + latOffset;
    double newLon = _currentPosition!.longitude + lonOffset;

    // 模拟更真实的速度变化
    double simulatedSpeed =
        2.5 + math.sin(_simulationStep * 0.1) * 1.5 + math.Random().nextDouble() * 0.5;

    Position newPosition = Position(
      latitude: newLat,
      longitude: newLon,
      timestamp: DateTime.now(),
      accuracy: 2.0 + math.Random().nextDouble() * 1.0, // 2-3米精度
      altitude: 50.0 + math.sin(_simulationStep * 0.05) * 5.0,
      altitudeAccuracy: 2.0,
      heading: _simulationAngle * 180 / math.pi,
      headingAccuracy: 3.0,
      speed: simulatedSpeed,
      speedAccuracy: 0.3,
    );

    _updateRunningPosition(newPosition);
  }

  /// 暂停跑步
  void _pauseRunning() {
    setState(() {
      _isPaused = !_isPaused;
    });

    final l10n = AppLocalizations.of(context)!;
    _updateStatusMessage(l10n);

    if (_isPaused) {
      _timer?.cancel();
      _simulationTimer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isRunning && !_isPaused) {
          setState(() {
            _elapsedTime++;
            _updateRunningStats();
          });
        }
      });
      _startSimulatedLocationTracking();
    }

    HapticFeedback.lightImpact();
  }

  /// 停止跑步
  void _stopRunning() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    final l10n = AppLocalizations.of(context)!;
    _statusMessage = l10n.runningEnded;

    _timer?.cancel();
    _simulationTimer?.cancel();

    // 添加结束标记
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: '🏁 ${l10n.runningCompleted}',
            snippet: l10n.runningCompleted,
          ),
        ),
      );
    }

    // 显示跑步总结
    _showRunningSummary();

    HapticFeedback.mediumImpact();
  }

  /// 更新跑步位置
  void _updateRunningPosition(Position newPosition) {
    if (_currentPosition != null) {
      // 计算距离
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      setState(() {
        _totalDistance += distance;
        _lastPosition = _currentPosition;
        _currentPosition = newPosition;
        _currentSpeed = newPosition.speed;
      });

      // 添加路线点
      final newPoint = LatLng(newPosition.latitude, newPosition.longitude);
      _routePoints.add(newPoint);

      // 更新路线
      _updateRoute();

      // 更新地图位置
      _updateMapLocation();
    } else {
      setState(() {
        _currentPosition = newPosition;
      });
    }
  }

  /// 更新路线显示（增强3D效果）
  void _updateRoute() {
    if (_routePoints.length < 2) return;

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('running_route'),
          points: _routePoints,
          color: _is3DMode ? AppColors.primary : AppColors.secondary,
          width: _is3DMode ? 8 : 6, // 3D模式下更粗的线条
          patterns: _is3DMode
              ? [PatternItem.dash(30), PatternItem.gap(15)] // 3D模式更长的虚线
              : [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    });
  }

  /// 更新跑步统计数据
  void _updateRunningStats() {
    if (_elapsedTime > 0) {
      _averageSpeed = _totalDistance / _elapsedTime;
      // 简单的卡路里计算（约每公里消耗50卡路里）
      _calories = (_totalDistance / 1000 * 50).round();
    }
  }

  /// 显示跑步总结
  void _showRunningSummary() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.runningComplete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryItem(
                l10n.totalDistance,
                '${(_totalDistance / 1000).toStringAsFixed(2)} ${l10n.kilometers}',
                Icons.straighten),
            _buildSummaryItem(l10n.time, _formatTime(_elapsedTime), Icons.timer),
            _buildSummaryItem(
                l10n.averageSpeed,
                '${(_averageSpeed * 3.6).toStringAsFixed(1)} ${l10n.kilometersPerHour}',
                Icons.speed),
            _buildSummaryItem(
                l10n.caloriesBurned, '$_calories ${l10n.kcal}', Icons.local_fire_department),
            const SizedBox(height: 16),
            Text(
              l10n.simulatedDataNote,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetRunning();
            },
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// 重置跑步数据
  void _resetRunning() {
    setState(() {
      _totalDistance = 0.0;
      _elapsedTime = 0;
      _currentSpeed = 0.0;
      _averageSpeed = 0.0;
      _calories = 0;
      _simulationStep = 0;
      _simulationAngle = 0;
      _currentBearing = 0.0;
      _targetBearing = 0.0;
      _routePoints.clear();
      _polylines.clear();

      // 清除所有标记，重新添加当前位置
      _markers.clear();
      final l10n = AppLocalizations.of(context)!;
      _statusMessage = '${l10n.gpsReadyMode}'
          .replaceAll('{fps}', '$_currentFPS')
          .replaceAll('{mode}', _is3DMode ? l10n.threeDMode : l10n.twoDMode);
    });

    // 重置到初始位置
    _currentPosition = Position(
      latitude: _defaultLocation.latitude,
      longitude: _defaultLocation.longitude,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 50.0,
      altitudeAccuracy: 3.0,
      heading: 0.0,
      headingAccuracy: 1.0,
      speed: 0.0,
      speedAccuracy: 1.0,
    );

    _updateMapLocation();
  }

  /// 格式化时间显示
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化速度显示
  String _formatSpeed(double speedMs) {
    double speedKmh = speedMs * 3.6;
    return speedKmh.toStringAsFixed(1);
  }

  /// 格式化配速显示 (分钟/公里)
  String _formatPace(double speedMs) {
    if (speedMs <= 0) return '--:--';
    double paceSeconds = 1000 / speedMs; // 秒/公里
    int minutes = paceSeconds ~/ 60;
    int seconds = (paceSeconds % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 构建统计项目
  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isRunning ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 更新状态消息
  void _updateStatusMessage(AppLocalizations l10n) {
    final modeText = _is3DMode ? l10n.threeDMode : l10n.twoDMode;
    if (_isRunning) {
      if (_isPaused) {
        _statusMessage =
            '${l10n.pausedMode}'.replaceAll('{fps}', '$_currentFPS').replaceAll('{mode}', modeText);
      } else {
        _statusMessage = '${l10n.runningMode}'
            .replaceAll('{fps}', '$_currentFPS')
            .replaceAll('{mode}', modeText);
      }
    } else {
      _statusMessage =
          '${l10n.gpsReadyMode}'.replaceAll('{fps}', '$_currentFPS').replaceAll('{mode}', modeText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Google地图 - 高性能3D渲染
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _defaultLocation,
              zoom: 18,
              tilt: _currentTilt,
              bearing: _currentBearing,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                _updateMapLocation();
              }
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            buildingsEnabled: _is3DMode, // 3D模式下启用建筑
            trafficEnabled: true,
            compassEnabled: _is3DMode, // 3D模式下显示指南针
            rotateGesturesEnabled: _is3DMode, // 3D模式下允许旋转
            tiltGesturesEnabled: _is3DMode, // 3D模式下允许倾斜
          ),

          // 顶部状态栏 - 增强3D视觉效果
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _statusMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        if (_isSimulating)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isHighFrameRate ? Icons.speed : Icons.refresh,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_currentFPS}FPS',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                _is3DMode ? Icons.view_in_ar : Icons.map,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _is3DMode ? '3D' : '2D',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // 帧率切换按钮
                  IconButton(
                    onPressed: _toggleFrameRate,
                    icon: Icon(
                      _isHighFrameRate ? Icons.speed : Icons.refresh,
                      color: _isHighFrameRate ? Colors.greenAccent : Colors.white,
                    ),
                    tooltip: '切换帧率: ${_isHighFrameRate ? "120" : "60"}FPS',
                  ),
                  // 3D模式切换按钮
                  IconButton(
                    onPressed: _toggle3DMode,
                    icon: Icon(
                      _is3DMode ? Icons.view_in_ar : Icons.map,
                      color: _is3DMode ? Colors.blueAccent : Colors.white,
                    ),
                    tooltip: '切换视角: ${_is3DMode ? "3D" : "2D"}',
                  ),
                ],
              ),
            ),
          ),

          // 跑步数据卡片 - 3D增强UI
          Positioned(
            top: MediaQuery.of(context).padding.top + 110,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_is3DMode ? 0.2 : 0.1),
                    blurRadius: _is3DMode ? 15 : 10,
                    offset: Offset(0, _is3DMode ? 6 : 4),
                  ),
                ],
                border: _is3DMode
                    ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
                    : null,
              ),
              child: Column(
                children: [
                  // 性能指示器
                  if (_isRunning)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.secondary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isHighFrameRate ? Icons.speed : Icons.refresh,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '🎮 ${_currentFPS}FPS ${_is3DMode ? l10n.threeDMode : l10n.twoDMode}${l10n.mode}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(l10n.distance,
                          '${(_totalDistance / 1000).toStringAsFixed(2)} ${l10n.kilometers}'),
                      _buildStatItem(l10n.time, _formatTime(_elapsedTime)),
                      _buildStatItem(
                          l10n.speed, '${_formatSpeed(_currentSpeed)} ${l10n.kilometersPerHour}'),
                      _buildStatItem(l10n.calories, '$_calories'),
                    ],
                  ),
                  if (_isRunning) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPaused ? Icons.pause_circle : Icons.play_circle,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '配速: ${_formatPace(_averageSpeed)} /${l10n.kilometers}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 底部控制按钮 - 3D增强样式
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // 开始按钮
                if (!_isRunning)
                  Expanded(
                    child: _buildControlButton(
                      l10n.startSimulatedRun,
                      AppColors.primary,
                      () => _startRunning(),
                      Icons.play_arrow,
                    ),
                  ),

                // 暂停/继续按钮
                if (_isRunning) ...[
                  Expanded(
                    child: _buildControlButton(
                      _isPaused ? l10n.continueText : l10n.pause,
                      _isPaused ? AppColors.secondary : Colors.orange,
                      () => _pauseRunning(),
                      _isPaused ? Icons.play_arrow : Icons.pause,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 停止按钮
                  Expanded(
                    child: _buildControlButton(
                      l10n.stop,
                      Colors.red,
                      () => _stopRunning(),
                      Icons.stop,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 路线点数和性能指示器
          if (_routePoints.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 260,
              right: 16,
              child: Column(
                children: [
                  // 路线点数指示器
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '🗺️ ${_routePoints.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (_isRunning) ...[
                    const SizedBox(height: 8),
                    // 实时FPS指示器
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isHighFrameRate ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_currentFPS}FPS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, Color color, VoidCallback onPressed, IconData icon) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
