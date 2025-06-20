# 🚀 测试环境部署完整指南

如果你还没有域名和服务器，这份指南将一步步教你如何部署到测试环境。

## 📋 目录

1. [免费云服务部署（推荐新手）](#1-免费云服务部署推荐新手)
2. [VPS 服务器部署](#2-vps服务器部署)
3. [前端部署](#3-前端部署)
4. [配置域名（可选）](#4-配置域名可选)
5. [Flutter 应用配置](#5-flutter应用配置)

---

## 1. 免费云服务部署（推荐新手）

### 方案一：Railway.app（最简单）

#### 步骤 1：准备代码

```bash
# 确保你的后端代码已提交到GitHub
cd backend
git add .
git commit -m "准备部署后端"
git push
```

#### 步骤 2：部署到 Railway

1. **注册账号**

   - 访问 [railway.app](https://railway.app)
   - 使用 GitHub 账号登录

2. **创建新项目**

   ```
   点击 "New Project" → "Deploy from GitHub repo" → 选择你的仓库
   ```

3. **配置环境变量**

   ```
   在Railway项目设置中添加：

   DATABASE_URL=file:./dev.db
   JWT_SECRET=your-super-secret-jwt-key-for-production
   JWT_EXPIRES_IN=7d
   NODE_ENV=production
   PORT=3000
   ```

4. **配置启动命令**

   ```
   在railway.toml中或项目设置中：

   [build]
   builder = "NIXPACKS"

   [deploy]
   startCommand = "npm start"
   ```

5. **等待部署完成**
   - Railway 会自动分配一个域名，如：`your-app-name.up.railway.app`

#### 步骤 3：测试 API

```bash
# 测试你的API
curl https://your-app-name.up.railway.app/health
```

### 方案二：Render.com（免费但有限制）

#### 步骤 1：注册并连接 GitHub

1. 访问 [render.com](https://render.com)
2. 注册账号并连接 GitHub

#### 步骤 2：创建 Web Service

1. 点击 "New Web Service"
2. 选择你的 GitHub 仓库
3. 配置：
   ```
   Name: your-app-backend
   Environment: Node
   Build Command: npm install
   Start Command: npm start
   ```

#### 步骤 3：设置环境变量

```
DATABASE_URL=file:./dev.db
JWT_SECRET=your-production-secret-key
NODE_ENV=production
PORT=10000
```

#### 步骤 4：部署

- Render 会给你一个域名：`your-app-backend.onrender.com`

---

## 2. VPS 服务器部署

### 推荐 VPS 提供商

#### DigitalOcean ($5/月)

1. **注册账号**：[digitalocean.com](https://digitalocean.com)
2. **创建 Droplet**：
   ```
   镜像：Ubuntu 22.04 LTS
   规格：Basic ($5/月)
   数据中心：选择离你最近的
   ```

#### 部署步骤

#### 步骤 1：连接服务器

```bash
# 通过SSH连接
ssh root@your-server-ip
```

#### 步骤 2：安装环境

```bash
# 更新系统
apt update && apt upgrade -y

# 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# 安装PM2（进程管理器）
npm install -g pm2

# 安装Git
apt install git -y
```

#### 步骤 3：部署代码

```bash
# 克隆代码
git clone https://github.com/your-username/your-repo.git
cd your-repo/backend

# 安装依赖
npm install

# 创建环境变量
nano .env
```

添加以下内容：

```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="your-super-secret-production-key"
JWT_EXPIRES_IN="7d"
PORT=3000
NODE_ENV="production"
FRONTEND_URL="https://your-frontend-domain.com"
```

#### 步骤 4：启动服务

```bash
# 生成数据库
npx prisma db push

# 使用PM2启动
pm2 start server.js --name "running-app-backend"

# 保存PM2配置
pm2 save
pm2 startup
```

#### 步骤 5：配置 Nginx（反向代理）

```bash
# 安装Nginx
apt install nginx -y

# 创建配置文件
nano /etc/nginx/sites-available/your-app
```

添加以下配置：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# 启用站点
ln -s /etc/nginx/sites-available/your-app /etc/nginx/sites-enabled/

# 测试配置
nginx -t

# 重启Nginx
systemctl restart nginx
```

---

## 3. 前端部署

### 方案一：Vercel（推荐）

#### 步骤 1：构建 Flutter Web

```bash
# 构建Web版本
flutter build web --release
```

#### 步骤 2：部署到 Vercel

1. 访问 [vercel.com](https://vercel.com)
2. 连接 GitHub 账号
3. 导入项目
4. 配置：
   ```
   Framework Preset: Other
   Build Command: flutter build web --release
   Output Directory: build/web
   ```

### 方案二：Netlify

1. 访问 [netlify.com](https://netlify.com)
2. 拖拽 `build/web` 文件夹到部署区域
3. 自动获得域名

---

## 4. 配置域名（可选）

### 免费域名

- [Freenom](https://freenom.com) - 免费域名（.tk, .ml 等）
- [NoIP](https://noip.com) - 动态 DNS

### 付费域名

- [Namecheap](https://namecheap.com) - $8-12/年
- [GoDaddy](https://godaddy.com) - $10-15/年
- [Cloudflare](https://cloudflare.com) - $8-10/年

### DNS 配置

```
A记录：
名称: @
值: your-server-ip

A记录：
名称: api
值: your-server-ip
```

### SSL 证书（免费）

```bash
# 安装Certbot
apt install certbot python3-certbot-nginx -y

# 获取SSL证书
certbot --nginx -d yourdomain.com -d api.yourdomain.com
```

---

## 5. Flutter 应用配置

### 更新 API 地址

修改 `lib/core/constants/app_config.dart`：

```dart
/// 测试环境配置
static const String _testApiUrl = 'https://your-api-domain.com/api/auth';

/// 生产环境配置
static const String _prodApiUrl = 'https://your-api-domain.com/api/auth';
```

### 构建不同环境的应用

#### 测试环境

```bash
# Android
flutter build apk --release --dart-define=ENV=test --dart-define=API_BASE_URL=https://your-test-api.com/api/auth

# iOS
flutter build ios --release --dart-define=ENV=test --dart-define=API_BASE_URL=https://your-test-api.com/api/auth
```

#### 生产环境

```bash
# Android
flutter build appbundle --release --dart-define=ENV=production --dart-define=API_BASE_URL=https://your-prod-api.com/api/auth

# iOS
flutter build ios --release --dart-define=ENV=production --dart-define=API_BASE_URL=https://your-prod-api.com/api/auth
```

---

## 🔥 快速部署方案（5 分钟搞定）

如果你想快速测试，推荐这个方案：

### 1. 后端 → Railway

- 注册 Railway 账号
- 连接 GitHub 仓库
- 自动部署获得域名

### 2. 前端 → Vercel

- 注册 Vercel 账号
- 部署 Flutter Web 版本
- 自动获得域名

### 3. 移动端配置

```bash
# 使用Railway给的域名构建APP
flutter build apk --release --dart-define=API_BASE_URL=https://your-app.up.railway.app/api/auth
```

---

## 📞 部署问题排查

### 常见问题

#### 1. 数据库连接失败

```bash
# 检查环境变量
echo $DATABASE_URL

# 重新生成数据库
npx prisma db push
```

#### 2. 跨域问题

```javascript
// 在server.js中确保CORS配置正确
app.use(
  cors({
    origin: ["https://your-frontend-domain.com", "http://localhost:8080"],
    credentials: true,
  })
);
```

#### 3. 端口冲突

```bash
# 检查端口使用
lsof -i :3000

# 修改端口
export PORT=8080
```

### 测试部署

```bash
# 测试API健康检查
curl https://your-api-domain.com/health

# 测试注册接口
curl -X POST https://your-api-domain.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456"}'
```

---

## 🎯 总结

1. **新手推荐**：Railway + Vercel
2. **进阶用户**：VPS + 自定义域名
3. **企业级**：AWS/GCP + CDN + 监控

选择适合你的方案，按步骤操作即可！🚀
