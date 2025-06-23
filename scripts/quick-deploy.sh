#!/bin/bash

# 🚀 快速部署脚本 - 交互式VPS部署
# 运行方法: ./scripts/quick-deploy.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🚀 跑步应用VPS快速部署向导${NC}"
echo -e "${BLUE}===========================================${NC}"

# 检查必要文件
if [ ! -f "scripts/deploy-vps.sh" ] || [ ! -f "scripts/server-setup.sh" ]; then
    echo -e "${RED}❌ 缺少必要的部署脚本文件${NC}"
    exit 1
fi

# 1. 获取用户输入
echo -e "${YELLOW}📝 请输入您的VPS信息:${NC}"
read -p "🌐 VPS IP地址: " SERVER_IP
read -p "🌍 域名 (例如: myapp.com): " DOMAIN

# 验证输入
if [ -z "$SERVER_IP" ] || [ -z "$DOMAIN" ]; then
    echo -e "${RED}❌ IP地址和域名不能为空${NC}"
    exit 1
fi

echo -e "${BLUE}📋 您输入的信息:${NC}"
echo -e "IP地址: ${GREEN}$SERVER_IP${NC}"
echo -e "域名: ${GREEN}$DOMAIN${NC}"

read -p "确认信息正确? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⏹️  部署已取消${NC}"
    exit 0
fi

# 2. 检查SSH连接
echo -e "${BLUE}🔐 测试SSH连接...${NC}"
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes root@$SERVER_IP exit 2>/dev/null; then
    echo -e "${YELLOW}⚠️  无法通过密钥连接，请确保已配置SSH密钥或准备输入密码${NC}"
fi

# 3. 创建后端环境配置
echo -e "${BLUE}⚙️  创建后端环境配置...${NC}"
cat > backend/.env << EOF
# 🌍 生产环境配置
DATABASE_URL="file:./prod.db"
JWT_SECRET="$(openssl rand -base64 32)"
PORT=3000
NODE_ENV=production
FRONTEND_URL=https://$DOMAIN
EMAIL_HOST=
EMAIL_PORT=587
EMAIL_USER=
EMAIL_PASS=
EMAIL_FROM=
MAX_FILE_SIZE=10mb
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF

echo -e "${GREEN}✅ 环境配置文件已创建: backend/.env${NC}"

# 4. 显示部署步骤
echo -e "${BLUE}🔧 开始部署流程...${NC}"

echo -e "${YELLOW}步骤 1/3: 初始化服务器${NC}"
echo -e "${BLUE}上传初始化脚本到服务器...${NC}"
scp scripts/init-server.sh root@$SERVER_IP:~/

echo -e "${BLUE}在服务器上运行初始化脚本...${NC}"
ssh root@$SERVER_IP 'chmod +x ~/init-server.sh && ~/init-server.sh'

echo -e "${YELLOW}步骤 2/3: 部署应用${NC}"
echo -e "${BLUE}开始应用部署...${NC}"
./scripts/deploy-vps.sh $SERVER_IP $DOMAIN

echo -e "${YELLOW}步骤 3/3: 验证部署${NC}"
echo -e "${BLUE}等待服务启动...${NC}"
sleep 10

# 检查健康状态
echo -e "${BLUE}检查API健康状态...${NC}"
if curl -f -s "http://$DOMAIN/api/health" > /dev/null 2>&1 || curl -f -s "https://$DOMAIN/api/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API服务正常运行${NC}"
else
    echo -e "${YELLOW}⚠️  API检查失败，请手动验证${NC}"
fi

# 5. 显示结果
echo -e "${GREEN}🎉 部署完成！${NC}"
echo -e "${BLUE}===========================================${NC}"
echo -e "${GREEN}✨ 访问地址:${NC}"
echo -e "🌐 前端: ${BLUE}https://$DOMAIN${NC}"
echo -e "📱 API: ${BLUE}https://$DOMAIN/api${NC}"
echo -e "🔍 健康检查: ${BLUE}https://$DOMAIN/api/health${NC}"

echo -e "${YELLOW}🔧 管理命令:${NC}"
echo -e "查看服务状态: ${BLUE}ssh deploy@$SERVER_IP 'pm2 status'${NC}"
echo -e "查看日志: ${BLUE}ssh deploy@$SERVER_IP 'pm2 logs'${NC}"
echo -e "重启服务: ${BLUE}ssh deploy@$SERVER_IP 'pm2 restart all'${NC}"

echo -e "${PURPLE}🎯 下一步建议:${NC}"
echo -e "1. 测试API接口是否正常工作"
echo -e "2. 在Flutter应用中更新API地址"
echo -e "3. 重新构建并测试移动应用" 