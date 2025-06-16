import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;
import '../theme/app_colors.dart';

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
  String _statusMessage = '正在获取位置...';

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

    // 使用默认位置开始，模拟用户在北京
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

    setState(() {
      _isLocationLoaded = true;
      _statusMessage = 'GPS就绪，可以开始跑步了！ 🎮 高帧率3D模式';
    });

    // 等待UI构建完成后更新地图
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mapController != null) {
        _updateMapLocation();
      }
    });
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

      _statusMessage = _isRunning
          ? '跑步中... (${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式)'
          : 'GPS就绪！ 🎮 ${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式';
    });

    // 显示帧率切换提示
    _showFrameRateToast();
  }

  /// 切换3D模式
  void _toggle3DMode() {
    setState(() {
      _is3DMode = !_is3DMode;
      _currentTilt = _is3DMode ? 45.0 : 0.0;

      _statusMessage = _isRunning
          ? '跑步中... (${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式)'
          : 'GPS就绪！ 🎮 ${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式';
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
            Text('🎮 切换到 ${_currentFPS}FPS 模式'),
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
            Text('🌐 切换到 ${_is3DMode ? "3D" : "2D"} 视角'),
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
            title: '🏃‍♂️ 当前位置',
            snippet: '${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式',
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
      _statusMessage = '跑步中... (${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式)';
      _isSimulating = true;
    });

    // 启用高帧率模式
    if (!_isHighFrameRate) {
      _toggleFrameRate();
    }

    // 开始帧率动画循环
    _frameController.repeat();

    // 添加起点标记
    if (_currentPosition != null) {
      final startPoint = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _routePoints.add(startPoint);

      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('start_point'),
            position: startPoint,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(
              title: '🚀 起点',
              snippet: '跑步开始！',
            ),
          ),
        );
      });
    }

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
      _statusMessage = _isPaused
          ? '已暂停 (${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式)'
          : '跑步中... (${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式)';
    });

    if (_isPaused) {
      _frameController.stop();
    } else {
      _frameController.repeat();
    }

    HapticFeedback.mediumImpact();
  }

  /// 停止跑步
  void _stopRunning() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isSimulating = false;
      _statusMessage = '跑步结束 - 太棒了！ 🎉';
    });

    _simulationTimer?.cancel();
    _timer?.cancel();
    _frameController.stop();

    // 添加终点标记
    if (_currentPosition != null) {
      final endPoint = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('end_point'),
            position: endPoint,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: const InfoWindow(
              title: '🏁 终点',
              snippet: '跑步完成！',
            ),
          ),
        );
      });
    }

    HapticFeedback.heavyImpact();
    _showRunSummary();
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
  void _showRunSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🎉 跑步完成！'),
            Spacer(),
            Icon(Icons.sports_score, color: AppColors.primary),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryItem(
                '总距离', '${(_totalDistance / 1000).toStringAsFixed(2)} 公里', Icons.straighten),
            _buildSummaryItem('用时', _formatTime(_elapsedTime), Icons.timer),
            _buildSummaryItem(
                '平均速度', '${(_averageSpeed * 3.6).toStringAsFixed(1)} 公里/小时', Icons.speed),
            _buildSummaryItem('当前配速', '${_formatPace(_averageSpeed)} /公里', Icons.directions_run),
            _buildSummaryItem('消耗卡路里', '$_calories 千卡', Icons.local_fire_department),
            _buildSummaryItem('路线点数', '${_routePoints.length}', Icons.route),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.gamepad, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '性能统计: ${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '📱 这是模拟数据，实际使用需要开启GPS',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.home),
            label: const Text('完成'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _resetRunning();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重新开始'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
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
      _statusMessage = 'GPS就绪！ 🎮 ${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式';
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

  @override
  Widget build(BuildContext context) {
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
                            '🎮 ${_currentFPS}FPS ${_is3DMode ? "3D" : "2D"}模式',
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
                      _buildStatItem('距离', '${(_totalDistance / 1000).toStringAsFixed(2)} km'),
                      _buildStatItem('时间', _formatTime(_elapsedTime)),
                      _buildStatItem('速度', '${_formatSpeed(_currentSpeed)} km/h'),
                      _buildStatItem('卡路里', '$_calories'),
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
                            '配速: ${_formatPace(_averageSpeed)} /公里',
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

          // 底部控制面板 - 3D增强设计
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_is3DMode ? 0.2 : 0.1),
                    blurRadius: _is3DMode ? 20 : 15,
                    offset: Offset(0, _is3DMode ? -8 : -4),
                  ),
                ],
                border: _is3DMode
                    ? Border.all(color: AppColors.primary.withOpacity(0.2), width: 1)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isRunning) ...[
                    // 开始按钮 - 3D增强
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.success, Color(0xFF4CAF50)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _startRunning,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow, size: 24),
                              SizedBox(width: 8),
                              Text('开始模拟跑步',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // 暂停/继续按钮
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isPaused
                                ? [AppColors.success, const Color(0xFF4CAF50)]
                                : [AppColors.warning, const Color(0xFFFFA726)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: (_isPaused ? AppColors.success : AppColors.warning)
                                  .withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _pauseRunning,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                _isPaused ? '继续' : '暂停',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 停止按钮
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.error, Color(0xFFE57373)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _stopRunning,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stop, size: 24),
                              SizedBox(width: 8),
                              Text('结束',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
}
