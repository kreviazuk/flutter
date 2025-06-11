import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 🏠 主页面 - Phase 1 基础版本
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏃‍♂️ 跑步追踪器'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run,
              size: 100,
              color: AppColors.primary,
            ),
            SizedBox(height: 24),
            Text(
              '准备开始你的跑步之旅！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Phase 1: 基础框架已完成 ✅',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '接下来：Phase 2 添加GPS功能',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 之后这里会启动跑步功能
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚧 跑步功能正在开发中...'),
              backgroundColor: AppColors.info,
            ),
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('开始跑步'),
      ),
    );
  }
}
