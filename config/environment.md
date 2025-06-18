# 环境配置说明

这个配置系统类似于 Vite 项目中的`.env`文件，支持多环境管理和环境变量覆盖。

## 🎯 快速开始

### 开发环境

```bash
# 方法1: 使用脚本 (推荐)
./scripts/run_dev.sh

# 方法2: 手动启动
flutter run --dart-define=ENV=development
```

### 生产环境构建

```bash
# 使用脚本构建
./scripts/run_prod.sh

# 手动构建
flutter build apk --release --dart-define=ENV=production
```

## 📁 配置文件位置

- 主配置文件: `lib/core/constants/app_config.dart`
- 环境说明: `config/environment.md`
- 开发脚本: `scripts/run_dev.sh`
- 生产脚本: `scripts/run_prod.sh`

## 🌍 支持的环境

### 🔧 开发环境 (development)

- **Web 端**: `http://localhost:3001/api/auth`
- **移动端**: `http://localhost:3001/api/auth` (统一使用 localhost)
- **代理**: 启用 (`192.168.8.119:9090`)

### 🚀 生产环境 (production)

- **API**: `https://your-production-api.com/api/auth`
- **代理**: 禁用

### 🧪 测试环境 (test)

- **API**: `https://your-test-api.com/api/auth`
- **代理**: 可选

## ⚙️ 环境变量支持

### 基本用法

```bash
# 设置环境
flutter run --dart-define=ENV=development

# 覆盖API URL
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3001/api/auth

# 设置代理
flutter run --dart-define=PROXY_HOST=192.168.1.100 --dart-define=PROXY_PORT=8888

# 强制启用代理
flutter run --dart-define=FORCE_PROXY=true
```

### 支持的环境变量

| 变量名         | 类型   | 默认值          | 说明         |
| -------------- | ------ | --------------- | ------------ |
| `ENV`          | String | `development`   | 环境名称     |
| `API_BASE_URL` | String | (自动选择)      | API 基础 URL |
| `PROXY_HOST`   | String | `192.168.8.119` | 代理主机     |
| `PROXY_PORT`   | int    | `9090`          | 代理端口     |
| `FORCE_PROXY`  | bool   | `false`         | 强制启用代理 |

## 📋 配置项说明

### 自动平台适配

- **Web 平台**: 自动使用 `localhost`
- **Android 模拟器**: 自动使用 `localhost` (已统一)
- **iOS 模拟器**: 自动使用 `localhost`
- **真机**: 需要手动设置实际 IP 地址

### 代理配置

- **开发模式**: 自动启用 (仅移动端)
- **生产模式**: 自动禁用
- **可覆盖**: 通过 `FORCE_PROXY=true` 强制启用

## 🔍 配置检查

### 启动时自动打印

应用启动时会自动显示当前配置：

```
🔧 ==================== App Config ====================
Environment: development
API Base URL: http://10.0.2.2:3001/api/auth
Proxy Enabled: true
Proxy: 192.168.8.119:9090
Platform: Mobile
Debug Mode: true
=====================================================
```

### 代码中获取配置

```dart
import 'package:your_app/core/constants/app_config.dart';

// 获取当前环境
String env = AppConfig.environmentName;

// 获取API URL
String apiUrl = AppConfig.apiBaseUrl;

// 检查环境
bool isDev = AppConfig.isDevelopment;
bool isProd = AppConfig.isProduction;

// 获取所有配置
Map<String, dynamic> config = AppConfig.toMap();
```

## 🛠️ 开发工具

### 快速脚本

```bash
# 开发环境 (启动后端+前端)
./scripts/run_dev.sh

# 生产环境构建
./scripts/run_prod.sh
```

### 不同平台启动

```bash
# Android模拟器
flutter run -d android --dart-define=ENV=development

# Web浏览器
flutter run -d chrome --web-port 8080 --dart-define=ENV=development

# iOS模拟器 (需要macOS)
flutter run -d ios --dart-define=ENV=development
```

## 🚨 注意事项

1. **网络连接**: 确保后端服务在正确端口运行
2. **代理调试**: Proxyman 需要监听正确的 IP 和端口
3. **模拟器 vs 真机**: 使用不同的 IP 地址配置
4. **环境切换**: 重新启动应用以应用新配置
5. **生产部署**: 记得更新生产环境的 API URL

## 📝 示例配置

### 本地开发 (推荐)

```bash
flutter run --dart-define=ENV=development
```

### 团队开发 (自定义后端地址)

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3001/api/auth
```

### 真机调试 (需要实际 IP)

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.8.119:3001/api/auth
```

### CI/CD 构建

```bash
flutter build apk --release --dart-define=ENV=production --dart-define=API_BASE_URL=https://api.yourapp.com/api/auth
```
