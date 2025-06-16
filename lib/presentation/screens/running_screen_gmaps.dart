import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;
import '../theme/app_colors.dart';

/// 🏃‍♂️ 跑步追踪页面 - 使用 Google Maps + 模拟跑步
class RunningScreenGMaps extends StatefulWidget {
  final Position? initialPosition;

  const RunningScreenGMaps({
    super.key,
    this.initialPosition,
  });

  @override
  State<RunningScreenGMaps> createState() => _RunningScreenGMapsState();
}

class _RunningScreenGMapsState extends State<RunningScreenGMaps> {
  GoogleMapController? _mapController;

  // GPS和位置数据
  Position? _currentPosition;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isLocationLoaded = false;

  // 模拟跑步相关
  bool _isSimulating = false;
  Timer? _simulationTimer;
  double _simulationAngle = 0; // 模拟移动的角度
  double _simulationSpeed = 3.0; // 模拟速度 (m/s)
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
      _statusMessage = 'GPS就绪，可以开始跑步了！';
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
    super.dispose();
  }

  /// 更新地图位置
  Future<void> _updateMapLocation() async {
    if (_currentPosition == null || _mapController == null) return;

    final LatLng currentLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // 平滑移动地图中心
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(currentLatLng, 18),
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
            snippet: '正在跑步中...',
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
      _statusMessage = '跑步中... (模拟模式)';
      _isSimulating = true;
    });

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

    // 开始模拟位置追踪
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
  }

  /// 开始模拟位置追踪
  void _startSimulatedLocationTracking() {
    // 每2秒更新一次位置，模拟真实跑步
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isRunning && !_isPaused && _isSimulating) {
        _generateNextSimulatedPosition();
      }
    });
  }

  /// 生成下一个模拟位置
  void _generateNextSimulatedPosition() {
    if (_currentPosition == null) return;

    _simulationStep++;

    // 模拟跑步路径：每次移动15-25米，随机改变方向
    double distance = 15 + math.Random().nextDouble() * 10; // 15-25米

    // 每10步左右改变方向，模拟真实跑步路径
    if (_simulationStep % (8 + math.Random().nextInt(5)) == 0) {
      _simulationAngle += (math.Random().nextDouble() - 0.5) * math.pi / 2; // 随机转向
    }

    // 计算新位置
    double latOffset = distance * math.cos(_simulationAngle) / 111000; // 纬度偏移
    double lonOffset = distance *
        math.sin(_simulationAngle) /
        (111000 * math.cos(_currentPosition!.latitude * math.pi / 180)); // 经度偏移

    double newLat = _currentPosition!.latitude + latOffset;
    double newLon = _currentPosition!.longitude + lonOffset;

    // 模拟速度变化 (2-5 m/s)
    double simulatedSpeed = 2.0 + math.Random().nextDouble() * 3.0;

    Position newPosition = Position(
      latitude: newLat,
      longitude: newLon,
      timestamp: DateTime.now(),
      accuracy: 3.0 + math.Random().nextDouble() * 2.0, // 3-5米精度
      altitude: 50.0 + math.Random().nextDouble() * 10.0,
      altitudeAccuracy: 3.0,
      heading: _simulationAngle * 180 / math.pi, // 转换为度
      headingAccuracy: 5.0,
      speed: simulatedSpeed,
      speedAccuracy: 0.5,
    );

    _updateRunningPosition(newPosition);
  }

  /// 暂停跑步
  void _pauseRunning() {
    setState(() {
      _isPaused = !_isPaused;
      _statusMessage = _isPaused ? '已暂停 (模拟模式)' : '跑步中... (模拟模式)';
    });
  }

  /// 停止跑步
  void _stopRunning() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isSimulating = false;
      _statusMessage = '跑步结束';
    });

    _simulationTimer?.cancel();
    _timer?.cancel();

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

  /// 更新路线显示
  void _updateRoute() {
    if (_routePoints.length < 2) return;

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('running_route'),
          points: _routePoints,
          color: AppColors.primary,
          width: 6,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)], // 虚线效果
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
        title: const Text('🎉 跑步完成！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('总距离: ${(_totalDistance / 1000).toStringAsFixed(2)} 公里'),
            Text('用时: ${_formatTime(_elapsedTime)}'),
            Text('平均速度: ${(_averageSpeed * 3.6).toStringAsFixed(1)} 公里/小时'),
            Text('当前配速: ${_formatPace(_averageSpeed)} /公里'),
            Text('消耗卡路里: $_calories 千卡'),
            Text('路线点数: ${_routePoints.length}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📱 这是模拟数据，实际使用需要开启GPS',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('完成'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetRunning();
            },
            child: const Text('重新开始'),
          ),
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
      _routePoints.clear();
      _polylines.clear();

      // 清除所有标记，重新添加当前位置
      _markers.clear();
      _statusMessage = 'GPS就绪，可以开始跑步了！';
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
          // Google地图
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _defaultLocation,
              zoom: 18,
              tilt: 45, // 添加3D倾斜效果
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
            mapType: MapType.normal, // 可以改为 MapType.satellite 查看卫星图
            buildingsEnabled: true, // 启用3D建筑
            trafficEnabled: true, // 启用实时路况
          ),

          // 顶部状态栏
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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
                          Text(
                            '📱 模拟跑步中，观察地图上的实时移动',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // 切换地图类型
                      setState(() {
                        // 这里可以添加地图类型切换逻辑
                      });
                    },
                    icon: const Icon(Icons.layers, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // 跑步数据卡片
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPaused ? Icons.pause_circle : Icons.play_circle,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '配速: ${_formatPace(_averageSpeed)} /公里',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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

          // 底部控制按钮
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isRunning) ...[
                    // 开始按钮
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startRunning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, size: 20),
                            SizedBox(width: 8),
                            Text('开始模拟跑步', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // 暂停/继续按钮
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pauseRunning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPaused ? AppColors.success : AppColors.warning,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 20),
                            const SizedBox(width: 8),
                            Text(_isPaused ? '继续' : '暂停', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 停止按钮
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _stopRunning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.stop, size: 20),
                            SizedBox(width: 8),
                            Text('结束', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 路线点数指示器
          if (_routePoints.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 220,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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
            ),
        ],
      ),
    );
  }
}
