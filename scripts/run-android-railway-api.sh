#!/bin/bash

echo "📱 启动 Flutter 应用 - Android 模拟器 + Railway API"
echo "================================================"
echo "API 地址: https://flutter-production-80de.up.railway.app/api/auth"
echo "环境: development"
echo "平台: Android"
echo ""

# 检查 Android 模拟器是否运行
echo "🔍 检查 Android 模拟器状态..."
adb devices

echo ""
echo "🚀 启动 Flutter 应用..."

# 使用 dart-define 参数为 Android 启动 Flutter 应用
flutter run \
  --dart-define=API_BASE_URL=https://flutter-production-80de.up.railway.app/api/auth \
  --dart-define=ENV=development \
  --dart-define=USE_RAILWAY_API=true \
  --hot

echo ""
echo "🔧 调试信息:"
echo "- 检查 Android 应用日志: flutter logs"
echo "- 查看 API 配置打印信息"
echo "- 测试注册/登录功能"
echo "- Railway API 地址会自动使用 HTTPS" 