#!/bin/bash

echo "🚀 测试环境快速部署脚本"
echo "==============================="

# 检查是否有测试API URL
if [ -z "$TEST_API_URL" ]; then
    echo "⚠️  未设置 TEST_API_URL 环境变量"
    echo "💡 示例: export TEST_API_URL=https://your-app.up.railway.app/api/auth"
    echo ""
    echo "📖 如果还没有部署后端，请参考 DEPLOYMENT_GUIDE.md"
    echo "   推荐使用 Railway.app 免费部署：https://railway.app"
    exit 1
fi

echo "🔗 使用测试API: $TEST_API_URL"
echo ""

# 构建不同版本的应用
echo "📱 构建测试版本应用..."

# Android APK
echo "🤖 构建 Android APK (测试环境)..."
flutter build apk --release \
    --dart-define=ENV=test \
    --dart-define=API_BASE_URL=$TEST_API_URL \
    --flavor=test || true

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ Android APK 构建成功!"
    
    # 重命名为测试版本
    cp build/app/outputs/flutter-apk/app-release.apk build/running-tracker-test.apk
    echo "📦 测试APK: build/running-tracker-test.apk"
else
    echo "❌ Android APK 构建失败"
fi

# 构建 Web 版本
echo "🌐 构建 Web 版本 (测试环境)..."
flutter build web --release \
    --dart-define=ENV=test \
    --dart-define=API_BASE_URL=$TEST_API_URL

if [ -d "build/web" ]; then
    echo "✅ Web 版本构建成功!"
    echo "📁 Web 文件: build/web/"
    echo ""
    echo "💡 部署到静态托管服务:"
    echo "   - Vercel: 拖拽 build/web 文件夹"
    echo "   - Netlify: 拖拽 build/web 文件夹"
    echo "   - GitHub Pages: 提交到 gh-pages 分支"
else
    echo "❌ Web 版本构建失败"
fi

echo ""
echo "==============================="
echo "🎉 构建完成!"
echo ""
echo "📦 生成的文件:"
echo "  📱 Android APK: build/running-tracker-test.apk"
echo "  🌐 Web 文件夹: build/web/"
echo ""
echo "🔗 API 配置: $TEST_API_URL"
echo ""
echo "💡 下一步:"
echo "  1. 安装 APK 到 Android 设备测试"
echo "  2. 部署 Web 版本到静态托管服务"
echo "  3. 测试所有功能是否正常工作" 