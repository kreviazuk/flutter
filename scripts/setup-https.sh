#!/bin/bash

# 🔒 VPS HTTPS配置脚本
# 域名: proxy.lawrencezhouda.xyz
# 服务器: 104.225.147.57

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="proxy.lawrencezhouda.xyz"
SERVER_IP="104.225.147.57"

echo -e "${BLUE}🔒 开始配置HTTPS证书...${NC}"

# 检测系统类型
if [ -f /etc/redhat-release ]; then
    SYSTEM="centos"
    echo -e "${GREEN}✅ 检测到CentOS/RHEL系统${NC}"
elif [ -f /etc/debian_version ]; then
    SYSTEM="ubuntu"
    echo -e "${GREEN}✅ 检测到Ubuntu/Debian系统${NC}"
else
    echo -e "${RED}❌ 不支持的系统类型${NC}"
    exit 1
fi

# 安装必要的包
install_packages() {
    echo -e "${BLUE}📦 安装必要的软件包...${NC}"
    
    if [ "$SYSTEM" = "centos" ]; then
        # CentOS/RHEL
        yum update -y
        yum install -y epel-release
        yum install -y nginx snapd
        
        # 启用snapd
        systemctl enable --now snapd.socket
        ln -sf /var/lib/snapd/snap /snap || true
        
        # 使用snap安装certbot
        snap install core; snap refresh core
        snap install --classic certbot
        ln -sf /snap/bin/certbot /usr/bin/certbot || true
        
    elif [ "$SYSTEM" = "ubuntu" ]; then
        # Ubuntu/Debian
        apt update -y
        apt install -y nginx certbot python3-certbot-nginx
    fi
}

# 配置Nginx
configure_nginx() {
    echo -e "${BLUE}🌐 配置Nginx...${NC}"
    
    # 创建基本的Nginx配置
    cat > /etc/nginx/conf.d/$DOMAIN.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    # 后端API代理
    location /api/ {
        proxy_pass http://localhost:3001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # 前端静态文件
    location / {
        root /var/www/html;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

    # 创建网站目录
    mkdir -p /var/www/html
    
    # 测试Nginx配置
    nginx -t
    
    # 启动Nginx
    systemctl enable nginx
    systemctl restart nginx
    
    echo -e "${GREEN}✅ Nginx配置完成${NC}"
}

# 获取SSL证书
get_ssl_certificate() {
    echo -e "${BLUE}🔒 获取SSL证书...${NC}"
    
    # 停止nginx以释放80端口（如果需要）
    systemctl stop nginx
    
    # 获取证书
    certbot certonly --standalone -d $DOMAIN --email admin@$DOMAIN --agree-tos --non-interactive
    
    # 更新Nginx配置以支持HTTPS
    cat > /etc/nginx/conf.d/$DOMAIN.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # SSL配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # 后端API代理
    location /api/ {
        proxy_pass http://localhost:3001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # 前端静态文件
    location / {
        root /var/www/html;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

    # 重启Nginx
    systemctl start nginx
    systemctl reload nginx
    
    echo -e "${GREEN}✅ SSL证书配置完成${NC}"
}

# 设置自动续期
setup_auto_renewal() {
    echo -e "${BLUE}🔄 设置证书自动续期...${NC}"
    
    # 添加续期任务到crontab
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet && systemctl reload nginx") | crontab -
    
    echo -e "${GREEN}✅ 自动续期配置完成${NC}"
}

# 防火墙配置
configure_firewall() {
    echo -e "${BLUE}🛡️  配置防火墙...${NC}"
    
    if command -v firewall-cmd &> /dev/null; then
        # CentOS/RHEL firewalld
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --reload
    elif command -v ufw &> /dev/null; then
        # Ubuntu ufw
        ufw allow 80/tcp
        ufw allow 443/tcp
    fi
    
    echo -e "${GREEN}✅ 防火墙配置完成${NC}"
}

# 测试HTTPS
test_https() {
    echo -e "${BLUE}🧪 测试HTTPS配置...${NC}"
    
    sleep 5
    
    if curl -s -I https://$DOMAIN | grep -q "200 OK"; then
        echo -e "${GREEN}✅ HTTPS配置成功！${NC}"
        echo -e "${GREEN}🌐 访问地址: https://$DOMAIN${NC}"
    else
        echo -e "${YELLOW}⚠️  HTTPS可能需要几分钟时间生效${NC}"
        echo -e "${YELLOW}🌐 请稍后访问: https://$DOMAIN${NC}"
    fi
}

# 主函数
main() {
    echo -e "${BLUE}🚀 开始为 $DOMAIN 配置HTTPS...${NC}"
    
    install_packages
    configure_nginx
    configure_firewall
    get_ssl_certificate
    setup_auto_renewal
    test_https
    
    echo -e "${GREEN}🎉 HTTPS配置完成！${NC}"
    echo -e "${GREEN}📋 配置信息:${NC}"
    echo -e "${GREEN}   域名: https://$DOMAIN${NC}"
    echo -e "${GREEN}   证书位置: /etc/letsencrypt/live/$DOMAIN/${NC}"
    echo -e "${GREEN}   自动续期: 已设置${NC}"
    echo ""
    echo -e "${YELLOW}💡 提示:${NC}"
    echo -e "${YELLOW}   - 证书有效期90天，会自动续期${NC}"
    echo -e "${YELLOW}   - 可以使用 'certbot certificates' 查看证书状态${NC}"
    echo -e "${YELLOW}   - 可以使用 'nginx -t' 测试配置${NC}"
}

# 运行主函数
main "$@" 