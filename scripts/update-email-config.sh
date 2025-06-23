#!/bin/bash

# 🔧 更新服务器邮件配置脚本
# 使用方法: ./scripts/update-email-config.sh <邮箱> <授权码> [邮件服务商]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 参数检查
if [ $# -lt 2 ]; then
    echo -e "${RED}❌ 使用方法: $0 <邮箱> <授权码> [邮件服务商]${NC}"
    echo -e "${YELLOW}例如: $0 your_email@qq.com your_auth_code qq${NC}"
    echo -e "${YELLOW}支持的邮件服务商: qq, 163, gmail${NC}"
    exit 1
fi

EMAIL=$1
AUTH_CODE=$2
PROVIDER=${3:-"qq"}

SERVER_IP="104.225.147.57"
USER="deploy"

echo -e "${BLUE}📧 正在更新邮件服务配置...${NC}"
echo -e "${YELLOW}邮箱: $EMAIL${NC}"
echo -e "${YELLOW}服务商: $PROVIDER${NC}"

# 根据服务商设置SMTP配置
case $PROVIDER in
    "qq")
        SMTP_HOST="smtp.qq.com"
        SMTP_PORT="587"
        SMTP_SECURE="false"
        ;;
    "163")
        SMTP_HOST="smtp.163.com"
        SMTP_PORT="587"
        SMTP_SECURE="false"
        ;;
    "gmail")
        SMTP_HOST="smtp.gmail.com"
        SMTP_PORT="587"
        SMTP_SECURE="false"
        ;;
    *)
        echo -e "${RED}❌ 不支持的邮件服务商: $PROVIDER${NC}"
        exit 1
        ;;
esac

# 创建新的环境变量文件
cat > temp_env_update.txt << EOF
# 数据库配置
DATABASE_URL="file:./prod.db"

# JWT密钥
JWT_SECRET="tHjiwYk8OcZROX4TnNTcN6PbRD3MpMGvP4WKHlR4IYw="

# 服务器配置
PORT=3000
NODE_ENV=production
FRONTEND_URL=http://104.225.147.57

# 邮件服务配置
EMAIL_HOST=$SMTP_HOST
EMAIL_PORT=$SMTP_PORT
EMAIL_SECURE=$SMTP_SECURE
EMAIL_USER=$EMAIL
EMAIL_PASS=$AUTH_CODE
EMAIL_FROM=$EMAIL
EOF

echo -e "${BLUE}📤 上传配置到服务器...${NC}"
scp temp_env_update.txt $USER@$SERVER_IP:~/backend/.env

echo -e "${BLUE}🔄 重启API服务...${NC}"
ssh $USER@$SERVER_IP 'pm2 restart running-tracker-api'

echo -e "${BLUE}🧹 清理临时文件...${NC}"
rm -f temp_env_update.txt

echo -e "${GREEN}✅ 邮件配置更新完成！${NC}"

echo -e "${BLUE}🔍 测试建议:${NC}"
echo -e "1. 查看日志: ${YELLOW}ssh $USER@$SERVER_IP 'pm2 logs running-tracker-api --lines 10'${NC}"
echo -e "2. 测试API: ${YELLOW}curl -X POST http://104.225.147.57/api/auth/send-code -H 'Content-Type: application/json' -d '{\"email\":\"test@example.com\"}'${NC}"

echo -e "${YELLOW}💡 如果仍有问题，请检查:${NC}"
echo -e "- 邮箱授权码是否正确"
echo -e "- 邮箱SMTP服务是否开启"
echo -e "- 服务器网络是否允许SMTP连接" 