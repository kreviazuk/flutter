#!/bin/bash

echo "🍎 开始构建 iOS 应用..."
echo "=================================="

# 检查是否在macOS上运行
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ iOS构建需要在macOS系统上运行"
    exit 1
fi

# 检查Xcode是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 未找到Xcode，请先安装Xcode"
    exit 1
fi

# 清理之前的构建
echo "📁 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 检查构建环境
echo "🔍 检查构建环境..."
flutter doctor

# 构建 iOS (调试版本)
echo "🏗️  构建调试版本..."
flutter build ios --debug --no-codesign
if [ $? -eq 0 ]; then
    echo "✅ iOS调试版本构建成功!"
else
    echo "❌ iOS调试版本构建失败!"
    exit 1
fi

# 构建 iOS (发布版本)
echo "🏗️  构建发布版本..."
flutter build ios --release --no-codesign
if [ $? -eq 0 ]; then
    echo "✅ iOS发布版本构建成功!"
else
    echo "❌ iOS发布版本构建失败!"
    exit 1
fi

echo "=================================="
echo "🎉 iOS 构建完成!"
echo ""
echo "📱 下一步操作:"
echo "  1. 打开 Xcode 项目:"
echo "     open ios/Runner.xcworkspace"
echo ""
echo "  2. 在 Xcode 中进行以下操作:"
echo "     - 选择开发团队 (Team)"
echo "     - 配置Bundle Identifier"
echo "     - 选择目标设备或模拟器"
echo "     - 点击 Product > Archive 进行归档"
echo ""
echo "  3. App Store 发布:"
echo "     - 使用 Organizer 上传到 App Store Connect"
echo "     - 或导出 IPA 文件进行Ad-hoc分发"
echo ""
echo "💡 提示:"
echo "  - 发布到App Store需要Apple Developer账号"
echo "  - 内测可使用TestFlight或Ad-hoc分发" 