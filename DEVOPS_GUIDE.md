# 🏃‍♂️ 跑步追踪器 - 运维操作手册

## 📋 目录

- [服务器信息](#服务器信息)
- [部署操作](#部署操作)
- [日常维护](#日常维护)
- [监控和调试](#监控和调试)
- [故障排除](#故障排除)
- [备份和恢复](#备份和恢复)

## 🖥️ 服务器信息

### 基本信息

- **服务器 IP**: `104.225.147.57`
- **域名**: `myrunning.app`
- **操作系统**: Rocky Linux 9.6
- **SSH 用户**: `deploy`
- **部署目录**: `/home/deploy/backend`
- **前端目录**: `/var/www/myrunning.app`

### 服务端口

- **前端**: 80/443 (Nginx)
- **API**: 3000 (PM2)
- **SSH**: 22

## 🚀 部署操作

### 完整部署（前端+后端）

```bash
# 部署到测试服务器
./scripts/deploy-vps-rocky.sh 104.225.147.57 myrunning.app
```

### 仅更新后端代码

```bash
# 上传后端文件
scp backend/routes/auth.js backend/server.js deploy@104.225.147.57:~/backend/

# 重启API服务
ssh deploy@104.225.147.57 'pm2 restart running-tracker-api'
```

### 仅更新前端代码

```bash
# 1. 构建前端
flutter build web --release --dart-define=ENV=production

# 2. 打包并上传
tar -czf frontend.tar.gz build/web/
scp frontend.tar.gz deploy@104.225.147.57:~/

# 3. 在服务器上解压
ssh deploy@104.225.147.57 '
  sudo rm -rf /var/www/myrunning.app/*
  sudo tar -xzf ~/frontend.tar.gz -C /var/www/myrunning.app --strip-components=2
  sudo chown -R nginx:nginx /var/www/myrunning.app
  rm ~/frontend.tar.gz
'
```

### 更新环境变量

```bash
# 使用脚本更新邮件配置
./scripts/update-email-config.sh your_email@qq.com your_auth_code qq

# 或手动更新
ssh deploy@104.225.147.57 'nano ~/backend/.env'
ssh deploy@104.225.147.57 'pm2 restart running-tracker-api'
```

## 🔧 日常维护

### PM2 进程管理

```bash
# 查看进程状态
ssh deploy@104.225.147.57 'pm2 status'

# 重启API服务
ssh deploy@104.225.147.57 'pm2 restart running-tracker-api'

# 停止API服务
ssh deploy@104.225.147.57 'pm2 stop running-tracker-api'

# 启动API服务
ssh deploy@104.225.147.57 'pm2 start running-tracker-api'

# 查看详细信息
ssh deploy@104.225.147.57 'pm2 show running-tracker-api'

# 实时监控
ssh deploy@104.225.147.57 'pm2 monit'
```

### Nginx 管理

```bash
# 检查Nginx状态
ssh deploy@104.225.147.57 'sudo systemctl status nginx'

# 重启Nginx
ssh deploy@104.225.147.57 'sudo systemctl restart nginx'

# 重新加载配置
ssh deploy@104.225.147.57 'sudo systemctl reload nginx'

# 测试配置文件
ssh deploy@104.225.147.57 'sudo nginx -t'

# 查看Nginx配置
ssh deploy@104.225.147.57 'sudo cat /etc/nginx/conf.d/myrunning.app.conf'
```

### 系统服务管理

```bash
# 查看系统负载
ssh deploy@104.225.147.57 'htop'

# 查看磁盘使用
ssh deploy@104.225.147.57 'df -h'

# 查看内存使用
ssh deploy@104.225.147.57 'free -h'

# 查看网络连接
ssh deploy@104.225.147.57 'netstat -tulnp'
```

## 📊 监控和调试

### 查看日志

```bash
# API应用日志（实时）
ssh deploy@104.225.147.57 'pm2 logs running-tracker-api'

# API应用日志（最近20行）
ssh deploy@104.225.147.57 'pm2 logs running-tracker-api --lines 20'

# 只看错误日志
ssh deploy@104.225.147.57 'pm2 logs running-tracker-api --err'

# 只看输出日志
ssh deploy@104.225.147.57 'pm2 logs running-tracker-api --out'

# Nginx访问日志
ssh deploy@104.225.147.57 'sudo tail -f /var/log/nginx/access.log'

# Nginx错误日志
ssh deploy@104.225.147.57 'sudo tail -f /var/log/nginx/error.log'

# 系统日志
ssh deploy@104.225.147.57 'sudo journalctl -u nginx -f'
```

### API 测试

```bash
# 健康检查
curl http://104.225.147.57/health

# 测试验证码发送
curl -X POST http://104.225.147.57/api/auth/send-verification-code \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com"}'

# 检查CORS配置
curl -H "Origin: http://104.225.147.57" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: X-Requested-With" \
     -X OPTIONS http://104.225.147.57/api/auth/login
```

### 性能监控

```bash
# PM2进程监控
ssh deploy@104.225.147.57 'pm2 monit'

# 系统资源监控
ssh deploy@104.225.147.57 'top'

# 网络流量监控
ssh deploy@104.225.147.57 'iftop'

# 查看端口占用
ssh deploy@104.225.147.57 'sudo netstat -tulnp | grep :3000'
```

## 🚨 故障排除

### API 服务无法启动

```bash
# 1. 查看PM2状态
ssh deploy@104.225.147.57 'pm2 status'

# 2. 查看错误日志
ssh deploy@104.225.147.57 'pm2 logs running-tracker-api --err --lines 50'

# 3. 检查环境变量
ssh deploy@104.225.147.57 'cat ~/backend/.env'

# 4. 手动测试启动
ssh deploy@104.225.147.57 'cd ~/backend && node server.js'

# 5. 检查依赖
ssh deploy@104.225.147.57 'cd ~/backend && pnpm install'
```

### 前端无法访问

```bash
# 1. 检查Nginx状态
ssh deploy@104.225.147.57 'sudo systemctl status nginx'

# 2. 检查配置文件
ssh deploy@104.225.147.57 'sudo nginx -t'

# 3. 查看前端文件
ssh deploy@104.225.147.57 'ls -la /var/www/myrunning.app/'

# 4. 检查权限
ssh deploy@104.225.147.57 'sudo chown -R nginx:nginx /var/www/myrunning.app'
```

### 邮件发送失败

```bash
# 1. 检查邮件配置
ssh deploy@104.225.147.57 'grep EMAIL ~/backend/.env'

# 2. 测试SMTP连接
ssh deploy@104.225.147.57 'telnet smtp.qq.com 587'

# 3. 查看邮件相关日志
ssh deploy@104.225.147.57 'pm2 logs running-tracker-api | grep -i email'
```

### 数据库问题

```bash
# 1. 检查数据库文件
ssh deploy@104.225.147.57 'ls -la ~/backend/prod.db'

# 2. 重新生成Prisma客户端
ssh deploy@104.225.147.57 'cd ~/backend && npx prisma generate'

# 3. 应用数据库迁移
ssh deploy@104.225.147.57 'cd ~/backend && npx prisma db push'
```

## 💾 备份和恢复

### 数据库备份

```bash
# 备份数据库
ssh deploy@104.225.147.57 'cp ~/backend/prod.db ~/backend/prod.db.backup.$(date +%Y%m%d_%H%M%S)'

# 下载备份到本地
scp deploy@104.225.147.57:~/backend/prod.db.backup.* ./backups/
```

### 配置文件备份

```bash
# 备份环境变量
scp deploy@104.225.147.57:~/backend/.env ./backups/env.backup.$(date +%Y%m%d_%H%M%S)

# 备份Nginx配置
ssh deploy@104.225.147.57 'sudo cp /etc/nginx/conf.d/myrunning.app.conf /tmp/'
scp deploy@104.225.147.57:/tmp/myrunning.app.conf ./backups/
```

### 恢复操作

```bash
# 恢复数据库
scp ./backups/prod.db.backup.YYYYMMDD_HHMMSS deploy@104.225.147.57:~/backend/prod.db
ssh deploy@104.225.147.57 'pm2 restart running-tracker-api'

# 恢复环境变量
scp ./backups/env.backup.YYYYMMDD_HHMMSS deploy@104.225.147.57:~/backend/.env
ssh deploy@104.225.147.57 'pm2 restart running-tracker-api'
```

## 📱 本地开发

### 启动本地服务

```bash
# 启动后端
cd backend && pnpm dev

# 启动前端（另一个终端）
flutter run -d chrome --web-port 8080
```

### 本地 API 测试

```bash
# 健康检查
curl http://localhost:3001/health

# 测试验证码（开发环境会返回验证码）
curl -X POST http://localhost:3001/api/auth/send-verification-code \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com"}'
```

## 🔄 常用命令快速参考

```bash
# 快速部署
./scripts/deploy-vps-rocky.sh 104.225.147.57 myrunning.app

# 查看服务状态
ssh deploy@104.225.147.57 'pm2 status && sudo systemctl status nginx'

# 查看实时日志
ssh deploy@104.225.147.57 'pm2 logs running-tracker-api'

# 重启所有服务
ssh deploy@104.225.147.57 'pm2 restart running-tracker-api && sudo systemctl reload nginx'

# 更新邮件配置
./scripts/update-email-config.sh your_email@qq.com your_auth_code qq

# 健康检查
curl http://104.225.147.57/health
```

---

## 📞 故障联系

如果遇到无法解决的问题，请提供以下信息：

1. 错误描述和截图
2. 相关日志内容
3. 执行的命令和参数
4. 系统环境信息
