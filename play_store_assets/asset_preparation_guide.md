# Google Play 素材准备指南

## 📁 本地文件组织结构

```
my_flutter_app/
├── play_store_assets/
│   ├── icons/
│   │   ├── app_icon_512x512.png          # 应用图标 (必需)
│   │   └── app_icon_adaptive.png         # 自适应图标 (可选)
│   ├── screenshots/
│   │   ├── phone/
│   │   │   ├── screenshot_1_home.png     # 主页截图
│   │   │   ├── screenshot_2_map.png      # 地图页面截图
│   │   │   ├── screenshot_3_profile.png  # 个人资料截图
│   │   │   └── screenshot_4_settings.png # 设置页面截图
│   │   └── tablet/ (可选)
│   │       ├── tablet_7inch_1.png
│   │       └── tablet_10inch_1.png
│   ├── graphics/
│   │   ├── feature_graphic_1024x500.png  # 置顶预览大图 (必需)
│   │   └── promo_video_thumbnail.png     # 宣传视频缩略图 (可选)
│   └── descriptions/
│       ├── app_descriptions.md           # 应用描述文本
│       └── release_notes.md              # 版本说明
```

## 🎨 素材规格要求

### 1. 应用图标 (必需)

- **文件名**: `app_icon_512x512.png`
- **尺寸**: 512 x 512 像素
- **格式**: PNG (24-bit, 无 Alpha 通道)
- **要求**:
  - 不能有圆角 (Google Play 会自动处理)
  - 背景不能透明
  - 必须是正方形
  - 设计简洁明了，在小尺寸下清晰可见

### 2. 置顶预览大图 (必需)

- **文件名**: `feature_graphic_1024x500.png`
- **尺寸**: 1024 x 500 像素
- **格式**: PNG 或 JPG (24-bit)
- **要求**:
  - 展示应用的核心功能
  - 可以包含文字说明
  - 视觉效果吸引用户

### 3. 手机截图 (必需)

- **数量**: 至少 2 张，最多 8 张
- **尺寸**: 建议 1080 x 1920 像素 (9:16 比例)
- **格式**: PNG 或 JPG (24-bit)
- **要求**:
  - 展示应用的主要功能页面
  - 截图需要是真实的应用界面
  - 可以添加简单的文字说明

## 📱 如何获取应用截图

### 方法 1: 使用模拟器截图

```bash
# 启动Android模拟器
flutter run -d emulator

# 在模拟器中截图 (Cmd+S 或工具栏截图按钮)
# 截图会保存到桌面
```

### 方法 2: 使用真机截图

```bash
# 连接Android手机，启用开发者模式
flutter run -d <device_id>

# 使用手机截图功能 (通常是音量下键+电源键)
# 或使用 adb 命令截图:
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./play_store_assets/screenshots/phone/
```

### 方法 3: 使用 Chrome DevTools (Web 版)

```bash
# 启动Web版本
flutter run -d chrome --web-port 8080

# 在Chrome中:
# 1. 按F12打开DevTools
# 2. 点击手机图标进入移动模式
# 3. 选择手机尺寸 (iPhone X: 375x812)
# 4. 右键页面 -> "截图" 或使用快捷键截图
```

## 🛠️ 制作工具推荐

### 图标制作:

- **Figma** (免费, 在线): https://figma.com
- **Canva** (部分免费): https://canva.com
- **Adobe Illustrator** (付费)
- **Sketch** (Mac, 付费)

### 截图编辑:

- **Preview** (Mac 自带)
- **GIMP** (免费): https://gimp.org
- **Photoshop** (付费)
- **在线工具**: https://photopea.com (免费 Photoshop 替代)

## 📤 上传到 Google Play Console

### 上传位置:

1. 登录 **Google Play Console**: https://play.google.com/console
2. 选择你的应用
3. 进入 **"商店设置"** > **"主要商品详情"**
4. 在对应区域上传素材:
   - **应用图标**: "应用图标"区域
   - **置顶预览大图**: "置顶预览大图"区域
   - **手机截图**: "截图"区域的"手机"选项卡
   - **平板截图**: "截图"区域的"7 英寸平板"/"10 英寸平板"选项卡

### 注意事项:

- 所有素材都是在**Google Play Console 网页端**手动上传
- **不需要**将这些素材打包到 APK/AAB 文件中
- 上传后可以预览效果
- 保存更改后才会生效

## ✅ 素材检查清单

上传前请确认:

- [ ] 应用图标: 512x512px, PNG 格式, 无透明背景
- [ ] 置顶预览大图: 1024x500px, 展示应用核心功能
- [ ] 手机截图: 至少 2 张, 1080x1920px, 展示主要页面
- [ ] 所有图片清晰, 无模糊或失真
- [ ] 截图内容真实反映应用功能
- [ ] 文字内容与目标市场语言一致

## 🚀 快速开始

1. **运行应用获取截图**:

   ```bash
   flutter run -d chrome --web-port 8080
   # 或
   flutter run -d emulator
   ```

2. **将截图保存到**:

   ```
   play_store_assets/screenshots/phone/
   ```

3. **制作应用图标**, 保存为:

   ```
   play_store_assets/icons/app_icon_512x512.png
   ```

4. **制作预览大图**, 保存为:
   ```
   play_store_assets/graphics/feature_graphic_1024x500.png
   ```

准备好素材后，就可以在 Google Play Console 中上传了！
