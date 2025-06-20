# 🚂 Railway 部署快速参考

## 📝 环境变量配置（复制粘贴）

```env
DATABASE_URL=file:./dev.db
JWT_SECRET=ecRST20gm5/RM7CEUQyFubzsgI15+43ocosfp06cQcY=
JWT_EXPIRES_IN=7d
NODE_ENV=production
PORT=3000
FRONTEND_URL=*
```

## 🎯 部署步骤（5 分钟搞定）

### 1️⃣ 访问 Railway

- 打开：https://railway.app
- 点击：**Login with GitHub**

### 2️⃣ 创建项目

- 点击：**New Project**
- 选择：**Deploy from GitHub repo**
- 选择仓库：`kreviazuk/flutter`

### 3️⃣ 配置根目录

- 在项目设置中设置：**Root Directory = backend**

### 4️⃣ 添加环境变量

- 进入：**Settings** → **Variables**
- 复制粘贴上面的环境变量

### 5️⃣ 等待部署

- 查看：**Deployments** 标签
- 获取 URL：**Settings** → **Domains**

## 🔗 测试 API

部署完成后，你的 API 地址类似：
`https://your-app-name.up.railway.app`

### 测试端点：

```bash
# 健康检查
curl https://your-app-name.up.railway.app/health

# 注册测试
curl -X POST https://your-app-name.up.railway.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456","username":"testuser"}'
```

## 💡 重要提示

1. **根目录设置**：必须设为 `backend`
2. **JWT 密钥**：已生成强随机密钥，直接使用
3. **自动部署**：代码推送到 GitHub 会自动重新部署
4. **免费额度**：500 小时/月，足够个人使用

## 🆘 常见问题

- **部署失败**：检查根目录是否设为 `backend`
- **404 错误**：API 路径是 `/api/auth/login` 不是 `/auth/login`
- **数据库错误**：确保 `DATABASE_URL=file:./dev.db`

---

⚡ **一键部署，马上开始！**
