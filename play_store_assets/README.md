# Play Store 素材文件夹

这个文件夹包含了上架 Google Play Store 所需的所有素材。

## 📁 目录结构

```
play_store_assets/
├── icons/                          # 应用图标
│   └── app_icon_512x512.png       # 👈 请放置512x512的应用图标
├── screenshots/
│   ├── phone/                      # 手机截图
│   │   ├── screenshot_1_home.png  # 👈 主页截图
│   │   ├── screenshot_2_map.png   # 👈 地图页面截图
│   │   └── ...                    # 👈 更多功能截图
│   └── tablet/                     # 平板截图 (可选)
├── graphics/
│   └── feature_graphic_1024x500.png # 👈 置顶预览大图
└── descriptions/
    ├── app_descriptions.md         # 应用商店描述文本
    └── asset_preparation_guide.md  # 素材准备指南
```

## 🎯 需要你准备的文件

### 必需文件 (3 个):

1. **icons/app_icon_512x512.png** - 应用图标
2. **graphics/feature_graphic_1024x500.png** - 置顶预览大图
3. **screenshots/phone/** - 至少 2 张应用截图

### 获取截图的最简单方法:

```bash
# 1. 启动Web版应用
flutter run -d chrome --web-port 8080

# 2. 在Chrome中按F12，切换到手机模式，截图保存到 screenshots/phone/
```

## 📤 使用方法

1. 将准备好的素材放入对应文件夹
2. 登录 Google Play Console
3. 进入"商店设置" > "主要商品详情"
4. 手动上传这些素材文件

## ❓ 需要帮助?

查看 `asset_preparation_guide.md` 获取详细的制作指南。
