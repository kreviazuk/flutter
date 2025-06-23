#!/bin/bash

# 🔧 Rocky Linux 服务器端设置脚本
# 在Rocky Linux VPS服务器上运行

set -e

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
    echo "❌ 请提供域名参数"
    exit 1
fi

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 开始Rocky Linux服务器设置...${NC}"

# 1. 解压后端文件
echo -e "${BLUE}📦 解压后端文件...${NC}"
if [ -f ~/backend.tar.gz ]; then
    rm -rf ~/backend
    tar -xzf ~/backend.tar.gz
    cd ~/backend
    
    # 安装依赖
    echo -e "${BLUE}📦 安装后端依赖...${NC}"
    pnpm install --production
    
    # 检查环境变量文件
    if [ ! -f .env ]; then
        echo -e "${YELLOW}⚠️  创建.env文件模板...${NC}"
        cat > .env << EOF
DATABASE_URL="file:./prod.db"
JWT_SECRET="$(openssl rand -base64 32)"
PORT=3000
NODE_ENV=production
FRONTEND_URL=https://$DOMAIN
EOF
        echo -e "${GREEN}✅ .env文件已创建${NC}"
    fi
    
    # 初始化数据库
    echo -e "${BLUE}🗄️  初始化数据库...${NC}"
    npx prisma generate
    npx prisma db push
    
    cd ~
fi

# 2. 解压前端文件（Rocky Linux使用nginx用户）
echo -e "${BLUE}📦 解压前端文件...${NC}"
if [ -f ~/frontend.tar.gz ]; then
    # 在Rocky Linux中，默认web目录通常是/usr/share/nginx/html
    # 但我们创建自定义目录
    sudo mkdir -p /var/www/$DOMAIN
    sudo tar -xzf ~/frontend.tar.gz -C /var/www/$DOMAIN --strip-components=1
    # Rocky Linux使用nginx:nginx而不是www-data:www-data
    sudo chown -R nginx:nginx /var/www/$DOMAIN
    sudo chmod -R 755 /var/www/$DOMAIN
fi

# 3. 创建PM2配置
echo -e "${BLUE}⚙️  配置PM2...${NC}"
cat > ~/ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'running-tracker-api',
    script: 'server.js',
    cwd: '/home/deploy/backend',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/home/deploy/logs/api-error.log',
    out_file: '/home/deploy/logs/api-out.log',
    log_file: '/home/deploy/logs/api-combined.log',
    time: true
  }]
}
EOF

# 创建日志目录
mkdir -p ~/logs

# 4. 配置Nginx（Rocky Linux配置目录结构）
echo -e "${BLUE}🌐 配置Nginx...${NC}"

# Rocky Linux的Nginx配置在/etc/nginx/conf.d/目录
sudo tee /etc/nginx/conf.d/$DOMAIN.conf > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # API代理
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Flutter Web应用
    location / {
        root /var/www/$DOMAIN;
        index index.html;
        try_files \$uri \$uri/ /index.html;
        
        # 缓存静态资源
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # 健康检查
    location /health {
        proxy_pass http://127.0.0.1:3000/health;
    }

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

# 备份并修改主配置文件
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# 确保包含conf.d目录
if ! sudo grep -q "include /etc/nginx/conf.d/\*.conf;" /etc/nginx/nginx.conf; then
    sudo sed -i '/http {/a\    include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf
fi

# 测试Nginx配置
echo -e "${BLUE}🔍 测试Nginx配置...${NC}"
sudo nginx -t

# 5. 配置SELinux（Rocky Linux特有）
echo -e "${BLUE}🔒 配置SELinux...${NC}"
# 允许Nginx连接到网络
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_can_network_relay 1

# 设置web目录的SELinux上下文
sudo setsebool -P httpd_read_user_content 1
sudo semanage fcontext -a -t httpd_exec_t "/var/www/$DOMAIN(/.*)?" 2>/dev/null || true
sudo restorecon -R /var/www/$DOMAIN

# 6. 启动服务
echo -e "${BLUE}🚀 启动服务...${NC}"

# 停止旧的PM2进程
pm2 delete running-tracker-api 2>/dev/null || true

# 启动新的PM2进程
pm2 start ~/ecosystem.config.js
pm2 save

# 重启Nginx
sudo systemctl restart nginx

# 7. 配置防火墙（Rocky Linux使用firewalld）
echo -e "${BLUE}🔒 配置防火墙...${NC}"
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload

# 8. 尝试安装certbot并申请SSL证书
echo -e "${BLUE}🔐 配置SSL证书...${NC}"
if command -v certbot &> /dev/null; then
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN || {
        echo -e "${YELLOW}⚠️  SSL证书申请失败，请手动配置${NC}"
    }
else
    echo -e "${YELLOW}⚠️  certbot未安装，跳过SSL配置${NC}"
    echo -e "${YELLOW}💡 您可以稍后手动安装SSL证书${NC}"
fi

# 9. 显示状态
echo -e "${GREEN}✅ Rocky Linux服务器设置完成！${NC}"
echo -e "${BLUE}📊 服务状态:${NC}"
echo -e "Nginx: $(sudo systemctl is-active nginx)"
echo -e "Firewalld: $(sudo systemctl is-active firewalld)"
echo -e "PM2: $(pm2 list | grep running-tracker-api | wc -l) 个进程运行中"

# 10. 显示访问信息
echo -e "${GREEN}🌐 访问测试:${NC}"
echo -e "前端: http://$DOMAIN"
echo -e "API: http://$DOMAIN/api/health"

# 11. 测试API连接
echo -e "${BLUE}🔍 测试API连接...${NC}"
sleep 5
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health 2>/dev/null || echo "000")
if [ "$API_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ API服务正常运行${NC}"
else
    echo -e "${YELLOW}⚠️  API状态: $API_STATUS (可能需要等待启动)${NC}"
fi

# 12. 清理临时文件
rm -f ~/backend.tar.gz ~/frontend.tar.gz ~/server-setup-rocky.sh

echo -e "${YELLOW}💡 下一步:${NC}"
echo -e "1. 检查 ~/backend/.env 环境变量配置"
echo -e "2. 测试API: curl http://$DOMAIN/api/health"
echo -e "3. 访问前端: http://$DOMAIN"
echo -e "4. 配置域名DNS指向此服务器IP: $(hostname -I | awk '{print $1}')"

echo -e "${GREEN}🎉 部署完成！您的跑步应用已在线运行！${NC}" 