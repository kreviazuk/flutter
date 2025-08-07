#!/bin/bash

echo "🔍 iOS配置检查"
echo "=============="

# 检查系统
echo "📱 系统信息:"
echo "OS: $(uname -s)"
echo "版本: $(sw_vers -productVersion)"

# 检查Flutter
echo ""
echo "🎯 Flutter信息:"
if command -v flutter &> /dev/null; then
    flutter --version | head -1
    echo "Flutter Doctor:"
    flutter doctor --android-licenses > /dev/null 2>&1
    flutter doctor | grep -E "(iOS|Xcode)"
else
    echo "❌ Flutter未安装"
fi

# 检查Xcode
echo ""
echo "🛠️  Xcode信息:"
if command -v xcodebuild &> /dev/null; then
    xcodebuild -version 2>/dev/null || echo "❌ 需要完整的Xcode"
else
    echo "❌ Xcode未安装"
fi

# 检查CocoaPods
echo ""
echo "📦 CocoaPods:"
if command -v pod &> /dev/null; then
    echo "✅ CocoaPods $(pod --version)"
else
    echo "❌ CocoaPods未安装"
fi

# 检查iOS模拟器
echo ""
echo "📱 iOS模拟器:"
if command -v xcrun &> /dev/null; then
    simulators=$(xcrun simctl list devices | grep -c "iPhone")
    echo "可用模拟器: $simulators 个"
else
    echo "❌ 无法检查模拟器"
fi

# 检查项目配置
echo ""
echo "📋 项目配置:"
if [ -f "ios/Runner.xcworkspace" ]; then
    echo "✅ Xcode workspace存在"
else
    echo "❌ Xcode workspace不存在"
fi

if [ -f "ios/Podfile" ]; then
    echo "✅ Podfile存在"
else
    echo "❌ Podfile不存在"
fi

# 检查Bundle ID
echo ""
echo "📱 应用配置:"
if [ -f "ios/Runner/Info.plist" ]; then
    bundle_name=$(grep -A1 "CFBundleDisplayName" ios/Runner/Info.plist | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
    echo "应用名称: $bundle_name"
else
    echo "❌ Info.plist不存在"
fi

echo ""
echo "🎯 建议操作:"
echo "1. 如果Xcode未安装，请从App Store安装"
echo "2. 如果CocoaPods未安装，运行: sudo gem install cocoapods"
echo "3. 运行: ./setup_ios_dev.sh 来设置开发环境"
echo "4. 运行: ./build_ios_testflight.sh 来构建测试包"