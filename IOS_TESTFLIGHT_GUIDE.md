# iOS TestFlight 测试包发布指南

## 📋 前置要求

### 1. Apple Developer 账户

- 需要付费的 Apple Developer Program 账户 ($99/年)
- 登录 [Apple Developer](https://developer.apple.com)

### 2. 开发环境

- macOS 系统
- Xcode 15+ (从 App Store 安装)
- Flutter SDK (已安装)

### 3. 证书和配置文件

需要在 Apple Developer Console 创建：

- App ID
- 开发证书 (Development Certificate)
- 分发证书 (Distribution Certificate)
- Provisioning Profile

## 🔧 配置步骤

### 第 1 步：在 Apple Developer Console 创建 App

1. 登录 [Apple Developer Console](https://developer.apple.com/account/)
2. 进入 "Certificates, Identifiers & Profiles"
3. 创建新的 App ID：
   - Bundle ID: `com.runningtracker.app`
   - App Name: `Running Tracker`
   - 启用功能：Location Services, Background Modes

### 第 2 步：创建证书

#### 开发证书

```bash
# 生成证书签名请求 (CSR)
# 在 Keychain Access > Certificate Assistant > Request a Certificate From a Certificate Authority
```

#### 分发证书

- 在 Developer Console 创建 "iOS Distribution" 证书
- 下载并安装到 Keychain

### 第 3 步：创建 Provisioning Profile

- 类型：App Store Distribution
- App ID：选择刚创建的 Running Tracker
- 证书：选择分发证书
- 下载并双击安装

### 第 4 步：配置 Xcode 项目

打开 `ios/Runner.xcworkspace` (不是 .xcodeproj)：

```bash
open ios/Runner.xcworkspace
```

在 Xcode 中配置：

1. **General 标签页**：

   - Bundle Identifier: `com.runningtracker.app`
   - Version: `1.0.5`
   - Build: `6`
   - Deployment Target: `12.0`

2. **Signing & Capabilities**：
   - Team: 选择你的开发团队
   - Provisioning Profile: 选择刚创建的 profile
   - 添加 Capabilities：
     - Location (When In Use, Always)
     - Background Modes (Location updates)

## 🚀 构建和发布

### 第 1 步：清理和准备

```bash
# 清理项目
flutter clean
flutter pub get

# 更新 iOS 依赖
cd ios
pod install --repo-update
cd ..
```

### 第 2 步：构建 iOS 应用

```bash
# 构建 iOS release 版本
flutter build ios --release

# 或者直接构建 IPA
flutter build ipa --release
```

### 第 3 步：在 Xcode 中 Archive

1. 在 Xcode 中选择 "Any iOS Device (arm64)"
2. Product > Archive
3. 等待构建完成
4. 在 Organizer 中选择刚构建的 Archive
5. 点击 "Distribute App"

### 第 4 步：上传到 App Store Connect

1. 选择 "App Store Connect"
2. 选择 "Upload"
3. 选择正确的 Provisioning Profile
4. 点击 "Upload"

## 📱 TestFlight 配置

### 第 1 步：在 App Store Connect 创建应用

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 点击 "My Apps" > "+" > "New App"
3. 填写信息：
   - Platform: iOS
   - Name: Running Tracker
   - Primary Language: Chinese (Simplified)
   - Bundle ID: com.runningtracker.app
   - SKU: running-tracker-ios

### 第 2 步：配置应用信息

#### App Information

- Name: Running Tracker
- Subtitle: 专业跑步路线追踪应用
- Category: Health & Fitness
- Content Rights: No

#### Pricing and Availability

- Price: Free
- Availability: All countries

### 第 3 步：准备测试版本

#### Build 信息

- 上传构建版本后，在 TestFlight 标签页可以看到
- 添加测试信息：
  - What to Test: 新增实时 GPS 速度计算功能
  - Test Details: 测试 GPS 精度和速度计算准确性

#### 测试用户

1. **内部测试**：

   - 添加团队成员邮箱
   - 自动获得测试权限

2. **外部测试**：
   - 创建测试组
   - 添加外部测试用户邮箱
   - 需要 Apple 审核 (通常 24-48 小时)

## 📋 测试清单

### 功能测试

- [ ] GPS 定位准确性
- [ ] 实时速度计算
- [ ] 地图显示和 3D 模式
- [ ] 跑步数据记录
- [ ] 路径图片保存
- [ ] 多语言切换

### 性能测试

- [ ] 应用启动时间
- [ ] 内存使用情况
- [ ] 电池消耗
- [ ] 长时间运行稳定性

### 兼容性测试

- [ ] iPhone 不同型号
- [ ] iOS 不同版本 (12.0+)
- [ ] 不同屏幕尺寸

## 🔍 常见问题

### 构建失败

```bash
# 清理 iOS 缓存
flutter clean
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter build ios --release
```

### 签名问题

- 确保证书和 Provisioning Profile 匹配
- 检查 Bundle ID 是否一致
- 确保证书未过期

### 上传失败

- 检查网络连接
- 确保使用正确的 Apple ID
- 验证应用版本号是否递增

## 📧 测试邀请

### 发送测试邀请

1. 在 TestFlight 中选择构建版本
2. 添加测试用户邮箱
3. 用户会收到邮件邀请
4. 用户安装 TestFlight 应用
5. 通过邮件链接安装测试版本

### 测试用户指南

```
1. 在 iPhone 上安装 TestFlight 应用
2. 点击邮件中的邀请链接
3. 在 TestFlight 中安装 Running Tracker
4. 测试应用功能并提供反馈
```

## 🚀 发布到 App Store

测试完成后，可以提交正式版本：

1. 在 App Store Connect 创建新版本
2. 填写版本信息和截图
3. 选择构建版本
4. 提交审核
5. 等待 Apple 审核 (通常 1-7 天)

---

**注意**: iOS 发布需要 macOS 环境和 Apple Developer 账户。如果没有 Mac，可以考虑使用云端 macOS 服务或请有 Mac 的开发者协助。
