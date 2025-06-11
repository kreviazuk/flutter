import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;
import '../theme/app_colors.dart';

/// 📍 纯GPS位置显示页面 - 无地图组件，解决缓冲区问题
class LocationDisplayScreenPure extends StatefulWidget {
  const LocationDisplayScreenPure({super.key});

  @override
  State<LocationDisplayScreenPure> createState() => _LocationDisplayScreenPureState();
}

class _LocationDisplayScreenPureState extends State<LocationDisplayScreenPure>
    with TickerProviderStateMixin {
  Position? _currentPosition;
  bool _isLocationLoaded = false;
  String _locationStatus = '正在获取位置...';
  Timer? _locationTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // 位置历史记录
  final List<Position> _locationHistory = [];
  double _totalDistance = 0.0;
  double _averageSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocation();
    _startLocationUpdates();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  /// 初始化位置服务
  Future<void> _initializeLocation() async {
    try {
      // 检查权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        // 检查定位服务是否开启
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            _locationStatus = 'GPS服务未开启';
          });
          return;
        }

        await _getCurrentLocation();
      } else {
        setState(() {
          _locationStatus = '定位权限被拒绝';
        });
      }
    } catch (e) {
      setState(() {
        _locationStatus = '位置初始化失败: $e';
      });
      debugPrint('位置初始化失败: $e');
    }
  }

  /// 开始位置更新
  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _getCurrentLocation();
      }
    });
  }

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      if (!_isLocationLoaded) {
        setState(() {
          _locationStatus = '正在定位...';
        });
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // 计算距离和速度
      if (_locationHistory.isNotEmpty) {
        double distance = Geolocator.distanceBetween(
          _locationHistory.last.latitude,
          _locationHistory.last.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance;

        // 计算平均速度（基于最近10个位置点）
        if (_locationHistory.length > 1) {
          final recentPositions = _locationHistory.length > 10
              ? _locationHistory.sublist(_locationHistory.length - 10)
              : _locationHistory;

          double totalDist = 0;
          for (int i = 1; i < recentPositions.length; i++) {
            totalDist += Geolocator.distanceBetween(
              recentPositions[i - 1].latitude,
              recentPositions[i - 1].longitude,
              recentPositions[i].latitude,
              recentPositions[i].longitude,
            );
          }

          final timeDiff = recentPositions.last.timestamp!
              .difference(recentPositions.first.timestamp!)
              .inSeconds;

          if (timeDiff > 0) {
            _averageSpeed = (totalDist / timeDiff) * 3.6; // 转换为 km/h
          }
        }
      }

      setState(() {
        _currentPosition = position;
        _isLocationLoaded = true;
        _locationStatus = '定位成功';
        _locationHistory.add(position);

        // 保持最近50个位置记录
        if (_locationHistory.length > 50) {
          _locationHistory.removeAt(0);
        }
      });
    } catch (e) {
      setState(() {
        _locationStatus = '获取位置失败: $e';
      });
      debugPrint('获取位置失败: $e');
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 GPS定位'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新位置',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // GPS状态指示器
              _buildGPSIndicator(),

              const SizedBox(height: 24),

              // 位置信息卡片
              if (_isLocationLoaded && _currentPosition != null) ...[
                _buildLocationCard(),
                const SizedBox(height: 16),
                _buildDetailsGrid(),
                const SizedBox(height: 16),
                _buildStatisticsCard(),
              ],

              const SizedBox(height: 24),

              // 位置历史
              if (_locationHistory.isNotEmpty) _buildLocationHistory(),
            ],
          ),
        ),
      ),
    );
  }

  /// GPS状态指示器
  Widget _buildGPSIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLocationLoaded ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (_isLocationLoaded ? AppColors.success : AppColors.warning).withOpacity(0.3),
                  (_isLocationLoaded ? AppColors.success : AppColors.warning).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: _isLocationLoaded ? AppColors.success : AppColors.warning,
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLocationLoaded ? Icons.gps_fixed : Icons.gps_not_fixed,
                    size: 40,
                    color: _isLocationLoaded ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _locationStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isLocationLoaded ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 位置信息主卡片
  Widget _buildLocationCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '当前位置',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildCoordinateRow(
                    '纬度',
                    _currentPosition!.latitude.toStringAsFixed(6),
                    Icons.explore,
                  ),
                  const SizedBox(height: 8),
                  _buildCoordinateRow(
                    '经度',
                    _currentPosition!.longitude.toStringAsFixed(6),
                    Icons.explore_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 坐标信息行
  Widget _buildCoordinateRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 详细信息网格
  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildDetailCard(
          '海拔高度',
          '${_currentPosition!.altitude.toStringAsFixed(1)} m',
          Icons.terrain,
          AppColors.success,
        ),
        _buildDetailCard(
          '定位精度',
          '${_currentPosition!.accuracy.toStringAsFixed(1)} m',
          Icons.my_location,
          AppColors.warning,
        ),
        _buildDetailCard(
          '速度',
          '${(_currentPosition!.speed * 3.6).toStringAsFixed(1)} km/h',
          Icons.speed,
          AppColors.error,
        ),
        _buildDetailCard(
          '方向',
          '${_currentPosition!.heading.toStringAsFixed(0)}°',
          Icons.navigation,
          AppColors.info,
        ),
      ],
    );
  }

  /// 详细信息卡片
  Widget _buildDetailCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 统计信息卡片
  Widget _buildStatisticsCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '统计信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatRow('总距离', '${(_totalDistance / 1000).toStringAsFixed(2)} km'),
            _buildStatRow('平均速度', '${_averageSpeed.toStringAsFixed(1)} km/h'),
            _buildStatRow('位置点数', '${_locationHistory.length}'),
            _buildStatRow(
                '最后更新', '${_currentPosition!.timestamp?.toString().substring(11, 19) ?? '未知'}'),
          ],
        ),
      ),
    );
  }

  /// 统计信息行
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 位置历史
  Widget _buildLocationHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 位置历史 (最近${math.min(_locationHistory.length, 5)}个)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...(_locationHistory.reversed.take(5).map((position) {
              final time = position.timestamp?.toString().substring(11, 19) ?? '未知';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$time - ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })),
          ],
        ),
      ),
    );
  }
}
