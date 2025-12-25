#!/bin/bash

# 📜 法律文档部署脚本
# 此脚本将用户协议和隐私政策上传到VPS服务器

# 配置信息
VPS_IP="104.225.147.57"
VPS_PORT="2222"
VPS_USER="root"
# 注意：密码需要在执行scp命令时手动输入
# VPS_PASS="8w6jZDrWAgSE" 

REMOTE_DIR="/var/www/myrunning.app"

echo "🚀 开始部署法律文档..."
echo "目标服务器: $VPS_USER@$VPS_IP:$VPS_PORT"
echo "目标目录: $REMOTE_DIR"

# 检查本地文件是否存在
if [ ! -f "docs/legal/terms.html" ] || [ ! -f "docs/legal/privacy.html" ]; then
    echo "❌ 错误: 找不到本地法律文档文件 (docs/legal/terms.html, docs/legal/privacy.html)"
    exit 1
fi

echo "📦 正在上传文件..."
echo "⚠️  提示: 系统将提示您输入服务器密码 (8w6jZDrWAgSE)"

# 使用 scp 上传文件
# -P 指定端口
scp -P $VPS_PORT docs/legal/terms.html docs/legal/privacy.html $VPS_USER@$VPS_IP:$REMOTE_DIR/

if [ $? -eq 0 ]; then
    echo "✅ 上传成功!"
    echo "-----------------------------------"
    echo "🌐 访问地址:"
    echo "用户协议: https://lawrencezhouda.xyz/terms.html"
    echo "隐私政策: https://lawrencezhouda.xyz/privacy.html"
    echo "-----------------------------------"
else
    echo "❌ 上传失败，请检查网络连接或密码是否正确。"
fi

