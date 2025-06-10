# Flutter Demo 项目

这是一个完整配置的 Flutter 项目，包含了常用的插件和项目结构。

## 🚀 已安装的插件

### 网络请求
- **http**: ^1.1.0 - HTTP 客户端
- **dio**: ^5.4.0 - 强大的网络请求库

### 状态管理
- **provider**: ^6.1.1 - 简单的状态管理
- **riverpod**: ^2.4.9 - 高级状态管理
- **flutter_riverpod**: ^2.4.9 - Riverpod for Flutter

### 路由导航
- **go_router**: ^14.0.2 - 声明式路由

### 本地存储
- **shared_preferences**: ^2.2.2 - 轻量级键值存储
- **sqflite**: ^2.3.0 - SQLite 数据库

### UI 组件
- **flutter_screenutil**: ^5.9.0 - 屏幕适配

### 图片处理
- **cached_network_image**: ^3.3.0 - 网络图片缓存
- **image_picker**: ^1.0.4 - 图片选择器

### 工具类
- **intl**: ^0.19.0 - 国际化支持
- **uuid**: ^4.2.1 - UUID 生成
- **url_launcher**: ^6.2.2 - URL 启动器

### 动画
- **lottie**: ^3.0.0 - Lottie 动画

## 📁 项目结构

```
lib/
├── main.dart                    # 应用入口
├── screens/                     # 页面文件
│   └── home_screen.dart        # 主页面
├── providers/                   # 状态管理
│   └── counter_provider.dart   # 计数器状态
├── services/                    # 服务层
│   └── api_service.dart        # API 服务
├── utils/                       # 工具类
│   └── storage_utils.dart      # 存储工具
├── widgets/                     # 组件文件夹
└── models/                      # 数据模型文件夹
```

## 🛠️ 开始使用

### 1. 安装依赖
```bash
flutter pub get
```

### 2. 运行项目
```bash
# 运行在模拟器或设备上
flutter run

# 运行在Web浏览器
flutter run -d chrome
```

### 3. 构建项目
```bash
# 构建Android APK
flutter build apk

# 构建iOS (需要在macOS上)
flutter build ios

# 构建Web应用
flutter build web
```

## 📋 功能特性

✅ **响应式设计** - 使用 flutter_screenutil 进行屏幕适配  
✅ **状态管理** - 使用 Riverpod 进行现代化状态管理  
✅ **网络请求** - 配置好的 Dio HTTP 客户端  
✅ **本地存储** - SharedPreferences 工具类  
✅ **代码规范** - 通过 Flutter Lint 检查  
✅ **多平台支持** - 支持 Android、iOS、Web  

## 🎯 使用示例

### 状态管理示例
```dart
// 在 Provider 中
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

// 在 Widget 中使用
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Text('$counter');
  }
}
```

### 网络请求示例
```dart
// 使用 ApiService
final response = await ApiService().get('/posts/1');
```

### 本地存储示例
```dart
// 保存数据
await StorageUtils.setString('user_name', 'Flutter开发者');

// 读取数据
final userName = StorageUtils.getString('user_name');
```

## 📱 兼容性

- **Flutter**: ^3.8.1
- **Dart**: ^3.8.1
- **Android**: API 21+ (Android 5.0+)
- **iOS**: 11.0+
- **Web**: Chrome, Firefox, Safari, Edge

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

此项目使用 MIT 许可证。
