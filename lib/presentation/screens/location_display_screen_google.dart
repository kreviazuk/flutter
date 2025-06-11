import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../theme/app_colors.dart';

/// 📍 位置显示页面 - 使用Google Maps (备用方案)
class LocationDisplayScreenGoogle extends StatefulWidget {
  const LocationDisplayScreenGoogle({super.key});

  @override
  State<LocationDisplayScreenGoogle> createState() => _LocationDisplayScreenGoogleState();
}

class _LocationDisplayScreenGoogleState extends State<LocationDisplayScreenGoogle> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLocationLoaded = false;
  String _locationStatus = '正在获取位置...';

  // 地图初始位置（北京天安门）
  static const LatLng _defaultLocation = LatLng(39.909187, 116.397451);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
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

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _locationStatus = '正在定位...';
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoaded = true;
        _locationStatus = '定位成功';
      });

      // 更新地图位置
      if (_mapController != null) {
        await _updateMapLocation();
      }
    } catch (e) {
      setState(() {
        _locationStatus = '获取位置失败: $e';
      });
      debugPrint('获取位置失败: $e');
    }
  }

  /// 更新地图位置和标记
  Future<void> _updateMapLocation() async {
    if (_currentPosition == null || _mapController == null) return;

    final LatLng currentLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // 移动地图到当前位置
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(currentLatLng, 16),
    );

    // 添加当前位置标记
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLatLng,
          infoWindow: InfoWindow(
            title: '我的位置',
            snippet: '纬度: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
                '经度: ${_currentPosition!.longitude.toStringAsFixed(6)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 我的位置'),
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
      body: Stack(
        children: [
          // Google地图
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _isLocationLoaded && _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _defaultLocation,
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_isLocationLoaded) {
                _updateMapLocation();
              }
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            buildingsEnabled: false,
            trafficEnabled: false,
            indoorViewEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
          ),

          // 顶部状态卡片
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildStatusCard(),
          ),

          // 底部位置信息卡片
          if (_isLocationLoaded && _currentPosition != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildLocationInfoCard(),
            ),

          // 右下角定位按钮
          Positioned(
            bottom: _isLocationLoaded ? 180 : 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isLocationLoaded ? Icons.location_on : Icons.location_searching,
              color: _isLocationLoaded ? AppColors.success : AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '定位状态',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _locationStatus,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isLocationLoaded ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isLocationLoaded)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建位置信息卡片
  Widget _buildLocationInfoCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '位置详情',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('纬度', _currentPosition!.latitude.toStringAsFixed(6)),
            _buildInfoRow('经度', _currentPosition!.longitude.toStringAsFixed(6)),
            _buildInfoRow('海拔', '${_currentPosition!.altitude.toStringAsFixed(1)} m'),
            _buildInfoRow('精度', '${_currentPosition!.accuracy.toStringAsFixed(1)} m'),
            _buildInfoRow(
                '获取时间', '${_currentPosition!.timestamp?.toString().substring(11, 19) ?? '未知'}'),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
}
