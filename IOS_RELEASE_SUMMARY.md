# 🍎 iOS TestFlight 发布总结

## 当前状态

- ✅ macOS 环境 (12.7.5)
- ✅ Flutter 3.32.2 已安装
- ✅ 项目配置已更新
- ❌ 需要安装完整的 Xcode
- ❌ 需要安装 CocoaPods

## 📋 必需步骤

### 1. 安装开发工具

```bash
# 1. 从 App Store 安装 Xcode (约 10GB)
# 2. 安装 CocoaPods
sudo gem install cocoapods

# 3. 配置 Xcode 命令行工具
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept

# 4. 运行设置脚本
./setup_ios_dev.sh
```

### 2. Apple Developer 账户设置

1. **注册 Apple Developer Program** ($99/年)
   - 访问: https://developer.apple.com/programs/
2. **创建 App ID**

   - Bundle ID: `com.runningtracker.app`
   - 启用功能: Location Services, Background Modes

3. **创建证书**

   - Development Certificate (开发)
   - Distribution Certificate (分发)

4. **创建 Provisioning Profile**
   - App Store Distribution Profile

### 3. App Store Connect 设置

1. **创建应用**

   - 登录: https://appstoreconnect.apple.com
   - 应用名称: Running Tracker
   - Bundle ID: com.runningtracker.app
   - 主要语言: 中文(简体)

2. **配置应用信息**
   - 类别: 健康健美
   - 价格: 免费
   - 可用性: 全球

### 4. 构建和上传

```bash
# 1. 清理项目
flutter clean
flutter pub get

# 2. 更新 iOS 依赖
cd ios
pod install --repo-update
cd ..

# 3. 构建 iOS 应用
flutter build ios --release

# 4. 在 Xcode 中 Archive
open ios/Runner.xcworkspace
# 然后在 Xcode 中: Product > Archive > Distribute App
```

### 5. TestFlight 配置

1. **等待处理**

   - 上传后等待 Apple 处理 (5-30 分钟)

2. **添加测试信息**

   - 测试内容: 实时 GPS 速度计算功能
   - 测试说明: 验证 GPS 精度和速度计算准确性

3. **邀请测试用户**
   - 内部测试: 团队成员 (立即可用)
   - 外部测试: 外部用户 (需要审核 24-48 小时)

## 🛠️ 项目配置更新

### Info.plist 权限

已添加以下权限:

- 位置权限 (NSLocationWhenInUseUsageDescription)
- 相机权限 (NSCameraUsageDescription)
- 相册权限 (NSPhotoLibraryUsageDescription)
- 运动权限 (NSMotionUsageDescription)
- 后台模式 (UIBackgroundModes)

### 应用信息

- 显示名称: Running Tracker
- Bundle Name: running_tracker
- 版本: 1.0.5 (6)

## 📱 测试重点

### 核心功能

- [ ] GPS 定位和权限请求
- [ ] 实时速度计算准确性
- [ ] 3D 地图显示和交互
- [ ] 跑步数据记录和统计
- [ ] 路径图片保存和分享
- [ ] 多语言界面切换

### 性能测试

- [ ] 应用启动速度
- [ ] 内存使用优化
- [ ] 电池消耗控制
- [ ] 长时间运行稳定性

### 兼容性

- [ ] iPhone 不同机型 (iPhone 8+)
- [ ] iOS 版本兼容 (iOS 12.0+)
- [ ] 不同屏幕尺寸适配

## 🚀 快速开始

如果你已经有 Apple Developer 账户和 Xcode:

```bash
# 1. 安装依赖
./setup_ios_dev.sh

# 2. 构建测试包
./build_ios_testflight.sh

# 3. 按照 Xcode 中的提示完成签名和上传
```

## 📞 支持资源

### 官方文档

- [Flutter iOS 部署](https://docs.flutter.dev/deployment/ios)
- [Apple Developer 指南](https://developer.apple.com/ios/)
- [TestFlight 用户指南](https://developer.apple.com/testflight/)

### 常见问题

- **签名错误**: 检查证书和 Provisioning Profile 匹配
- **上传失败**: 确保网络稳定，版本号递增
- **权限问题**: 确保 Info.plist 中权限描述完整

## 📈 发布时间线

1. **准备阶段** (1-2 天)

   - 安装开发工具
   - 注册 Apple Developer
   - 配置证书和 Profile

2. **构建阶段** (1 天)

   - 项目配置
   - 构建和上传

3. **测试阶段** (3-7 天)

   - TestFlight 内部测试
   - 外部测试审核和反馈

4. **发布阶段** (1-7 天)
   - 提交 App Store 审核
   - 正式发布

---

**总预计时间**: 1-2 周 (包括审核时间)

**成本**: $99 Apple Developer Program 年费
