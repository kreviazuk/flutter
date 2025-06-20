# ⚡ 快速开始指南

## 🏃‍♂️ 5 分钟快速体验

### 1. 本地开发环境

```bash
# 1. 启动后端
cd backend && pnpm dev

# 2. 启动前端 (新终端)
flutter run -d chrome --web-port 8080
```

### 2. 打包移动端应用

```bash
# Android APK
./scripts/build-android.sh

# iOS (需要 macOS + Xcode)
./scripts/build-ios.sh
```

### 3. 部署到测试环境

#### 后端部署（选择一种）

**方案 A: VPS 服务器 (推荐)**

1. 购买 VPS 服务器（阿里云/腾讯云，约 ¥24/月）
2. 注册域名并解析到服务器 IP
3. 一键部署：
   ```bash
   ./scripts/deploy-vps.sh your_server_ip yourdomain.com
   ```
4. 获得域名：`https://yourdomain.com`

**方案 B: Railway**

1. 注册 [railway.app](https://railway.app)
2. 连接 GitHub 仓库
3. 部署后端服务
4. 获得域名：`https://your-app.up.railway.app`
5. ⚠️ 注意：部分地区可能无法访问

**方案 C: Render**

1. 注册 [render.com](https://render.com)
2. 创建 Web Service
3. 连接 GitHub 仓库
4. 获得域名：`https://your-app.onrender.com`

#### 前端部署

```bash
# 构建Web版本
flutter build web --release

# 上传到 Vercel/Netlify
# 或使用脚本
export TEST_API_URL=https://your-api.railway.app/api/auth
./scripts/deploy-test.sh
```

## 📱 测试安装

### Android 设备

1. 开启"开发者选项" → "USB 调试"
2. 安装生成的 APK：
   ```bash
   adb install build/running-tracker-test.apk
   ```
   或直接传输 APK 文件到手机安装

### iOS 设备

1. 使用 Xcode 打开项目
2. 连接 iPhone 并信任开发者证书
3. 点击运行按钮安装

## 🔧 常用命令

### 🌍 环境配置

通过 `ENV` 参数控制环境（类似 Vite 项目）：

| 环境         | ENV 值 | API 地址                                            |
| ------------ | ------ | --------------------------------------------------- |
| **开发环境** | `dev`  | `localhost:3000` (Web)<br>`10.0.2.2:3000` (Android) |
| **测试环境** | `test` | `http://104.225.147.57/api/auth` (VPS)              |
| **生产环境** | `prod` | `https://flutter-production-80de.up.railway.app`    |

```bash
# 🏠 开发环境 (默认 - 本地 API)
flutter run -d chrome --web-port 8080    # Web端
flutter run -d android                   # Android端
flutter run -d ios                       # iOS端

# 🧪 测试环境 (VPS API)
flutter run -d chrome --web-port 8080 --dart-define=ENV=test    # Web端
flutter run -d android --dart-define=ENV=test                   # Android端
# 或使用快捷脚本
./scripts/run-web-vps-test.sh                                   # Web测试
./scripts/run-android-vps-test.sh                               # Android测试

# 🚀 生产环境 (Railway API)
flutter run -d chrome --web-port 8080 --dart-define=ENV=prod    # Web端
flutter run --dart-define=ENV=prod                              # Android端

# 📦 打包
flutter build apk --release                                     # 开发环境 APK
flutter build apk --release --dart-define=ENV=prod              # 生产环境 APK
flutter build appbundle --release --dart-define=ENV=prod        # Android Bundle
flutter build ios --release --dart-define=ENV=prod             # iOS
flutter build web --release --dart-define=ENV=prod             # Web

# 🔧 后端
cd backend && pnpm dev                    # 开发模式
cd backend && pnpm start                 # 生产模式
cd backend && npx prisma studio          # 数据库管理
```

## 🚀 发布检查清单

### 开发完成

- [ ] 功能测试完成
- [ ] UI 界面调试完成
- [ ] API 接口调试完成
- [ ] 本地数据库正常

### 测试环境

- [ ] 后端部署成功 (Railway/Render)
- [ ] 前端部署成功 (Vercel/Netlify)
- [ ] 移动端 APK 测试正常
- [ ] Web 端功能测试正常

### 生产环境

- [ ] 购买域名并配置 DNS
- [ ] 配置 SSL 证书
- [ ] 数据库迁移到生产环境
- [ ] 配置监控和备份
- [ ] App Store / Google Play 发布

## 📞 问题排查

### 构建失败

```bash
flutter clean && flutter pub get
flutter doctor                    # 检查环境
flutter doctor --android-licenses # 接受Android协议
```

### API 连接失败

```bash
# 检查后端状态
curl https://your-api.com/health

# 检查跨域配置
# 确保后端CORS设置包含前端域名
```

### 部署失败

```bash
# 检查环境变量
echo $DATABASE_URL
echo $JWT_SECRET

# 重新部署
git push origin main  # 触发自动部署
```

## 🎯 推荐部署组合

### 🌟 VPS 自建方案 (推荐)

- **服务器**: 阿里云 ECS 1 核 2G (¥24/月)
- **域名**: .com 域名 (¥60/年)
- **SSL**: Let's Encrypt (免费)
- **总成本**: ¥29/月，¥348/年
- **优势**: 完全自主可控，稳定可靠

### 🆓 免费方案 (适合学习/测试)

- **后端**: Railway.app (免费额度，网络问题)
- **前端**: Vercel (免费)
- **数据库**: SQLite (内置)
- **域名**: 使用平台提供的子域名

### 💰 海外付费方案 (适合国际用户)

- **后端**: DigitalOcean VPS ($4/月)
- **前端**: Cloudflare Pages (免费) + CDN
- **数据库**: PostgreSQL (托管服务)
- **域名**: 自购域名 ($10/年)

选择适合你的方案开始吧！🚀
