#!/bin/bash

# 🔧 Rocky Linux VPS服务器初始化脚本
# 专门针对 Rocky Linux 9.x 系统

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 开始初始化Rocky Linux VPS服务器...${NC}"

# 检测系统版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${BLUE}📋 检测到系统: $NAME $VERSION_ID${NC}"
fi

# 1. 更新系统
echo -e "${BLUE}📦 更新系统软件包...${NC}"
dnf update -y

# 2. 启用必要的仓库
echo -e "${BLUE}📦 配置软件仓库...${NC}"
dnf install -y epel-release
dnf config-manager --set-enabled crb

# 3. 安装基础软件
echo -e "${BLUE}📦 安装基础软件...${NC}"
dnf install -y \
    curl \
    wget \
    git \
    nginx \
    firewalld \
    unzip \
    tar \
    vim

# 4. 安装可选软件（如果可用）
echo -e "${BLUE}📦 安装可选软件...${NC}"

# 尝试安装certbot
dnf install -y certbot python3-certbot-nginx 2>/dev/null || {
    echo -e "${YELLOW}⚠️  从snap安装certbot...${NC}"
    dnf install -y snapd
    systemctl enable --now snapd.socket
    ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
    snap install core; snap refresh core
    snap install --classic certbot
    ln -sf /snap/bin/certbot /usr/bin/certbot 2>/dev/null || true
} || {
    echo -e "${YELLOW}⚠️  certbot安装失败，稍后手动安装${NC}"
}

# 尝试安装htop
dnf install -y htop 2>/dev/null || {
    echo -e "${YELLOW}⚠️  htop不可用，使用top替代${NC}"
}

# 尝试安装fail2ban
dnf install -y fail2ban 2>/dev/null || {
    echo -e "${YELLOW}⚠️  fail2ban不可用，跳过安装${NC}"
}

# 安装tree
dnf install -y tree 2>/dev/null || {
    echo -e "${YELLOW}⚠️  tree不可用，跳过安装${NC}"
}

# 5. 安装Node.js
echo -e "${BLUE}📦 安装Node.js...${NC}"

# 使用NodeSource官方仓库
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
dnf install -y nodejs

# 验证安装
node_version=$(node --version 2>/dev/null || echo "未安装")
npm_version=$(npm --version 2>/dev/null || echo "未安装")

echo -e "${GREEN}✅ Node.js: $node_version${NC}"
echo -e "${GREEN}✅ npm: $npm_version${NC}"

# 6. 安装pnpm和PM2
echo -e "${BLUE}📦 安装pnpm和PM2...${NC}"
npm install -g pnpm pm2

# 7. 创建部署用户
echo -e "${BLUE}👤 创建部署用户...${NC}"
if ! id "deploy" &>/dev/null; then
    useradd -m -s /bin/bash deploy
    usermod -aG wheel deploy
    echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo -e "${GREEN}✅ deploy用户已创建${NC}"
else
    echo -e "${YELLOW}⚠️  deploy用户已存在${NC}"
fi

# 8. 设置SSH密钥
echo -e "${BLUE}🔑 配置SSH密钥...${NC}"
mkdir -p /home/deploy/.ssh
chown deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh

# 复制root的SSH密钥到deploy用户
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/deploy/.ssh/
    chown deploy:deploy /home/deploy/.ssh/authorized_keys
    chmod 600 /home/deploy/.ssh/authorized_keys
    echo -e "${GREEN}✅ SSH密钥已复制到deploy用户${NC}"
fi

# 9. 配置防火墙
echo -e "${BLUE}🔒 配置防火墙...${NC}"
systemctl start firewalld
systemctl enable firewalld

firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

echo -e "${GREEN}✅ 防火墙已配置${NC}"

# 10. 启动并启用Nginx
echo -e "${BLUE}🌐 配置Nginx...${NC}"
systemctl start nginx
systemctl enable nginx

# 设置SELinux策略（Rocky Linux默认启用SELinux）
setsebool -P httpd_can_network_connect 1 2>/dev/null || true
setsebool -P httpd_can_network_relay 1 2>/dev/null || true

echo -e "${GREEN}✅ Nginx已启动并配置${NC}"

# 11. 配置PM2
echo -e "${BLUE}⚙️ 配置PM2...${NC}"
su - deploy -c "pm2 startup" 2>/dev/null || true
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u deploy --hp /home/deploy

# 12. 启动fail2ban（如果已安装）
if systemctl list-unit-files | grep -q fail2ban; then
    systemctl start fail2ban
    systemctl enable fail2ban
    echo -e "${GREEN}✅ fail2ban已启动${NC}"
fi

# 13. 显示系统信息
echo -e "${GREEN}🎉 Rocky Linux服务器初始化完成！${NC}"
echo -e "${BLUE}=====================================${NC}"
echo -e "${GREEN}📋 系统信息:${NC}"
echo -e "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo -e "Node.js: $(node --version 2>/dev/null || echo '未安装')"
echo -e "npm: $(npm --version 2>/dev/null || echo '未安装')"
echo -e "pnpm: $(pnpm --version 2>/dev/null || echo '未安装')"
echo -e "Nginx: $(nginx -v 2>&1 | head -n1 || echo '未安装')"

echo -e "${GREEN}🔧 服务状态:${NC}"
echo -e "Nginx: $(systemctl is-active nginx)"
echo -e "Firewalld: $(systemctl is-active firewalld)"
echo -e "Fail2ban: $(systemctl is-active fail2ban 2>/dev/null || echo 'not installed')"

echo -e "${YELLOW}📝 下一步：${NC}"
echo -e "1. ✅ SSH密钥已配置，可以免密连接deploy用户"
echo -e "2. 🚀 运行部署脚本: ./scripts/quick-deploy.sh"
echo -e "3. 🔍 测试连接: ssh deploy@$(hostname -I | awk '{print $1}')"

echo -e "${GREEN}✨ 系统已准备就绪，可以开始部署应用！${NC}" 