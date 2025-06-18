#!/bin/bash

# 开发环境启动脚本 (类似于 npm run dev)
echo "🚀 启动开发环境..."

# 启动后端服务
echo "📡 启动后端服务..."
cd backend && pnpm dev &

# 等待后端服务启动
sleep 3

# 启动Flutter应用 (Android模拟器)
echo "📱 启动Flutter应用 (Android)..."
cd ..
flutter run -d android --dart-define=ENV=development

# 如果需要Web版本，使用：
# flutter run -d chrome --web-port 8080 --dart-define=ENV=development 