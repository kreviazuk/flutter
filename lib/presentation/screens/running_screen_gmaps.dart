import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../theme/app_colors.dart';

/// 🏃‍♂️ 跑步追踪页面 - 使用 Google Maps
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
  bool _isLocationLoaded = false; // 新增：位置是否已加载

  // 地图和路线数据
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];

  // 跑步状态
  bool _isRunning = false;
  bool _isPaused = false;
  String _statusMessage = '正在获取位置...';

  // 跑步数据
  double _totalDistance = 0.0; // 总距离（米）
  int _elapsedTime = 0; // 经过时间（秒）
  double _currentSpeed = 0.0; // 当前速度（m/s）
  double _averageSpeed = 0.0; // 平均速度（m/s）
  int _calories = 0; // 消耗卡路里
  Timer? _timer;

  // 地图初始位置
  static const LatLng _defaultLocation = LatLng(39.909187, 116.397451);

  @override
  void initState() {
    super.initState();

    // 如果已经有位置信息，直接使用
    if (widget.initialPosition != null) {
      setState(() {
        _currentPosition = widget.initialPosition;
        _isLocationLoaded = true;
        _statusMessage = 'GPS就绪，可以开始跑步了！';
      });
      // 等待一小段时间确保UI构建完成，然后添加标记
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null) {
          _updateMapLocation();
        }
      });
    } else {
      // 否则重新获取位置
      _initializeLocation();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  /// 初始化位置服务
  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _statusMessage = '正在检查位置权限...';
      });

      // 检查并请求位置权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _statusMessage = '正在申请位置权限...';
        });
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _statusMessage = '位置权限被永久拒绝，请在设置中开启';
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _statusMessage = '需要位置权限才能追踪跑步路线';
        });
        return;
      }

      // 检查GPS服务
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _statusMessage = 'GPS服务未开启，请在设置中开启';
        });
        return;
      }

      setState(() {
        _statusMessage = '正在获取当前位置...';
      });

      // 获取初始位置
      await _getCurrentLocation();
    } catch (e) {
      setState(() {
        _statusMessage = '初始化失败: ${e.toString()}';
      });
    }
  }

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoaded = true; // 位置已加载
        _statusMessage = 'GPS就绪，可以开始跑步了！';
      });

      // 等待一小段时间确保地图已创建，然后更新位置
      if (_mapController != null) {
        await _updateMapLocation();
      }
    } catch (e) {
      setState(() {
        _statusMessage = '获取位置失败: ${e.toString()}';
      });
    }
  }

  /// 更新地图位置
  Future<void> _updateMapLocation() async {
    if (_currentPosition == null || _mapController == null) return;

    final LatLng currentLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // 移动地图中心
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(currentLatLng, 18),
    );

    // 更新当前位置标记
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: '当前位置',
            snippet: '你在这里',
          ),
        ),
      );
    });
  }

  /// 开始跑步
  void _startRunning() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _statusMessage = '跑步中...';
    });

    // 开始位置追踪
    _startLocationTracking();

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

  /// 暂停跑步
  void _pauseRunning() {
    setState(() {
      _isPaused = !_isPaused;
      _statusMessage = _isPaused ? '已暂停' : '跑步中...';
    });
  }

  /// 停止跑步
  void _stopRunning() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _statusMessage = '跑步结束';
    });

    _positionSubscription?.cancel();
    _timer?.cancel();

    _showRunSummary();
  }

  /// 开始位置追踪
  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // 每5米更新一次
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_isRunning && !_isPaused) {
        _updateRunningPosition(position);
      }
    });
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

      // 过滤掉过短的距离（可能是GPS误差）
      if (distance > 2) {
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
      }
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
          width: 5,
          patterns: [],
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
            Text('消耗卡路里: $_calories 千卡'),
            Text('路线点数: ${_routePoints.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 返回主页
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
      _routePoints.clear();
      _polylines.clear();
      _statusMessage = 'GPS就绪，可以开始跑步了！';
    });
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
          // 根据位置加载状态显示不同内容
          if (_isLocationLoaded && _currentPosition != null) ...[
            // Google地图 - 只有在获取到位置后才显示
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 18,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                // 地图创建后立即更新位置（如果有位置信息）
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
            ),
          ] else ...[
            // 加载界面
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.secondary.withOpacity(0.6),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 加载动画
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 加载文本
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // 提示文本
                    Text(
                      '📍 正在为您定位最佳起跑点',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 顶部状态栏
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_isLocationLoaded)
                    IconButton(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),

          // 跑步数据卡片 - 只有在位置加载后才显示
          if (_isLocationLoaded) ...[
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('距离', '${(_totalDistance / 1000).toStringAsFixed(2)} km'),
                    _buildStatItem('时间', _formatTime(_elapsedTime)),
                    _buildStatItem('速度', '${_formatSpeed(_currentSpeed)} km/h'),
                    _buildStatItem('卡路里', '$_calories'),
                  ],
                ),
              ),
            ),

            // 底部控制按钮
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isRunning) ...[
                    // 开始按钮
                    ElevatedButton(
                      onPressed: _currentPosition != null ? _startRunning : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow),
                          SizedBox(width: 8),
                          Text('开始跑步'),
                        ],
                      ),
                    ),
                  ] else ...[
                    // 暂停/继续按钮
                    ElevatedButton(
                      onPressed: _pauseRunning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaused ? AppColors.success : AppColors.warning,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                          const SizedBox(width: 8),
                          Text(_isPaused ? '继续' : '暂停'),
                        ],
                      ),
                    ),

                    // 停止按钮
                    ElevatedButton(
                      onPressed: _stopRunning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stop),
                          SizedBox(width: 8),
                          Text('结束'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
