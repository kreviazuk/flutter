#!/bin/bash

# 生产环境构建脚本
echo "🏗️ 构建生产版本..."

# 清理之前的构建
echo "🧹 清理构建缓存..."
flutter clean
flutter pub get

# 构建APK
echo "📦 构建APK..."
flutter build apk --release --dart-define=ENV=production

# 构建Web版本
echo "🌐 构建Web版本..."
flutter build web --release --dart-define=ENV=production

echo "✅ 构建完成！"
echo "APK位置: build/app/outputs/flutter-apk/app-release.apk"
echo "Web位置: build/web/" 