import 'package:flutter/material.dart';

/// 🎨 应用颜色主题配置
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();

  // ========== 🏃‍♂️ 主题色彩 ==========
  /// 主色调 - 运动蓝
  static const Color primary = Color(0xFF2196F3);

  /// 主色调变体
  static const Color primaryVariant = Color(0xFF1976D2);

  /// 次要色 - 成功绿
  static const Color secondary = Color(0xFF4CAF50);

  /// 次要色变体
  static const Color secondaryVariant = Color(0xFF388E3C);

  // ========== 🚨 状态颜色 ==========
  /// 成功状态
  static const Color success = Color(0xFF4CAF50);

  /// 警告状态
  static const Color warning = Color(0xFFFF9800);

  /// 错误状态
  static const Color error = Color(0xFFF44336);

  /// 信息状态
  static const Color info = Color(0xFF2196F3);

  // ========== 🖼️ 背景颜色 ==========
  /// 主背景色
  static const Color background = Color(0xFFF5F5F5);

  /// 卡片背景色
  static const Color surface = Color(0xFFFFFFFF);

  /// 深色背景
  static const Color surfaceDark = Color(0xFF121212);

  // ========== 📝 文字颜色 ==========
  /// 主要文字
  static const Color textPrimary = Color(0xFF212121);

  /// 次要文字
  static const Color textSecondary = Color(0xFF757575);

  /// 禁用状态文字
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// 白色文字
  static const Color textWhite = Color(0xFFFFFFFF);

  // ========== 🎯 跑步专用颜色 ==========
  /// 跑步进行中
  static const Color running = Color(0xFF4CAF50);

  /// 跑步暂停
  static const Color paused = Color(0xFFFF9800);

  /// 跑步停止
  static const Color stopped = Color(0xFFF44336);

  /// 路径线条颜色
  static const Color routePath = Color(0xFF2196F3);

  /// 距离指示器
  static const Color distance = Color(0xFF9C27B0);

  /// 速度指示器
  static const Color speed = Color(0xFF00BCD4);

  /// 时间指示器
  static const Color time = Color(0xFFFF5722);

  // ========== 🌈 渐变色 ==========
  /// 主要渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryVariant],
  );

  /// 跑步状态渐变
  static const LinearGradient runningGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [running, success],
  );

  /// 背景渐变
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
  );
}
