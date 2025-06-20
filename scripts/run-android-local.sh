#!/bin/bash

echo "📱 启动 Flutter 应用 - Android 模拟器 + 本地 API"
echo "=============================================="
echo "API 地址: http://10.0.2.2:3000/api/auth"
echo "环境: development"
echo "平台: Android"
echo ""
echo "💡 注意: Android 模拟器使用 10.0.2.2 访问宿主机的 localhost"
echo ""

# 检查 Android 模拟器是否运行
echo "🔍 检查 Android 模拟器状态..."
adb devices

echo ""
echo "🚀 启动 Flutter 应用..."

# 使用本地 API 启动 Android Flutter 应用
# Android 模拟器中 10.0.2.2 对应宿主机的 localhost
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/auth \
  --dart-define=ENV=development \
  --dart-define=USE_RAILWAY_API=false \
  --hot

echo ""
echo "🔧 调试信息:"
echo "- 确保本地后端服务运行在 localhost:3000"
echo "- Android 模拟器通过 10.0.2.2:3000 访问本地服务"
echo "- 检查 Android 应用日志: flutter logs" 