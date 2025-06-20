# 🚀 VPS 服务器部署指南

## 📋 服务器选择推荐

### 🌟 推荐 VPS 服务商

| 服务商           | 价格     | 配置      | 特点                 | 适用场景 |
| ---------------- | -------- | --------- | -------------------- | -------- |
| **阿里云 ECS**   | ¥24/月   | 1 核 2G   | 国内访问快，文档完善 | 国内用户 |
| **腾讯云 CVM**   | ¥25/月   | 1 核 2G   | 新用户优惠，稳定性好 | 国内用户 |
| **DigitalOcean** | $4/月    | 1 核 1G   | 海外访问好，简单易用 | 海外用户 |
| **Vultr**        | $2.50/月 | 1 核 512M | 价格便宜，多地域     | 预算有限 |
| **Linode**       | $5/月    | 1 核 1G   | 性能稳定，技术支持好 | 企业级   |

### 💡 推荐配置

- **最低配置**: 1 核 1G 内存 20G 硬盘
- **推荐配置**: 1 核 2G 内存 40G 硬盘
- **操作系统**: Ubuntu 22.04 LTS

---

## 🔧 服务器初始化

### 1. 连接服务器

```bash
# 使用SSH连接服务器
ssh root@your_server_ip

# 首次连接需要修改密码
passwd
```

### 2. 系统更新

```bash
# 更新系统包
apt update && apt upgrade -y

# 安装必要工具
apt install -y curl wget git vim htop
```

### 3. 创建普通用户

```bash
# 创建新用户
adduser deploy
usermod -aG sudo deploy

# 切换到普通用户
su - deploy
```

---

## 📦 环境安装

### 1. 安装 Node.js

```bash
# 安装Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装pnpm
npm install -g pnpm

# 验证安装
node --version
npm --version
pnpm --version
```

### 2. 安装 Nginx

```bash
sudo apt install -y nginx

# 启动并设置开机自启
sudo systemctl start nginx
sudo systemctl enable nginx

# 验证安装
sudo systemctl status nginx
```

### 3. 安装 PM2 进程管理器

```bash
# 安装PM2
npm install -g pm2

# 设置开机自启
pm2 startup
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u deploy --hp /home/deploy
```

---

## 🚀 项目部署

### 1. 克隆项目

```bash
# 进入用户目录
cd ~

# 克隆项目
git clone https://github.com/your-username/my_flutter_app.git
cd my_flutter_app
```

### 2. 后端部署

```bash
# 进入后端目录
cd backend

# 安装依赖
pnpm install

# 创建生产环境配置
cp .env.example .env
```

**编辑.env 文件**:

```bash
vim .env
```

```env
# 数据库配置
DATABASE_URL="file:./dev.db"

# JWT密钥（生成一个强密码）
JWT_SECRET="your-super-strong-jwt-secret-key-here"

# 服务器配置
PORT=3000
NODE_ENV=production

# 跨域配置
ALLOWED_ORIGINS="https://yourdomain.com,http://localhost:8080"

# 邮件配置（如果需要）
EMAIL_HOST="smtp.gmail.com"
EMAIL_PORT=587
EMAIL_USER="your-email@gmail.com"
EMAIL_PASS="your-email-password"
```

### 3. 初始化数据库

```bash
# 生成Prisma客户端
npx prisma generate

# 同步数据库
npx prisma db push

# 构建项目
pnpm run build
```

### 4. 使用 PM2 启动服务

```bash
# 创建PM2配置文件
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'running-tracker-api',
    script: 'server.js',
    cwd: '/home/deploy/my_flutter_app/backend',
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

# 启动服务
pm2 start ecosystem.config.js

# 保存PM2配置
pm2 save
```

---

## 🌐 Nginx 配置

### 1. 创建 Nginx 配置

```bash
sudo vim /etc/nginx/sites-available/running-tracker
```

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # API代理
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Flutter Web应用
    location / {
        root /home/deploy/my_flutter_app/build/web;
        index index.html;
        try_files $uri $uri/ /index.html;

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
}
```

### 2. 启用配置

```bash
# 启用站点
sudo ln -s /etc/nginx/sites-available/running-tracker /etc/nginx/sites-enabled/

# 删除默认配置
sudo rm /etc/nginx/sites-enabled/default

# 测试配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx
```

---

## 🔐 SSL 证书配置

### 1. 安装 Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 2. 获取 SSL 证书

```bash
# 申请证书（替换为你的域名）
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# 测试自动续期
sudo certbot renew --dry-run
```

---

## 📱 Flutter 前端部署

### 1. 构建 Flutter Web 版本

在本地开发机器上：

```bash
# 构建Web版本
flutter build web --release --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://yourdomain.com/api/auth
```

### 2. 上传到服务器

```bash
# 打包构建文件
tar -czf flutter-web.tar.gz build/web

# 上传到服务器
scp flutter-web.tar.gz deploy@your_server_ip:~/

# 在服务器上解压
ssh deploy@your_server_ip
tar -xzf flutter-web.tar.gz
sudo rm -rf /home/deploy/my_flutter_app/build/web
sudo mv build/web /home/deploy/my_flutter_app/build/
sudo chown -R www-data:www-data /home/deploy/my_flutter_app/build/web
```

---

## 🛠️ 自动化部署

### 1. 快速部署脚本

```bash
# 给脚本执行权限
chmod +x scripts/deploy-vps.sh scripts/server-setup.sh

# 一键部署到VPS（替换为你的服务器IP和域名）
./scripts/deploy-vps.sh 192.168.1.100 myapp.com
```

### 2. 手动部署步骤

如果自动化脚本失败，可以按以下步骤手动部署：

```bash
# 1. 构建Flutter应用
flutter build web --release --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://yourdomain.com/api/auth

# 2. 打包并上传
tar -czf backend.tar.gz backend/
tar -czf frontend.tar.gz build/web/
scp backend.tar.gz frontend.tar.gz deploy@your_server_ip:~/

# 3. 在服务器上执行
ssh deploy@your_server_ip
# 按照上面的服务器配置步骤执行
```

---

## 📱 移动端 APK 配置

### 1. 更新 API 配置

```bash
# 构建指向VPS服务器的APK
flutter build apk --release --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://yourdomain.com/api/auth
```

### 2. 测试 API 连接

```bash
# 测试服务器API
curl https://yourdomain.com/api/health

# 应该返回类似：
# {"status":"OK","timestamp":"2025-01-20T10:00:00.000Z"}
```

---

## 🔧 维护和监控

### 1. 服务监控

```bash
# 查看PM2状态
pm2 status
pm2 logs running-tracker-api

# 查看Nginx状态
sudo systemctl status nginx
sudo tail -f /var/log/nginx/access.log

# 查看系统资源
htop
df -h
```

### 2. 日常维护

```bash
# 重启API服务
pm2 restart running-tracker-api

# 重启Nginx
sudo systemctl restart nginx

# 更新SSL证书
sudo certbot renew

# 备份数据库
cp ~/backend/prod.db ~/backup/prod_$(date +%Y%m%d).db
```

### 3. 更新部署

```bash
# 拉取最新代码
cd ~/my_flutter_app
git pull origin main

# 重新部署
cd ~/my_flutter_app
./scripts/deploy-vps.sh your_server_ip yourdomain.com
```

---

## 💰 成本估算

### 基础配置成本

| 项目           | 服务商        | 配置      | 月费用     | 年费用      |
| -------------- | ------------- | --------- | ---------- | ----------- |
| **VPS 服务器** | 阿里云 ECS    | 1 核 2G   | ¥24        | ¥288        |
| **域名**       | 阿里云        | .com 域名 | ¥5         | ¥60         |
| **SSL 证书**   | Let's Encrypt | 免费证书  | ¥0         | ¥0          |
| **总计**       | -             | -         | **¥29/月** | **¥348/年** |

### 高配版本成本

| 项目           | 服务商        | 配置      | 月费用     | 年费用      |
| -------------- | ------------- | --------- | ---------- | ----------- |
| **VPS 服务器** | 阿里云 ECS    | 2 核 4G   | ¥56        | ¥672        |
| **CDN 加速**   | 阿里云 CDN    | 流量包    | ¥10        | ¥120        |
| **域名**       | 阿里云        | .com 域名 | ¥5         | ¥60         |
| **SSL 证书**   | Let's Encrypt | 免费证书  | ¥0         | ¥0          |
| **总计**       | -             | -         | **¥71/月** | **¥852/年** |

---

## 📞 故障排查

### 1. 常见问题

**Q: Nginx 启动失败**

```bash
# 检查配置语法
sudo nginx -t

# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
```

**Q: PM2 进程启动失败**

```bash
# 查看错误日志
pm2 logs running-tracker-api

# 检查Node.js版本
node --version

# 手动启动测试
cd ~/backend && node server.js
```

**Q: SSL 证书申请失败**

```bash
# 手动申请证书
sudo certbot --nginx -d yourdomain.com

# 检查域名解析
nslookup yourdomain.com
```

**Q: API 无法访问**

```bash
# 检查后端服务
curl http://localhost:3000/health

# 检查防火墙
sudo ufw status

# 检查Nginx代理
sudo nginx -T | grep proxy_pass
```

### 2. 监控脚本

创建简单的监控脚本：

```bash
#!/bin/bash
# 保存为 ~/monitor.sh

# 检查API健康状态
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ API服务正常"
else
    echo "❌ API服务异常，尝试重启..."
    pm2 restart running-tracker-api
fi

# 检查Nginx状态
if sudo systemctl is-active nginx > /dev/null; then
    echo "✅ Nginx服务正常"
else
    echo "❌ Nginx服务异常，尝试重启..."
    sudo systemctl restart nginx
fi

# 检查磁盘空间
DISK_USAGE=$(df / | grep -vE '^Filesystem' | awk '{print $5}' | sed 's/%//g')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠️  磁盘使用率过高: ${DISK_USAGE}%"
fi
```

```bash
# 设置定时监控
chmod +x ~/monitor.sh
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/monitor.sh") | crontab -
```

---

## 🎯 总结

### ✅ VPS 部署优势

1. **完全控制**：拥有服务器完全控制权
2. **稳定可靠**：不受第三方平台限制
3. **成本可控**：月费用约 ¥29-71
4. **性能保证**：独立资源，性能稳定
5. **扩展性强**：可随时升级配置

### 🚀 快速开始

1. **购买 VPS**：选择阿里云、腾讯云等服务商
2. **注册域名**：购买.com 域名并解析到服务器 IP
3. **一键部署**：使用提供的脚本自动化部署
4. **测试验证**：检查前端和 API 是否正常工作

完成后你将拥有一个完全自主可控的跑步追踪应用部署环境！🏃‍♂️
