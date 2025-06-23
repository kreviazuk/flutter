# 🚀 VPS 部署配置指南

## 📋 部署前准备

### 1. 环境变量配置

在 `backend/` 目录创建 `.env` 文件：

```bash
# 数据库配置
DATABASE_URL="file:./prod.db"

# JWT密钥（请修改为强密码）
JWT_SECRET="your-super-strong-jwt-secret-change-this"

# 服务端口
PORT=3000

# 运行环境
NODE_ENV=production

# 前端域名（替换为您的域名）
FRONTEND_URL=https://your-domain.com
```

### 2. DNS 配置

将您的域名 DNS 记录指向 VPS IP：

```
A记录    your-domain.com      -> YOUR_VPS_IP
A记录    www.your-domain.com  -> YOUR_VPS_IP
```

### 3. 部署命令

```bash
# 确保您在项目根目录
cd /path/to/my_flutter_app

# 运行部署脚本（替换为您的实际IP和域名）
./scripts/deploy-vps.sh YOUR_VPS_IP your-domain.com
```

## 🔧 部署步骤详解

### 步骤 1：初始化服务器

```bash
# 上传并运行初始化脚本
scp scripts/init-server.sh root@YOUR_VPS_IP:~/
ssh root@YOUR_VPS_IP './init-server.sh'
```

### 步骤 2：执行部署

```bash
# 在本地执行部署
./scripts/deploy-vps.sh YOUR_VPS_IP your-domain.com
```

### 步骤 3：验证部署

```bash
# 检查服务状态
ssh deploy@YOUR_VPS_IP 'pm2 status'

# 检查API健康状态
curl https://your-domain.com/api/health

# 检查前端访问
curl https://your-domain.com
```

## 🎯 完成后的访问地址

- 🌐 前端应用: `https://your-domain.com`
- 📱 API 接口: `https://your-domain.com/api`
- 🔍 健康检查: `https://your-domain.com/api/health`

## 🐛 故障排除

### 查看服务日志

```bash
ssh deploy@YOUR_VPS_IP
pm2 logs running-tracker-api
```

### 重启服务

```bash
ssh deploy@YOUR_VPS_IP
pm2 restart running-tracker-api
```

### 查看 Nginx 状态

```bash
ssh deploy@YOUR_VPS_IP
sudo systemctl status nginx
sudo nginx -t
```
