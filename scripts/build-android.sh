#!/bin/bash

echo "🔨 开始构建 Android 应用..."
echo "=================================="

# 清理之前的构建
echo "📁 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 检查构建环境
echo "🔍 检查构建环境..."
flutter doctor

# 构建 APK (调试版本)
echo "🏗️  构建调试APK..."
flutter build apk --debug
if [ $? -eq 0 ]; then
    echo "✅ 调试APK构建成功!"
else
    echo "❌ 调试APK构建失败!"
    exit 1
fi

# 构建 APK (发布版本)
echo "🏗️  构建发布APK..."
flutter build apk --release
if [ $? -eq 0 ]; then
    echo "✅ 发布APK构建成功!"
else
    echo "❌ 发布APK构建失败!"
    exit 1
fi

# 构建 App Bundle (推荐)
echo "🏗️  构建App Bundle..."
flutter build appbundle --release
if [ $? -eq 0 ]; then
    echo "✅ App Bundle构建成功!"
else
    echo "⚠️  App Bundle构建失败，但APK构建成功"
    echo "💡 建议: 运行 'flutter doctor --android-licenses' 解决工具链问题"
fi

echo "=================================="
echo "🎉 Android 构建完成!"
echo ""
echo "📦 构建文件位置:"
echo "  📱 调试APK: build/app/outputs/flutter-apk/app-debug.apk"
echo "  📱 发布APK: build/app/outputs/flutter-apk/app-release.apk"
echo "  📦 App Bundle: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "💡 提示:"
echo "  - APK可直接安装到Android设备"
echo "  - App Bundle适用于Google Play发布"
echo "  - 发布前请确保已配置签名" 