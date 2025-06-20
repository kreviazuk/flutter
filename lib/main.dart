import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'core/constants/app_config.dart';

void main() {
  // 配置Flutter错误处理，显示详细堆栈信息
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('🚨 =================== Flutter Error ===================');
    print('错误信息: ${details.exception}');
    print('错误位置: ${details.library}');
    print('堆栈追踪:');
    print(details.stack);
    print('====================================================');
  };

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
