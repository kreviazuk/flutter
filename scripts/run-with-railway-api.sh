#!/bin/bash

echo "🚂 启动 Flutter 应用 - 使用 Railway API"
echo "==========================================="
echo "API 地址: https://flutter-production-80de.up.railway.app/api/auth"
echo "环境: development"
echo "平台: Chrome Web"
echo "端口: 8080"
echo ""

# 使用 dart-define 参数启动 Flutter 应用
flutter run -d chrome --web-port 8080 \
  --dart-define=API_BASE_URL=https://flutter-production-80de.up.railway.app/api/auth \
  --dart-define=ENV=development \
  --dart-define=USE_RAILWAY_API=true

echo ""
echo "🔧 调试信息:"
echo "- 检查浏览器控制台中的网络请求"
echo "- 查看 API 配置打印信息"
echo "- 测试注册/登录功能" 