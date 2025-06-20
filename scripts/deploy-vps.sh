#!/bin/bash

# 🚀 VPS自动化部署脚本
# 使用方法: ./scripts/deploy-vps.sh your_server_ip your_domain

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 参数检查
if [ $# -lt 2 ]; then
    echo -e "${RED}❌ 使用方法: $0 <服务器IP> <域名>${NC}"
    echo -e "${YELLOW}例如: $0 192.168.1.100 myapp.com${NC}"
    exit 1
fi

SERVER_IP=$1
DOMAIN=$2
USER="deploy"

echo -e "${BLUE}🚀 开始部署到VPS服务器...${NC}"
echo -e "${YELLOW}服务器IP: $SERVER_IP${NC}"
echo -e "${YELLOW}域名: $DOMAIN${NC}"

# 1. 构建Flutter应用
echo -e "${BLUE}📦 构建Flutter Web应用...${NC}"
flutter build web --release --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://$DOMAIN/api/auth

# 2. 打包后端和前端
echo -e "${BLUE}📦 打包应用文件...${NC}"
tar -czf backend.tar.gz backend/
tar -czf frontend.tar.gz build/web/

# 3. 上传文件到服务器
echo -e "${BLUE}📤 上传文件到服务器...${NC}"
scp backend.tar.gz $USER@$SERVER_IP:~/
scp frontend.tar.gz $USER@$SERVER_IP:~/
scp scripts/server-setup.sh $USER@$SERVER_IP:~/

# 4. 在服务器上执行部署
echo -e "${BLUE}🔧 在服务器上执行部署...${NC}"
ssh $USER@$SERVER_IP << EOF
chmod +x ~/server-setup.sh
~/server-setup.sh $DOMAIN
EOF

# 5. 清理本地临时文件
echo -e "${BLUE}🧹 清理临时文件...${NC}"
rm -f backend.tar.gz frontend.tar.gz

echo -e "${GREEN}✅ 部署完成！${NC}"
echo -e "${GREEN}🌐 访问地址: https://$DOMAIN${NC}"
echo -e "${GREEN}📱 API地址: https://$DOMAIN/api${NC}"
echo -e "${YELLOW}💡 请确保DNS已正确解析到服务器IP${NC}" 