#!/bin/bash

echo "🔍 Railway 部署准备检查"
echo "========================="

# 检查是否在正确目录
if [ ! -d "backend" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

echo "✅ 项目目录结构正确"

# 检查关键文件
echo ""
echo "📁 检查关键文件..."

if [ ! -f "backend/package.json" ]; then
    echo "❌ 缺少 backend/package.json"
    exit 1
fi
echo "✅ package.json 存在"

if [ ! -f "backend/server.js" ]; then
    echo "❌ 缺少 backend/server.js"
    exit 1
fi
echo "✅ server.js 存在"

if [ ! -f "backend/prisma/schema.prisma" ]; then
    echo "❌ 缺少 prisma/schema.prisma"
    exit 1
fi
echo "✅ Prisma schema 存在"

# 检查 package.json scripts
echo ""
echo "🔧 检查 package.json scripts..."
if grep -q '"start".*"node server.js"' backend/package.json; then
    echo "✅ start 脚本配置正确"
else
    echo "❌ 缺少正确的 start 脚本"
    echo "应该是: \"start\": \"node server.js\""
fi

# 检查 Git 状态
echo ""
echo "📚 检查 Git 状态..."
if [ -d ".git" ]; then
    echo "✅ Git 仓库已初始化"
    
    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠️  有未提交的更改，请先提交："
        echo "   git add ."
        echo "   git commit -m '准备部署到 Railway'"
        echo "   git push origin main"
    else
        echo "✅ 代码已提交"
    fi
else
    echo "❌ 尚未初始化 Git 仓库"
    echo "请运行: git init && git add . && git commit -m 'Initial commit'"
fi

# 检查环境变量模板
echo ""
echo "⚙️  检查环境变量配置..."
if [ -f "backend/.env" ]; then
    echo "⚠️  检测到本地 .env 文件"
    echo "   Railway 部署时需要在项目设置中手动配置环境变量"
else
    echo "✅ 无本地 .env 文件，部署时配置环境变量"
fi

echo ""
echo "📋 Railway 环境变量配置清单："
echo "================================"
echo "DATABASE_URL=file:./dev.db"
echo "JWT_SECRET=your-super-secret-jwt-key-for-production-change-this"
echo "JWT_EXPIRES_IN=7d"
echo "NODE_ENV=production"
echo "PORT=3000"
echo "FRONTEND_URL=*"
echo "================================"

echo ""
echo "🚀 下一步操作："
echo "1. 访问 https://railway.app"
echo "2. 使用 GitHub 账号登录"
echo "3. 点击 'New Project' → 'Deploy from GitHub repo'"
echo "4. 选择此仓库并设置根目录为 'backend'"
echo "5. 配置上述环境变量"
echo "6. 等待部署完成"

echo ""
echo "💡 提示：复制上面的环境变量配置，部署时粘贴使用" 