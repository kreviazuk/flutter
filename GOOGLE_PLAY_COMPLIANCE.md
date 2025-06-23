# Google Play Store 合规功能

## 概述

为了通过 Google Play Store 审核，我们为 Running Tracker 应用添加了完整的法律信息和隐私合规功能。

## 新增功能

### 1. 用户协议页面 (Terms of Service)

- **文件位置**: `lib/presentation/screens/terms_screen.dart`
- **访问路径**: 设置 → 关于应用 → 用户协议
- **包含内容**: 用户账户、使用许可、隐私保护、禁止使用条款等

### 2. 隐私政策页面 (Privacy Policy)

- **文件位置**: `lib/presentation/screens/privacy_screen.dart`
- **访问路径**: 设置 → 关于应用 → 隐私政策
- **包含内容**: 数据收集、使用方式、安全措施、用户权利等

### 3. 关于应用页面 (About App)

- **文件位置**: `lib/presentation/screens/about_screen.dart`
- **访问路径**: 设置 → 关于应用
- **包含内容**: 应用信息、版本、开发者、联系方式、版权声明

### 4. 国际化支持

- 支持中英文双语
- 所有法律文档都有完整翻译
- 文件: `lib/l10n/app_en.arb`, `lib/l10n/app_zh.arb`

## 合规要点

✅ **数据收集透明度**: 明确说明收集的数据类型  
✅ **位置数据处理**: 详细说明位置数据的收集和使用  
✅ **用户权利**: 明确数据访问、更新、删除权利  
✅ **联系方式**: 提供技术支持和隐私咨询邮箱  
✅ **数据安全**: 说明数据保护措施  
✅ **第三方分享**: 明确不会向第三方出售数据

## 重要联系信息

- **技术支持**: support@runningtracker.app
- **隐私咨询**: privacy@runningtracker.app

## 注意事项

1. 发布前需要设置并激活上述邮箱地址
2. 确保所有联系方式都是有效的
3. 根据功能变化及时更新法律文档
4. 针对不同地区可能需要调整内容

这些功能确保了应用完全符合 Google Play Store 的合规要求。
