#!/bin/bash

# 🚀 Rocky Linux VPS自动化部署脚本
# 使用方法: ./scripts/deploy-vps-rocky.sh <服务器IP> <域名>

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
    echo -e "${YELLOW}例如: $0 104.225.147.57 myrunning.app${NC}"
    exit 1
fi

SERVER_IP=$1
DOMAIN=$2
USER="deploy"

echo -e "${BLUE}🚀 开始部署到Rocky Linux VPS服务器...${NC}"
echo -e "${YELLOW}服务器IP: $SERVER_IP${NC}"
echo -e "${YELLOW}域名: $DOMAIN${NC}"

# 1. 构建Flutter应用
echo -e "${BLUE}📦 构建Flutter Web应用...${NC}"
flutter build web --release --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=http://$DOMAIN/api

# 2. 创建后端环境配置
echo -e "${BLUE}⚙️  创建后端环境配置...${NC}"
cat > backend/.env << EOF
DATABASE_URL="file:./prod.db"
JWT_SECRET="$(openssl rand -base64 32)"
PORT=3000
NODE_ENV=production
FRONTEND_URL=http://$DOMAIN
EOF

echo -e "${GREEN}✅ 后端环境配置已创建${NC}"

# 3. 打包后端和前端
echo -e "${BLUE}📦 打包应用文件...${NC}"
tar -czf backend.tar.gz backend/
tar -czf frontend.tar.gz build/web/

# 4. 上传文件到服务器
echo -e "${BLUE}📤 上传文件到服务器...${NC}"
scp backend.tar.gz $USER@$SERVER_IP:~/
scp frontend.tar.gz $USER@$SERVER_IP:~/
scp scripts/server-setup-rocky.sh $USER@$SERVER_IP:~/

# 5. 在服务器上执行部署
echo -e "${BLUE}🔧 在服务器上执行部署...${NC}"
ssh $USER@$SERVER_IP << EOF
chmod +x ~/server-setup-rocky.sh
~/server-setup-rocky.sh $DOMAIN
EOF

# 6. 清理本地临时文件
echo -e "${BLUE}🧹 清理临时文件...${NC}"
rm -f backend.tar.gz frontend.tar.gz

# 7. 等待服务启动并测试
echo -e "${BLUE}⏳ 等待服务启动...${NC}"
sleep 10

# 8. 测试部署结果
echo -e "${BLUE}🔍 测试部署结果...${NC}"

# 测试API健康检查
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN/api/health 2>/dev/null || echo "000")
if [ "$API_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ API服务正常运行${NC}"
else
    echo -e "${YELLOW}⚠️  API状态码: $API_STATUS${NC}"
    echo -e "${YELLOW}💡 可能需要等待更长时间或检查配置${NC}"
fi

# 测试前端访问
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN 2>/dev/null || echo "000")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ 前端服务正常运行${NC}"
else
    echo -e "${YELLOW}⚠️  前端状态码: $FRONTEND_STATUS${NC}"
fi

echo -e "${GREEN}✅ Rocky Linux部署完成！${NC}"
echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}🌐 访问地址:${NC}"
echo -e "前端: ${BLUE}http://$DOMAIN${NC}"
echo -e "API: ${BLUE}http://$DOMAIN/api${NC}"
echo -e "健康检查: ${BLUE}http://$DOMAIN/api/health${NC}"

echo -e "${YELLOW}🔧 管理命令:${NC}"
echo -e "查看服务状态: ${BLUE}ssh $USER@$SERVER_IP 'pm2 status'${NC}"
echo -e "查看API日志: ${BLUE}ssh $USER@$SERVER_IP 'pm2 logs running-tracker-api'${NC}"
echo -e "重启API服务: ${BLUE}ssh $USER@$SERVER_IP 'pm2 restart running-tracker-api'${NC}"
echo -e "查看Nginx状态: ${BLUE}ssh $USER@$SERVER_IP 'sudo systemctl status nginx'${NC}"

echo -e "${PURPLE}🎯 下一步建议:${NC}"
echo -e "1. 🌍 配置域名DNS: 将 $DOMAIN 解析到 $SERVER_IP"
echo -e "2. 🔐 配置SSL证书: 运行 ssh $USER@$SERVER_IP 'sudo certbot --nginx -d $DOMAIN'"
echo -e "3. 📱 测试移动应用: 更新Flutter应用中的API地址"
echo -e "4. 🔍 监控服务: 定期检查 pm2 status 和系统日志"

# 显示服务器状态
echo -e "${BLUE}📊 当前服务器状态:${NC}"
ssh $USER@$SERVER_IP 'echo "系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"'"'"' -f2)"'
ssh $USER@$SERVER_IP 'echo "负载: $(uptime | cut -d'"'"'load average:'"'"' -f2)"'
ssh $USER@$SERVER_IP 'echo "内存: $(free -h | grep Mem | awk '"'"'{print $3"/"$2}'"'"')"'
ssh $USER@$SERVER_IP 'echo "磁盘: $(df -h / | tail -1 | awk '"'"'{print $3"/"$2" ("$5")"}'"'"')"' 