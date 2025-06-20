#!/bin/bash

echo "🔧 Flutter 应用配置检查"
echo "========================"

echo ""
echo "📋 可用的运行方式："
echo ""

echo "🌐 Web 环境:"
echo "1️⃣ 测试 Railway API (Web):"
echo "   ./scripts/run-with-railway-api.sh"
echo "   API 地址: https://flutter-production-80de.up.railway.app/api/auth"
echo ""

echo "2️⃣ 本地开发环境 (Web):"
echo "   ./scripts/run-local-dev.sh"
echo "   API 地址: http://localhost:3000/api/auth"
echo ""

echo "📱 Android 环境:"
echo "3️⃣ 测试 Railway API (Android) - 推荐:"
echo "   ./scripts/run-android-railway-api.sh"
echo "   API 地址: https://flutter-production-80de.up.railway.app/api/auth"
echo ""

echo "4️⃣ 本地开发环境 (Android):"
echo "   ./scripts/run-android-local.sh"
echo "   API 地址: http://10.0.2.2:3000/api/auth"
echo ""

echo "5️⃣ 手动指定 API 地址:"
echo "   flutter run \\"
echo "     --dart-define=API_BASE_URL=你的API地址 \\"
echo "     --dart-define=ENV=development"
echo ""

echo "🌐 当前 Railway API 状态:"
response=$(curl -s https://flutter-production-80de.up.railway.app/health 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "$response" | head -1
    echo "✅ Railway API 正常"
else
    echo "❌ Railway API 连接失败"
fi

echo ""
echo "📱 Android 模拟器状态:"
adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" || echo "❌ 没有检测到 Android 模拟器"

echo ""
echo "💡 使用建议:"
echo "- Android 测试推荐用方式3 (Railway API)"
echo "- Web 测试推荐用方式1 (Railway API)"
echo "- 在 Android Studio 或命令行启动模拟器"
echo "- 使用 'flutter logs' 查看应用日志"

echo ""
echo "🔗 访问地址:"
echo "- Web: http://localhost:8080"
echo "- Android: 模拟器中直接使用应用" 