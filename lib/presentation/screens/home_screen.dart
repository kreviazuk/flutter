import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/permission_dialog.dart';
import '../../core/services/permission_service.dart';
import 'countdown_screen.dart';

/// 🏠 主页面 - 简化版本
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPermissions = false;
  bool _isCheckingPermissions = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermissions = await PermissionService.hasAllRequiredPermissions();
    setState(() {
      _hasPermissions = hasPermissions;
      _isCheckingPermissions = false;
    });
  }

  Future<void> _showPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    );

    if (result == true) {
      // 权限授权成功，重新检查权限状态
      await _checkPermissions();
    }
  }

  Future<void> _startRunning() async {
    if (!_hasPermissions) {
      await _showPermissionDialog();
      return;
    }

    // 权限已授权，开始倒计时
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CountdownScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                '正在检查权限状态...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏃‍♂️ 跑步追踪器'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_hasPermissions)
            IconButton(
              onPressed: _showPermissionDialog,
              icon: const Icon(
                Icons.security,
                color: AppColors.warning,
              ),
              tooltip: '权限设置',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 主图标
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasPermissions ? Icons.directions_run : Icons.security,
                  size: 120,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // 主标题
              Text(
                _hasPermissions ? '准备开始你的跑步之旅！' : '需要权限才能开始跑步',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 副标题
              Text(
                _hasPermissions ? '点击下方按钮开始你的健康运动' : '请授权位置权限以使用跑步功能',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // 主要操作按钮
              if (_hasPermissions) ...[
                ElevatedButton(
                  onPressed: _startRunning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, size: 28),
                      SizedBox(width: 12),
                      Text(
                        '开始跑步',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _showPermissionDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.security, size: 28),
                      SizedBox(width: 12),
                      Text(
                        '申请权限',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
