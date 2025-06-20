#!/bin/bash

echo "💻 启动 Flutter 应用 - 本地开发环境"
echo "====================================="
echo "API 地址: http://localhost:3000/api/auth"
echo "环境: development"
echo "平台: Chrome Web"
echo "端口: 8080"
echo ""

# 使用本地 API 启动 Flutter 应用
flutter run -d chrome --web-port 8080 \
  --dart-define=API_BASE_URL=http://localhost:3000/api/auth \
  --dart-define=ENV=development \
  --dart-define=USE_RAILWAY_API=false

echo ""
echo "🔧 调试信息:"
echo "- 确保本地后端服务运行在 localhost:3000"
echo "- 检查浏览器控制台中的网络请求"
echo "- 查看 API 配置打印信息" 