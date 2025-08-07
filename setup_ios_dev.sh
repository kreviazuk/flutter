#!/bin/bash

echo "🍎 iOS开发环境设置脚本"
echo "========================"

# 检查是否在macOS上
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 错误: iOS开发需要macOS环境"
    exit 1
fi

echo "✅ 检测到macOS环境"

# 1. 检查并安装Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 安装Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew已安装"
fi

# 2. 安装CocoaPods
if ! command -v pod &> /dev/null; then
    echo "📱 安装CocoaPods..."
    sudo gem install cocoapods
else
    echo "✅ CocoaPods已安装"
fi

# 3. 检查Xcode
if ! xcode-select -p &> /dev/null; then
    echo "⚠️  需要安装Xcode:"
    echo "   1. 从App Store安装Xcode"
    echo "   2. 运行: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "   3. 运行: sudo xcodebuild -license accept"
else
    echo "✅ Xcode已配置"
fi

# 4. 更新iOS项目依赖
echo "📱 更新iOS项目依赖..."
cd ios
pod install --repo-update
cd ..

echo "🎉 iOS开发环境设置完成!"
echo ""
echo "下一步:"
echo "1. 确保有Apple Developer账户"
echo "2. 在Xcode中配置签名"
echo "3. 运行: flutter build ios --release"