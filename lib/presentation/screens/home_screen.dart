import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/permission_dialog.dart';
import '../../core/services/permission_service.dart';
import 'countdown_screen.dart';

/// 🏠 主页面 - Phase 2 权限管理版本
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
          builder: (context) => CountdownScreen(
            onCountdownComplete: () {
              // 倒计时完成后的处理
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🏃‍♂️ 跑步开始！GPS追踪功能即将上线...'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasPermissions ? Icons.directions_run : Icons.security,
              size: 100,
              color: _hasPermissions ? AppColors.primary : AppColors.warning,
            ),
            const SizedBox(height: 24),
            Text(
              _hasPermissions ? '准备开始你的跑步之旅！' : '需要权限才能开始跑步',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (_hasPermissions) ...[
              const Text(
                'Phase 2: 权限管理已完成 ✅',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '接下来：Phase 3 添加GPS追踪功能',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(height: 20),
              // 倒计时预览按钮
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CountdownScreen(
                        onCountdownComplete: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 倒计时预览完成！'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.timer, size: 20),
                label: const Text('预览倒计时', style: TextStyle(fontSize: 14)),
              ),
            ] else ...[
              const Text(
                '请授权位置权限以使用跑步功能',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showPermissionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.security),
                label: const Text('申请权限'),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startRunning,
        backgroundColor: _hasPermissions ? AppColors.primary : AppColors.warning,
        icon: Icon(_hasPermissions ? Icons.play_arrow : Icons.security),
        label: Text(_hasPermissions ? '开始跑步' : '需要权限'),
      ),
    );
  }
}
