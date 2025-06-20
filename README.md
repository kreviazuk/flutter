# 🏃‍♂️ Flutter 跑步追踪器

一个基于 Flutter 开发的跑步追踪应用，支持实时位置记录、运动数据统计和个人资料管理。

## 📱 支持平台

- ✅ **Android** (API Level 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **Web** (Chrome, Safari, Firefox)

## 🛠️ 技术栈

### 前端

- **Flutter** 3.0+ - 跨平台 UI 框架
- **Dart** - 编程语言
- **Google Maps** - 地图服务
- **Geolocator** - 位置服务
- **Image Picker** - 图片选择

### 后端

- **Node.js** + **Express** - 服务器框架
- **Prisma** + **SQLite** - 数据库 ORM
- **JWT** - 身份验证
- **Bcrypt** - 密码加密

## 🚀 快速开始

### 环境准备

1. **安装 Flutter SDK**

   ```bash
   # 下载并安装 Flutter
   # https://flutter.dev/docs/get-started/install
   flutter doctor
   ```

2. **安装依赖**

   ```bash
   # 前端依赖
   flutter pub get

   # 后端依赖
   cd backend
   pnpm install
   ```

3. **配置数据库**
   ```bash
   cd backend
   npx prisma db push
   ```

### 开发环境运行

1. **启动后端服务**

   ```bash
   cd backend
   pnpm dev
   ```

2. **启动前端应用**

   ```bash
   # Web端 (Chrome)
   flutter run -d chrome --web-port 8080

   # Android端
   flutter run -d android

   # iOS端 (需要macOS)
   flutter run -d ios
   ```

## 📦 应用打包

### Android 打包

#### 1. 调试版本 (APK)

```bash
# 构建调试APK
flutter build apk --debug

# 构建发布APK (未签名)
flutter build apk --release

# APK文件位置
# build/app/outputs/flutter-apk/app-release.apk
```

#### 2. 生产版本 (AAB - 推荐)

```bash
# 构建App Bundle (推荐用于Google Play)
flutter build appbundle --release

# AAB文件位置
# build/app/outputs/bundle/release/app-release.aab
```

#### 3. 签名配置 (生产环境)

```bash
# 1. 生成签名密钥
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. 配置 android/key.properties
storePassword=<密码>
keyPassword=<密钥密码>
keyAlias=upload
storeFile=<keystore文件路径>

# 3. 构建签名版本
flutter build appbundle --release
```

### iOS 打包

#### 1. 开发版本

```bash
# 构建iOS应用 (需要Xcode)
flutter build ios --debug

# 通过Xcode运行
open ios/Runner.xcworkspace
```

#### 2. 生产版本

```bash
# 构建发布版本
flutter build ios --release

# App Store发布步骤：
# 1. 在Xcode中打开项目
# 2. 选择 Product > Archive
# 3. 使用 Organizer 上传到 App Store Connect
```

#### 3. Ad-hoc 分发

```bash
# 构建Ad-hoc版本用于内测
flutter build ios --release --flavor adhoc
```

### Web 打包

```bash
# 构建Web版本
flutter build web --release

# 部署到静态服务器
# 构建文件位置: build/web/
```

## 🌍 部署指南

### 测试环境部署

#### 后端部署选项

1. **免费云服务 (推荐新手)**

   - [Railway](https://railway.app) - 简单快速
   - [Render](https://render.com) - 免费层
   - [Vercel](https://vercel.com) - Node.js 支持
   - [Heroku](https://heroku.com) - 老牌服务

2. **VPS 服务器**
   - [DigitalOcean](https://digitalocean.com) - $5/月
   - [Vultr](https://vultr.com) - $2.50/月
   - [Linode](https://linode.com) - $5/月

#### 前端部署选项

1. **静态站点托管**

   - [Vercel](https://vercel.com) - 免费
   - [Netlify](https://netlify.com) - 免费
   - [GitHub Pages](https://pages.github.com) - 免费

2. **CDN 服务**
   - [Cloudflare](https://cloudflare.com) - 免费 CDN

### 环境配置

#### 开发环境

```bash
ENV=development
API_BASE_URL=http://localhost:3000/api/auth
```

#### 测试环境

```bash
ENV=test
API_BASE_URL=https://your-test-api.railway.app/api/auth
```

#### 生产环境

```bash
ENV=production
API_BASE_URL=https://your-prod-api.com/api/auth
```

## 🔧 配置文件

### Flutter 环境变量

```bash
# 使用自定义API地址运行
flutter run --dart-define=API_BASE_URL=https://your-api.com/api/auth --dart-define=ENV=production
```

### 后端环境变量 (.env)

```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="7d"
PORT=3000
NODE_ENV="development"
FRONTEND_URL="http://localhost:8080"
```

## 📝 发布脚本

### 创建快速打包脚本

```bash
# scripts/build-android.sh
#!/bin/bash
echo "🔨 构建 Android 应用..."
flutter clean
flutter pub get
flutter build appbundle --release
echo "✅ Android 构建完成!"
echo "📦 文件位置: build/app/outputs/bundle/release/app-release.aab"

# scripts/build-ios.sh
#!/bin/bash
echo "🔨 构建 iOS 应用..."
flutter clean
flutter pub get
flutter build ios --release
echo "✅ iOS 构建完成!"
echo "📱 请使用 Xcode 打开 ios/Runner.xcworkspace 进行发布"
```

## 🚀 CI/CD 自动化

### GitHub Actions 示例

```yaml
# .github/workflows/build.yml
name: Build and Deploy
on:
  push:
    branches: [main]
jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build appbundle --release
```

## 📱 应用功能

- 🏃‍♂️ **实时跑步追踪** - GPS 位置记录
- 📊 **运动数据统计** - 距离、时间、配速
- 👤 **个人资料管理** - 头像、用户名、个人简介
- 🔐 **用户认证系统** - 注册、登录、JWT 认证
- 🗺️ **地图显示** - Google Maps 集成
- 📸 **头像上传** - 相册选择、拍照功能

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

_快乐跑步，记录每一步！_ 🎉
