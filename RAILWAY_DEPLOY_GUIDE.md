# 🚂 Railway.app 部署详细教程

Railway.app 是一个现代化的云平台，可以让你在几分钟内部署应用程序。本教程将手把手教你如何部署我们的 Flutter 跑步应用后端。

## 📋 准备工作

### 1. 检查后端代码状态

```bash
# 确保你在正确的目录
cd my_flutter_app

# 检查后端文件是否完整
ls backend/
# 应该看到：server.js, package.json, prisma/, routes/ 等

# 检查 package.json 的 scripts 部分
cat backend/package.json
```

### 2. 确保代码已提交到 GitHub

```bash
# 添加所有文件到 Git
git add .

# 提交代码
git commit -m "准备部署到 Railway"

# 推送到 GitHub
git push origin main
```

---

## 🚀 步骤 1：注册 Railway 账号

### 1.1 访问网站

- 打开浏览器，访问：[https://railway.app](https://railway.app)

### 1.2 注册账号

1. 点击右上角 **"Login"** 按钮
2. 选择 **"Login with GitHub"**
3. 如果没有 GitHub 账号，先注册一个
4. 授权 Railway 访问你的 GitHub 账号

---

## 🛠️ 步骤 2：创建新项目

### 2.1 创建项目

1. 登录后，点击 **"New Project"**
2. 选择 **"Deploy from GitHub repo"**
3. 如果这是第一次使用，需要连接 GitHub：
   - 点击 **"Configure GitHub App"**
   - 选择要授权的仓库（可以选择所有仓库或特定仓库）
   - 点击 **"Install & Authorize"**

### 2.2 选择仓库

1. 在仓库列表中找到你的项目
2. 点击 **"Deploy Now"**
3. Railway 会自动检测到这是一个 Node.js 项目

### 2.3 配置根目录

由于我们的后端代码在 `backend` 子目录中：

1. 在项目设置中找到 **"Source"** 或 **"Settings"**
2. 设置 **Root Directory** 为 `backend`
3. 或者在部署时指定：**"backend"**

---

## ⚙️ 步骤 3：配置环境变量

### 3.1 进入项目设置

1. 在 Railway 项目仪表板中
2. 点击你的服务名称
3. 点击 **"Settings"** 或 **"Variables"** 标签

### 3.2 添加环境变量

点击 **"New Variable"** 并添加以下变量：

```env
DATABASE_URL=file:./dev.db
JWT_SECRET=your-super-secret-jwt-key-for-production-change-this
JWT_EXPIRES_IN=7d
NODE_ENV=production
PORT=3000
FRONTEND_URL=*
```

**重要提示**：

- `JWT_SECRET`: 请更改为一个强密码，比如：`my-super-secret-running-app-jwt-key-2024`
- `FRONTEND_URL`: 暂时设为 `*`，后面可以更改为你的前端域名

### 3.3 保存配置

1. 确保所有变量都正确输入
2. 点击 **"Save"** 或变量会自动保存

---

## 🔧 步骤 4：配置部署设置

### 4.1 构建配置

Railway 通常会自动检测，但你可以手动配置：

1. 在项目设置中找到 **"Build"** 部分
2. 确保以下设置：
   ```
   Build Command: npm install
   Start Command: npm start
   ```

### 4.2 创建 railway.toml (可选)

在你的 `backend` 目录中创建 `railway.toml` 文件：

```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "npm start"
healthcheckPath = "/health"
healthcheckTimeout = 300
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

---

## 🚀 步骤 5：部署应用

### 5.1 触发部署

1. 配置完成后，Railway 会自动开始部署
2. 你可以在 **"Deployments"** 标签中看到部署进度
3. 部署过程通常需要 2-5 分钟

### 5.2 查看部署日志

1. 点击正在进行的部署
2. 可以看到实时日志输出
3. 确保没有错误信息

### 5.3 获取应用 URL

1. 部署成功后，在项目仪表板中
2. 点击 **"Settings"** → **"Domains"**
3. 会看到类似这样的 URL：`https://your-app-name.up.railway.app`
4. 这就是你的后端 API 地址！

---

## ✅ 步骤 6：测试部署结果

### 6.1 测试健康检查端点

```bash
# 替换为你的实际 Railway URL
curl https://your-app-name.up.railway.app/health
```

期望看到类似这样的响应：

```json
{
  "status": "OK",
  "timestamp": "2024-06-20T12:00:00.000Z",
  "service": "跑步追踪器后端服务"
}
```

### 6.2 测试注册接口

```bash
curl -X POST https://your-app-name.up.railway.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456",
    "username": "testuser"
  }'
```

### 6.3 测试登录接口

```bash
curl -X POST https://your-app-name.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456"
  }'
```

---

## 🔍 步骤 7：配置自定义域名（可选）

### 7.1 添加自定义域名

1. 在 Railway 项目中，进入 **"Settings"** → **"Domains"**
2. 点击 **"Custom Domain"**
3. 输入你的域名，如：`api.yourdomain.com`
4. Railway 会提供 CNAME 记录信息

### 7.2 配置 DNS

在你的域名管理面板中：

```
类型: CNAME
名称: api
值: your-app-name.up.railway.app
```

---

## 📊 步骤 8：监控和维护

### 8.1 查看应用指标

1. 在 Railway 仪表板中可以看到：
   - CPU 使用率
   - 内存使用量
   - 网络流量
   - 响应时间

### 8.2 查看日志

1. 点击 **"Logs"** 标签
2. 可以看到应用的实时日志
3. 用于调试问题

### 8.3 重新部署

当你的代码有更新时：

1. 推送代码到 GitHub：`git push origin main`
2. Railway 会自动检测到更改并重新部署
3. 也可以手动触发部署：点击 **"Deploy Latest"**

---

## 🛡️ 安全配置

### 9.1 更新 CORS 设置

更新你的后端 `server.js` 中的 CORS 配置：

```javascript
app.use(
  cors({
    origin: [
      "https://your-frontend-domain.vercel.app",
      "http://localhost:8080",
      "https://localhost:8080",
    ],
    credentials: true,
  })
);
```

### 9.2 生产环境密钥

确保在 Railway 中的 `JWT_SECRET` 是一个强密码：

```bash
# 生成一个随机密钥
openssl rand -base64 32
```

---

## 💰 费用说明

### Railway 免费额度

- **执行时间**：每月 500 小时
- **内存**：512MB RAM
- **存储**：1GB 持久化存储
- **带宽**：100GB 流量

### 升级选项

- **Pro Plan**: $5/月，更多资源和功能
- **按使用量计费**：超出免费额度后按实际使用付费

---

## ❗ 常见问题解决

### 问题 1：部署失败

**可能原因**：

- `package.json` 中缺少 `start` 脚本
- 环境变量配置错误
- Node.js 版本不兼容

**解决方案**：

```bash
# 检查 package.json
cat backend/package.json

# 确保有 start 脚本
"scripts": {
  "start": "node server.js",
  "dev": "nodemon server.js"
}
```

### 问题 2：数据库连接错误

**解决方案**：

1. 确保 `DATABASE_URL=file:./dev.db`
2. 在部署后运行数据库迁移：
   ```bash
   # 在 Railway 项目设置中添加构建命令
   npx prisma db push
   ```

### 问题 3：API 404 错误

**检查**：

1. URL 是否正确：`/api/auth/login` 而不是 `/auth/login`
2. 后端路由配置是否正确
3. 服务是否正常启动

### 问题 4：CORS 错误

**解决方案**：
更新 `server.js` 中的 CORS 配置，添加你的前端域名

---

## 🎉 完成！

恭喜！你已经成功将后端部署到 Railway.app。现在你有了：

✅ **免费的后端 API 服务**  
✅ **自动 HTTPS 证书**  
✅ **自动缩放**  
✅ **监控和日志**  
✅ **持续部署**（代码更新自动部署）

### 下一步：

1. **更新 Flutter 应用配置**：将 API URL 改为你的 Railway 域名
2. **部署前端**：使用 Vercel 或 Netlify 部署 Flutter Web 版本
3. **构建移动端**：使用新的 API URL 构建 Android/iOS 应用

**你的 Railway 后端地址**：`https://your-app-name.up.railway.app`

现在可以开始构建和测试你的完整应用了！🚀
