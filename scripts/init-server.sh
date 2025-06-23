#!/bin/bash

# 🔧 VPS服务器初始化脚本
# 在VPS上以root用户身份运行
# 支持 Ubuntu/Debian 和 CentOS/RHEL 系统

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 开始初始化VPS服务器...${NC}"

# 检测操作系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

echo -e "${BLUE}📋 检测到系统: $OS $VER${NC}"

# 1. 更新系统并安装基础软件
echo -e "${BLUE}📦 更新系统软件包...${NC}"

if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
    # Ubuntu/Debian 系统
    echo -e "${BLUE}使用 apt 包管理器...${NC}"
    apt update && apt upgrade -y
    
    # 安装必要软件
    echo -e "${BLUE}📦 安装必要软件...${NC}"
    apt install -y \
        curl \
        wget \
        git \
        nginx \
        certbot \
        python3-certbot-nginx \
        ufw \
        fail2ban \
        htop \
        tree \
        unzip

elif [[ $OS == *"CentOS"* ]] || [[ $OS == *"Red Hat"* ]] || [[ $OS == *"Rocky"* ]] || [[ $OS == *"AlmaLinux"* ]]; then
    # CentOS/RHEL 系统
    echo -e "${BLUE}使用 yum/dnf 包管理器...${NC}"
    
    # 检查是否有dnf，否则使用yum
    if command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    else
        PKG_MANAGER="yum"
    fi
    
    echo -e "${BLUE}使用 $PKG_MANAGER 更新系统...${NC}"
    $PKG_MANAGER update -y
    
    # 安装EPEL仓库（用于额外软件包）
    if [[ $VER == "7"* ]]; then
        $PKG_MANAGER install -y epel-release
    elif [[ $VER == "8"* ]] || [[ $VER == "9"* ]]; then
        $PKG_MANAGER install -y epel-release
        if command -v dnf &> /dev/null; then
            dnf config-manager --set-enabled powertools 2>/dev/null || \
            dnf config-manager --set-enabled crb 2>/dev/null || true
        fi
    fi
    
    # 安装必要软件
    echo -e "${BLUE}📦 安装必要软件...${NC}"
    $PKG_MANAGER install -y \
        curl \
        wget \
        git \
        nginx \
        certbot \
        python3-certbot-nginx \
        firewalld \
        fail2ban \
        htop \
        tree \
        unzip

    # 启动并启用firewalld（CentOS的防火墙）
    systemctl start firewalld
    systemctl enable firewalld
    
    # 启动并启用nginx
    systemctl start nginx
    systemctl enable nginx

else
    echo -e "${RED}❌ 不支持的操作系统: $OS${NC}"
    echo -e "${YELLOW}支持的系统: Ubuntu, Debian, CentOS, RHEL, Rocky Linux, AlmaLinux${NC}"
    exit 1
fi

# 2. 安装Node.js和pnpm
echo -e "${BLUE}📦 安装Node.js...${NC}"

# 使用NodeSource官方脚本安装Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - 2>/dev/null || \
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash - 2>/dev/null || {
    echo -e "${YELLOW}⚠️  官方脚本失败，尝试手动安装...${NC}"
    
    if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
        apt install -y nodejs npm
    else
        $PKG_MANAGER install -y nodejs npm
    fi
}

# 安装Node.js（如果上面的脚本成功了）
if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
    apt install -y nodejs
else
    $PKG_MANAGER install -y nodejs
fi

# 安装pnpm和PM2
npm install -g pnpm pm2

# 3. 创建部署用户
echo -e "${BLUE}👤 创建部署用户...${NC}"
if ! id "deploy" &>/dev/null; then
    useradd -m -s /bin/bash deploy
    usermod -aG wheel deploy 2>/dev/null || usermod -aG sudo deploy 2>/dev/null || true
    
    # 为deploy用户设置sudo权限
    echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# 4. 设置SSH密钥
echo -e "${BLUE}🔑 设置SSH目录...${NC}"
mkdir -p /home/deploy/.ssh
chown deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh

# 复制root的SSH密钥到deploy用户
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/deploy/.ssh/
    chown deploy:deploy /home/deploy/.ssh/authorized_keys
    chmod 600 /home/deploy/.ssh/authorized_keys
fi

# 5. 配置防火墙
echo -e "${BLUE}🔒 配置防火墙...${NC}"

if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
    # Ubuntu/Debian 使用 ufw
    ufw allow ssh
    ufw allow 'Nginx Full'
    ufw --force enable
else
    # CentOS/RHEL 使用 firewalld
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi

# 6. 启动PM2开机自启
echo -e "${BLUE}⚙️ 配置PM2...${NC}"
su - deploy -c "pm2 startup" || true
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u deploy --hp /home/deploy

# 7. 启动并启用服务
systemctl start nginx
systemctl enable nginx
systemctl start fail2ban
systemctl enable fail2ban

echo -e "${GREEN}✅ 服务器初始化完成！${NC}"
echo -e "${BLUE}📋 系统信息:${NC}"
echo -e "操作系统: $OS $VER"
echo -e "Node.js: $(node --version 2>/dev/null || echo '未安装')"
echo -e "pnpm: $(pnpm --version 2>/dev/null || echo '未安装')"
echo -e "Nginx: $(nginx -v 2>&1 | grep -o 'nginx/[0-9.]*' || echo '未安装')"

echo -e "${YELLOW}📝 下一步：${NC}"
echo -e "1. SSH密钥已配置，可以免密连接deploy用户"
echo -e "2. 运行部署脚本: ./scripts/quick-deploy.sh"
echo -e "3. 测试连接: ssh deploy@$(hostname -I | awk '{print $1}')" 