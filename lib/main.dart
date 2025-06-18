import 'package:flutter/material.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'core/constants/app_config.dart';

void main() {
  // 打印应用配置信息
  AppConfig.printConfig();

  runApp(const RunningTrackerApp());
}

/// 🏃‍♂️ 跑步追踪应用
class RunningTrackerApp extends StatelessWidget {
  const RunningTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🏃‍♂️ 跑步追踪器',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
