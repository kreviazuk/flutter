# 🏃‍♂️ 跑步路线记录 App - 项目结构建议

## 📁 推荐的文件夹结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用配置
│
├── core/                        # 核心功能
│   ├── constants/
│   │   ├── app_constants.dart   # 应用常量
│   │   ├── colors.dart          # 颜色定义
│   │   └── routes.dart          # 路由定义
│   ├── utils/
│   │   ├── location_utils.dart  # 位置工具类
│   │   ├── calculation_utils.dart # 数学计算工具
│   │   └── formatter_utils.dart # 格式化工具
│   └── services/
│       ├── location_service.dart # 定位服务
│       ├── database_service.dart # 数据库服务
│       ├── permission_service.dart # 权限服务
│       └── background_service.dart # 后台服务
│
├── data/                        # 数据层
│   ├── models/
│   │   ├── run_record.dart      # 跑步记录模型
│   │   ├── route_point.dart     # 路线点位模型
│   │   ├── user_profile.dart    # 用户资料模型
│   │   └── achievement.dart     # 成就模型
│   ├── repositories/
│   │   ├── run_repository.dart  # 跑步数据仓库
│   │   └── user_repository.dart # 用户数据仓库
│   └── database/
│       ├── app_database.dart    # 数据库配置
│       └── dao/
│           ├── run_dao.dart     # 跑步数据访问
│           └── user_dao.dart    # 用户数据访问
│
├── presentation/                # 表现层
│   ├── providers/
│   │   ├── run_provider.dart    # 跑步状态管理
│   │   ├── map_provider.dart    # 地图状态管理
│   │   ├── user_provider.dart   # 用户状态管理
│   │   └── settings_provider.dart # 设置状态管理
│   │
│   ├── screens/
│   │   ├── splash/              # 启动页
│   │   ├── auth/                # 登录注册
│   │   ├── home/                # 主页
│   │   ├── running/             # 跑步页面
│   │   │   ├── running_screen.dart
│   │   │   ├── map_widget.dart
│   │   │   └── stats_widget.dart
│   │   ├── history/             # 历史记录
│   │   ├── profile/             # 个人资料
│   │   └── settings/            # 设置页面
│   │
│   ├── widgets/                 # 通用组件
│   │   ├── common/
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── loading_widget.dart
│   │   │   └── error_widget.dart
│   │   ├── charts/
│   │   │   ├── distance_chart.dart
│   │   │   ├── pace_chart.dart
│   │   │   └── elevation_chart.dart
│   │   └── cards/
│   │       ├── run_summary_card.dart
│   │       ├── achievement_card.dart
│   │       └── stats_card.dart
│   │
│   └── theme/
│       ├── app_theme.dart       # 主题配置
│       ├── colors.dart          # 颜色主题
│       └── text_styles.dart     # 文字样式
│
└── features/                    # 功能模块（可选的模块化方式）
    ├── running/
    ├── history/
    ├── social/
    └── achievements/
```

## 🎨 UI 设计建议

### 主要页面

1. **启动页** - Logo 动画 + 权限请求
2. **主页** - 今日统计 + 快速开始跑步
3. **跑步页** - 地图 + 实时数据 + 控制按钮
4. **历史页** - 跑步记录列表 + 筛选
5. **统计页** - 图表分析 + 成就展示
6. **设置页** - 个人信息 + 应用设置

### 配色方案

```dart
// 建议配色
const Color primaryColor = Color(0xFF2196F3);    // 运动蓝
const Color accentColor = Color(0xFF4CAF50);     // 成功绿
const Color warningColor = Color(0xFFFF9800);    // 警告橙
const Color errorColor = Color(0xFFF44336);      // 错误红
const Color backgroundColor = Color(0xFFF5F5F5);  // 背景灰
```

## 📊 数据模型设计

### 核心数据表

1. **runs** - 跑步记录主表
2. **route_points** - 路线点位详情
3. **user_settings** - 用户设置
4. **achievements** - 成就记录

## 🚀 开发优先级

### Phase 1 (MVP)

- ✅ 基础 GPS 跟踪
- ✅ 地图显示
- ✅ 基础数据记录
- ✅ 本地存储

### Phase 2 (完善功能)

- ✅ 历史记录查看
- ✅ 数据图表
- ✅ 设置页面
- ✅ 权限管理

### Phase 3 (高级功能)

- ✅ 社交分享
- ✅ 训练计划
- ✅ 音乐播放
- ✅ 云端同步

## 🔧 技术难点解决

### 1. GPS 精度优化

```dart
LocationSettings locationSettings = const LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 5, // 5米更新一次
);
```

### 2. 后台运行

```dart
// 使用 flutter_background_service
await FlutterBackgroundService.initialize(onStart);
```

### 3. 电池优化

- 智能定位频率调整
- 暂停时停止 GPS
- 使用低功耗传感器

### 4. 权限处理

```dart
// 位置权限检查
if (await Permission.location.isGranted) {
  // 开始定位
}
```
