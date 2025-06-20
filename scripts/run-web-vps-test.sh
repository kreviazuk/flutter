#!/bin/bash

# 🌐 Web测试环境启动脚本
# 连接到VPS测试环境

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🌐 启动Web应用 - VPS测试环境${NC}"
echo -e "${YELLOW}API地址: http://104.225.147.57/api/auth${NC}"
echo -e "${YELLOW}Web地址: http://localhost:8080${NC}"

# 检查Flutter环境
echo -e "${BLUE}🔍 检查Flutter环境...${NC}"
flutter doctor > /dev/null 2>&1 || true

# 清理缓存
echo -e "${BLUE}🧹 清理Flutter缓存...${NC}"
flutter clean
flutter pub get

# 启动Web应用
echo -e "${GREEN}🌐 启动Web应用...${NC}"
flutter run -d chrome \
  --web-port 8080 \
  --dart-define=ENV=test \
  --dart-define=API_BASE_URL=http://104.225.147.57/api/auth

echo -e "${GREEN}✅ 应用已启动！${NC}" 