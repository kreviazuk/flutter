#!/bin/bash

# 🚀 Android测试环境启动脚本
# 连接到VPS测试环境

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 启动Android应用 - VPS测试环境${NC}"
echo -e "${YELLOW}API地址: http://104.225.147.57/api/auth${NC}"

# 检查Flutter环境
echo -e "${BLUE}🔍 检查Flutter环境...${NC}"
flutter doctor --android-licenses > /dev/null 2>&1 || true

# 检查可用的Android设备
echo -e "${BLUE}📱 检查Android设备...${NC}"
DEVICES=$(flutter devices | grep "android")
if [ -z "$DEVICES" ]; then
    echo -e "${RED}❌ 没有找到Android设备或模拟器${NC}"
    echo -e "${YELLOW}请启动Android模拟器或连接Android设备${NC}"
    exit 1
fi

# 获取第一个Android设备ID
DEVICE_ID=$(flutter devices | grep "android" | head -1 | sed 's/.*• \([^ ]*\) •.*/\1/')
echo -e "${GREEN}📱 使用设备: $DEVICE_ID${NC}"

# 清理缓存
echo -e "${BLUE}🧹 清理Flutter缓存...${NC}"
flutter clean
flutter pub get

# 启动Android应用
echo -e "${GREEN}📱 启动Android应用...${NC}"
flutter run -d "$DEVICE_ID" \
  --dart-define=ENV=test \
  --dart-define=API_BASE_URL=http://104.225.147.57/api/auth

echo -e "${GREEN}✅ 应用已启动！${NC}" 