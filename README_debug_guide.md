# 🐛 Android 调试指南

## Android Studio Logcat 配置

### 1. 基本过滤设置

```
标签过滤: flutter
包名过滤: com.example.running_tracker
```

### 2. 高级过滤器

在 Logcat 窗口的搜索框中使用这些过滤器：

#### 查看所有 Flutter 日志

```
tag:flutter
```

#### 查看错误和警告

```
tag:flutter level:warn
```

#### 查看特定功能的日志

```
tag:flutter 登录
```

#### 查看堆栈追踪

```
tag:flutter Stack
```

### 3. 自定义过滤器创建步骤

1. **打开 Logcat 窗口** (View → Tool Windows → Logcat)
2. **点击过滤器下拉菜单** (默认显示 "No Filters")
3. **选择 "Create New Filter"**
4. **配置过滤器**:
   - Filter Name: `Flutter Debug`
   - Log Tag: `flutter`
   - Package Name: `com.example.running_tracker`
   - Log Level: `Debug`

### 4. 关键日志搜索词

#### 错误相关

- `❌` - 错误标记
- `Exception` - 异常信息
- `Error` - 错误信息
- `Failed` - 失败信息

#### 网络请求

- `--- 登录请求` - 登录请求日志
- `--- 登录响应` - 登录响应日志
- `🌐 创建HTTP客户端` - HTTP 客户端创建

#### 用户数据处理

- `🔍 User.fromJson` - 用户数据解析
- `🔍 检查响应数据结构` - 响应数据检查

## 错误定位技巧

### 1. 堆栈追踪阅读

当看到错误时，查找类似这样的堆栈信息：

```
#0      User.fromJson (package:running_tracker/data/models/user.dart:25:7)
#1      AuthService.login (package:running_tracker/core/services/auth_service.dart:156:23)
#2      _AuthScreenState._handleLogin (package:running_tracker/presentation/screens/auth_screen.dart:89:12)
```

这表示错误发生在：

- 文件: `user.dart`
- 行数: `25`
- 方法: `User.fromJson`

### 2. 错误分类

#### Type 'Null' is not a subtype of type 'String'

- **位置**: 通常在数据模型的 fromJson 方法中
- **原因**: 服务器返回的字段为 null，但模型期望 String
- **解决**: 检查服务器返回数据和 null 处理

#### JSON 解析错误

- **位置**: HTTP 响应处理
- **原因**: 服务器返回的不是有效 JSON
- **解决**: 检查响应体内容

#### 网络连接错误

- **位置**: HTTP 请求发送
- **原因**: 网络配置或服务器问题
- **解决**: 检查 URL 和网络设置

## 实用 Logcat 命令

### 在终端中查看日志 (可选)

```bash
# 查看Flutter日志
adb logcat -s flutter

# 查看特定包的日志
adb logcat | grep com.example.running_tracker

# 清除日志后重新开始
adb logcat -c && adb logcat -s flutter
```

## 完整调试流程

### 第一步：重现错误

1. 清除 Logcat (点击 🗑️ 按钮)
2. 执行引发错误的操作 (如登录)
3. 立即查看 Logcat 输出

### 第二步：定位错误

1. 搜索 `❌` 或 `Exception`
2. 查看完整的堆栈追踪
3. 找到第一个项目代码文件和行数

### 第三步：分析错误

1. 查看错误前的相关日志
2. 检查网络请求和响应
3. 验证数据处理逻辑

### 第四步：验证修复

1. 重新运行应用
2. 重复错误操作
3. 确认日志中显示成功信息

## 常见错误模式

### 1. 登录错误流程

```
=== 登录请求开始 [ID: xxxxx] ===
--- 登录请求 [ID: xxxxx] ---
--- 登录响应 [ID: xxxxx] ---
✅ JSON解析成功 [ID: xxxxx]
🔍 检查响应数据结构 [ID: xxxxx]
🔍 User.fromJson - 输入数据: {...}
❌ User.fromJson 失败        ← 错误发生在这里
```

### 2. 查看具体错误

找到错误后，查看详细信息：

```
❌ User.fromJson 失败
错误: ArgumentError: User id不能为null
输入数据: {email: test@test.com, username: test, ...}
堆栈追踪:
#0      User.fromJson (package:running_tracker/data/models/user.dart:25:7)
...
```

这样您就能准确知道：

- **错误类型**: User id 不能为 null
- **错误位置**: user.dart 第 25 行
- **输入数据**: 具体的 JSON 数据
