#!/bin/bash

# 🔐 SSH密钥配置脚本
# 将本地SSH公钥添加到VPS服务器，实现免密登录

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔐 SSH密钥配置工具${NC}"
echo -e "${BLUE}=============================${NC}"

# 1. 获取VPS信息
if [ -z "$1" ]; then
    read -p "🌐 请输入VPS IP地址: " SERVER_IP
else
    SERVER_IP=$1
fi

if [ -z "$SERVER_IP" ]; then
    echo -e "${RED}❌ IP地址不能为空${NC}"
    exit 1
fi

# 2. 检查本地SSH密钥
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo -e "${YELLOW}⚠️  本地没有SSH密钥，正在生成...${NC}"
    ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_rsa -N ""
    echo -e "${GREEN}✅ SSH密钥已生成${NC}"
fi

# 3. 显示公钥
echo -e "${BLUE}📋 您的SSH公钥:${NC}"
cat ~/.ssh/id_rsa.pub
echo

# 4. 配置服务器SSH密钥
echo -e "${BLUE}🔧 配置服务器SSH密钥...${NC}"

# 方法1：使用ssh-copy-id（推荐）
if command -v ssh-copy-id &> /dev/null; then
    echo -e "${BLUE}使用ssh-copy-id自动配置...${NC}"
    ssh-copy-id -i ~/.ssh/id_rsa.pub root@$SERVER_IP
    
    # 同时配置deploy用户（如果存在）
    echo -e "${BLUE}配置deploy用户SSH密钥...${NC}"
    ssh-copy-id -i ~/.ssh/id_rsa.pub deploy@$SERVER_IP 2>/dev/null || {
        echo -e "${YELLOW}⚠️  deploy用户不存在或未配置，稍后在初始化脚本中会创建${NC}"
    }
else
    # 方法2：手动配置
    echo -e "${BLUE}手动配置SSH密钥...${NC}"
    
    # 为root用户配置
    ssh root@$SERVER_IP "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    cat ~/.ssh/id_rsa.pub | ssh root@$SERVER_IP "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    
    # 为deploy用户配置（如果存在）
    ssh root@$SERVER_IP "
        if id 'deploy' &>/dev/null; then
            mkdir -p /home/deploy/.ssh
            chmod 700 /home/deploy/.ssh
            chown deploy:deploy /home/deploy/.ssh
            cat >> /home/deploy/.ssh/authorized_keys
            chmod 600 /home/deploy/.ssh/authorized_keys
            chown deploy:deploy /home/deploy/.ssh/authorized_keys
        fi
    " < ~/.ssh/id_rsa.pub 2>/dev/null || true
fi

# 5. 测试SSH连接
echo -e "${BLUE}🔍 测试SSH连接...${NC}"

if ssh -o ConnectTimeout=10 -o BatchMode=yes root@$SERVER_IP exit 2>/dev/null; then
    echo -e "${GREEN}✅ root用户SSH密钥认证成功${NC}"
else
    echo -e "${YELLOW}⚠️  root用户SSH密钥认证失败${NC}"
fi

if ssh -o ConnectTimeout=10 -o BatchMode=yes deploy@$SERVER_IP exit 2>/dev/null; then
    echo -e "${GREEN}✅ deploy用户SSH密钥认证成功${NC}"
else
    echo -e "${YELLOW}⚠️  deploy用户不存在或SSH密钥认证失败，这是正常的${NC}"
fi

# 6. 显示结果
echo -e "${GREEN}🎉 SSH密钥配置完成！${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "${GREEN}✨ 现在您可以：${NC}"
echo -e "🔐 免密连接root: ${BLUE}ssh root@$SERVER_IP${NC}"
echo -e "🔐 免密连接deploy: ${BLUE}ssh deploy@$SERVER_IP${NC} (初始化后)"
echo -e "🚀 运行部署脚本: ${BLUE}./scripts/quick-deploy.sh${NC}"

echo -e "${YELLOW}💡 下一步：${NC}"
echo -e "1. 运行部署脚本进行应用部署"
echo -e "2. 初始化脚本会自动创建deploy用户并配置SSH密钥" 