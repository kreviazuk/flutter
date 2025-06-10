# 托育机构管理系统 - Flutter版本

基于Flutter框架开发的托育机构管理系统，支持机构人员登录、学员管理、人员管理等功能。

## 🚀 功能特性

- **用户认证**：手机号验证码登录
- **学员管理**：婴幼儿信息管理
- **人员管理**：员工信息管理  
- **考勤管理**：签到签退管理
- **食谱管理**：营养餐单管理
- **健康管理**：体检晨检管理
- **活动管理**：机构活动管理

## 🛠️ 技术栈

- **框架**：Flutter 3.5.4+
- **状态管理**：Provider
- **网络请求**：Dio
- **本地存储**：SharedPreferences
- **UI组件**：Material Design 3

## 📱 后台接口

- **API地址**：https://gapitest.yban.co
- **登录方式**：手机号 + 验证码

## 🔧 开发环境配置

### 前置要求

- Flutter SDK 3.5.4+
- Dart SDK 3.0+
- Android Studio / VS Code
- iOS开发需要Xcode (macOS)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/kreviazuk/flutter.git
   cd flutter
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行项目**
   ```bash
   # Android
   flutter run
   
   # iOS (需要macOS)
   flutter run -d ios
   
   # Web
   flutter run -d web
   ```

## 📲 使用说明

### 登录测试

1. 启动应用后会显示登录页面
2. 输入任意11位手机号码
3. 点击"获取验证码"按钮
4. 输入验证码 `1234` (测试用)
5. 点击"登录"按钮

### 主要功能

- **首页**：显示系统功能模块
- **学员管理**：管理婴幼儿基本信息
- **人员管理**：管理机构员工信息
- **其他功能**：正在开发中...

## 🏗️ 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
├── providers/                # 状态管理
│   └── auth_provider.dart   # 认证状态管理
├── screens/                  # 页面
│   ├── home_screen.dart     # 主页
│   └── login_screen.dart    # 登录页
├── services/                 # 服务层
├── utils/                    # 工具类
└── widgets/                  # 公共组件
```

## 🔐 API集成

当前使用模拟数据进行测试，真实API集成需要：

1. 实现 `ApiClient` 类用于网络请求
2. 创建 `AuthService` 处理登录相关API
3. 定义数据模型类对应后台接口
4. 更新 `AuthProvider` 调用真实API

### 示例API调用

```dart
// 发送验证码
POST https://gapitest.yban.co/api/subdev/GovService/login/sendcode
{
  "phone": "手机号",
  "scope": "jiGou"
}

// 用户登录
POST https://gapitest.yban.co/api/subdev/GovService/login
{
  "phone": "手机号",
  "code": "验证码",
  "scope": "jiGou"
}
```

## 🎨 UI设计

- **设计风格**：Material Design 3
- **主题色**：蓝色 (#2196F3)
- **布局**：响应式设计
- **动画**：流畅的页面转场

## 🚧 开发计划

- [x] 用户登录功能
- [x] 主页UI设计
- [ ] 学员管理模块
- [ ] 人员管理模块
- [ ] 考勤管理模块
- [ ] 食谱管理模块
- [ ] 健康管理模块
- [ ] 活动管理模块
- [ ] 数据同步功能
- [ ] 离线缓存支持

## 📝 更新日志

### v1.0.0 (2024-01-XX)
- ✅ 项目初始化
- ✅ 登录功能实现
- ✅ 主页UI设计
- ✅ 状态管理配置
- ✅ 路由导航设置

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/新功能`)
3. 提交代码 (`git commit -am '添加新功能'`)
4. 推送分支 (`git push origin feature/新功能`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

如有问题或建议，请创建 Issue 或联系开发团队。
