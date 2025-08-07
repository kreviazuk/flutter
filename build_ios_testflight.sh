#!/bin/bash

echo "🚀 iOS TestFlight 测试包构建脚本"
echo "================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查前置条件
check_requirements() {
    echo -e "${BLUE}📋 检查前置条件...${NC}"
    
    # 检查macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}❌ 错误: iOS开发需要macOS环境${NC}"
        exit 1
    fi
    
    # 检查Flutter
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ 错误: 未找到Flutter${NC}"
        exit 1
    fi
    
    # 检查Xcode
    if ! command -v xcodebuild &> /dev/null; then
        echo -e "${YELLOW}⚠️  警告: 需要安装完整的Xcode${NC}"
        echo "请从App Store安装Xcode，然后运行:"
        echo "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
        exit 1
    fi
    
    # 检查CocoaPods
    if ! command -v pod &> /dev/null; then
        echo -e "${YELLOW}📱 安装CocoaPods...${NC}"
        sudo gem install cocoapods
    fi
    
    echo -e "${GREEN}✅ 前置条件检查完成${NC}"
}

# 清理项目
clean_project() {
    echo -e "${BLUE}🧹 清理项目...${NC}"
    flutter clean
    flutter pub get
    
    cd ios
    rm -rf Pods
    rm -f Podfile.lock
    pod install --repo-update
    cd ..
    
    echo -e "${GREEN}✅ 项目清理完成${NC}"
}

# 构建iOS应用
build_ios() {
    echo -e "${BLUE}🔨 构建iOS应用...${NC}"
    
    # 构建iOS release版本
    flutter build ios --release --no-codesign
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ iOS构建成功${NC}"
    else
        echo -e "${RED}❌ iOS构建失败${NC}"
        exit 1
    fi
}

# 打开Xcode进行签名和上传
open_xcode() {
    echo -e "${BLUE}📱 打开Xcode进行签名和Archive...${NC}"
    
    if [ -d "ios/Runner.xcworkspace" ]; then
        open ios/Runner.xcworkspace
        echo -e "${YELLOW}📝 请在Xcode中完成以下步骤:${NC}"
        echo "1. 选择 Runner target"
        echo "2. 在 Signing & Capabilities 中配置签名"
        echo "3. 选择 'Any iOS Device (arm64)'"
        echo "4. Product > Archive"
        echo "5. 在 Organizer 中选择 'Distribute App'"
        echo "6. 选择 'App Store Connect' > 'Upload'"
    else
        echo -e "${RED}❌ 未找到Xcode workspace${NC}"
        exit 1
    fi
}

# 显示后续步骤
show_next_steps() {
    echo -e "${BLUE}📋 后续步骤:${NC}"
    echo "1. 在App Store Connect创建应用"
    echo "2. 配置TestFlight测试信息"
    echo "3. 添加测试用户"
    echo "4. 发送测试邀请"
    echo ""
    echo -e "${YELLOW}📖 详细指南请查看: IOS_TESTFLIGHT_GUIDE.md${NC}"
}

# 主函数
main() {
    echo -e "${GREEN}开始iOS TestFlight构建流程...${NC}"
    
    check_requirements
    clean_project
    build_ios
    open_xcode
    show_next_steps
    
    echo -e "${GREEN}🎉 构建脚本执行完成!${NC}"
}

# 运行主函数
main