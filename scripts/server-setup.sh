#!/bin/bash

# 🔧 服务器端设置脚本
# 在VPS服务器上运行

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

echo -e "${BLUE}🔧 开始服务器设置...${NC}"

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
        cat > .env << 'EOF'
DATABASE_URL="file:./prod.db"
JWT_SECRET="your-super-strong-jwt-secret-please-change-this"
PORT=3000
NODE_ENV=production
EOF
        echo -e "${RED}❗ 请手动编辑 ~/backend/.env 文件配置正确的环境变量${NC}"
    fi
    
    # 初始化数据库
    echo -e "${BLUE}🗄️  初始化数据库...${NC}"
    npx prisma generate
    npx prisma db push
    
    cd ~
fi

# 2. 解压前端文件
echo -e "${BLUE}📦 解压前端文件...${NC}"
if [ -f ~/frontend.tar.gz ]; then
    sudo mkdir -p /var/www/$DOMAIN
    sudo tar -xzf ~/frontend.tar.gz -C /var/www/$DOMAIN --strip-components=1
    sudo chown -R www-data:www-data /var/www/$DOMAIN
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

# 4. 配置Nginx
echo -e "${BLUE}🌐 配置Nginx...${NC}"
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOF
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

# 启用站点
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 测试Nginx配置
sudo nginx -t

# 5. 启动服务
echo -e "${BLUE}🚀 启动服务...${NC}"

# 停止旧的PM2进程
pm2 delete running-tracker-api 2>/dev/null || true

# 启动新的PM2进程
pm2 start ~/ecosystem.config.js
pm2 save

# 重启Nginx
sudo systemctl restart nginx

# 6. 申请SSL证书
echo -e "${BLUE}🔐 申请SSL证书...${NC}"
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN || {
    echo -e "${YELLOW}⚠️  SSL证书申请失败，请手动运行: sudo certbot --nginx -d $DOMAIN${NC}"
}

# 7. 设置防火墙
echo -e "${BLUE}🔒 配置防火墙...${NC}"
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# 8. 显示状态
echo -e "${GREEN}✅ 服务器设置完成！${NC}"
echo -e "${BLUE}📊 服务状态:${NC}"
echo -e "Nginx: $(sudo systemctl is-active nginx)"
echo -e "PM2: $(pm2 list | grep running-tracker-api | wc -l) 个进程运行中"

echo -e "${GREEN}🌐 访问测试:${NC}"
echo -e "前端: http://$DOMAIN"
echo -e "API: http://$DOMAIN/api/health"

# 清理临时文件
rm -f ~/backend.tar.gz ~/frontend.tar.gz ~/server-setup.sh

echo -e "${YELLOW}💡 下一步:${NC}"
echo -e "1. 检查 ~/backend/.env 环境变量配置"
echo -e "2. 测试API: curl http://$DOMAIN/api/health"
echo -e "3. 访问前端: http://$DOMAIN" 