# Google Play Console 上传流程指南

## 📋 准备工作检查清单

### ✅ 已完成 (假设你已准备好)

- [x] AAB 文件: `build/app/outputs/bundle/release/app-release.aab` (42MB)
- [x] 应用图标: `play_store_assets/icons/app_icon_512x512.png`
- [x] 置顶预览大图: `play_store_assets/graphics/feature_graphic_1024x500.png`
- [x] 手机截图: `play_store_assets/screenshots/phone/` (至少 2 张)
- [x] 应用描述: `play_store_assets/app_descriptions.md`

### 🔧 需要设置的服务

- [ ] Google Play 开发者账号 ($25 一次性费用)
- [ ] 邮箱服务: support@lawrencezhouda.xyz
- [ ] 邮箱服务: privacy@lawrencezhouda.xyz

## 🎯 第一步: 注册 Google Play 开发者账号

### 1. 访问注册页面

```
网址: https://play.google.com/console/signup
```

### 2. 账号类型选择

**推荐选择: 个人开发者**

- 费用: $25 (一次性)
- 审核时间: 1-3 天
- 所需信息: 个人身份证明

**如果需要组织账号:**

- 费用: $25 (一次性)
- 审核时间: 7-14 天
- 所需信息: 营业执照等企业信息

### 3. 填写开发者信息

```
- 开发者名称: Lawrence Zhou (或你的真实姓名)
- 联系邮箱: 你的Gmail账号
- 电话号码: 你的真实手机号
- 地址信息: 你的真实地址
```

### 4. 支付注册费

- 使用信用卡或 PayPal 支付$25
- 支付成功后等待账号审核

## 🎯 第二步: 创建应用

### 1. 登录 Google Play Console

```
网址: https://play.google.com/console
```

### 2. 创建新应用

- 点击 **"创建应用"**
- 应用名称: `Running Tracker`
- 默认语言: `英语 (美国)` 或 `中文 (中国)`
- 应用类型: `应用`
- 免费或付费: `免费`

### 3. 填写应用基本信息

- 简短描述: `Professional GPS running tracker with route recording and real-time tracking`
- 完整描述: 使用 `app_descriptions.md` 中的内容

## 🎯 第三步: 上传 AAB 文件

### 1. 进入版本管理

- 左侧菜单: **"发布"** > **"生产"**
- 点击 **"创建新版本"**

### 2. 上传应用包

- 点击 **"上传"** 按钮
- 选择文件: `build/app/outputs/bundle/release/app-release.aab`
- 等待上传完成 (约 2-5 分钟)

### 3. 填写版本信息

```
版本名称: 1.0.0
版本说明:
🎉 Running Tracker 首次发布！

✨ 功能特色:
• GPS路线追踪
• 实时地图显示
• 用户账户系统
• 中英文双语支持
• 美观的用户界面

开始你的跑步之旅吧！
```

## 🎯 第四步: 配置商店信息

### 1. 商店设置 > 主要商品详情

#### 应用详情:

- **应用名称**: Running Tracker
- **简短描述**: Professional GPS running tracker with route recording and real-time tracking
- **完整描述**: (复制 `app_descriptions.md` 中的完整描述)

#### 图形资产:

- **应用图标**: 上传 `play_store_assets/icons/app_icon_512x512.png`
- **置顶预览大图**: 上传 `play_store_assets/graphics/feature_graphic_1024x500.png`

#### 截图:

- **手机**: 上传 `play_store_assets/screenshots/phone/` 中的所有截图
- **平板** (可选): 如果有平板截图也可上传

#### 分类:

- **应用类别**: 健康与健身
- **标签**: running, fitness, GPS, tracker

### 2. 商店设置 > 商店展示信息

#### 联系方式:

- **邮箱**: support@lawrencezhouda.xyz
- **网站**: https://lawrencezhouda.xyz (可选)
- **电话**: (可选)

## 🎯 第五步: 配置应用内容

### 1. 政策 > 应用内容

#### 隐私政策:

- **隐私政策 URL**: https://lawrencezhouda.xyz/privacy
- 或者: 说明隐私政策已内置在应用中

#### 应用访问权限:

- 检查是否需要提供测试账号
- 如果应用有登录功能，可能需要提供测试账号

#### 内容分级:

- 完成内容分级问卷
- 根据应用功能如实填写
- 推荐选择: **适合所有人**

#### 目标受众:

- **年龄段**: 18 岁及以上 (推荐，避免儿童相关的额外审核)
- **目标国家**: 选择你想发布的国家

### 2. 政策 > 应用权限

审核并确认应用使用的权限:

- 位置权限: 用于 GPS 追踪
- 存储权限: 用于保存路线数据
- 网络权限: 用于用户认证和地图服务
- 相机权限: 用于头像上传

## 🎯 第六步: 提交审核

### 1. 检查发布前概览

- 左侧菜单: **"发布概览"**
- 确保所有必需项都已完成 ✅
- 解决任何警告或错误

### 2. 提交审核

- 返回 **"生产"** 页面
- 点击 **"发布到生产环境"**
- 确认提交

### 3. 审核时间

- **首次提交**: 通常需要 **1-3 天**
- **后续更新**: 通常几小时到 1 天

## 🎯 第七步: 等待审核期间

### 设置邮箱服务

```bash
# 你需要激活这两个邮箱:
support@lawrencezhouda.xyz    # 技术支持
privacy@lawrencezhouda.xyz    # 隐私咨询
```

### 准备网站页面 (可选但推荐)

- 应用主页: https://lawrencezhouda.xyz
- 隐私政策: https://lawrencezhouda.xyz/privacy
- 用户协议: https://lawrencezhouda.xyz/terms

## ✅ 预期结果

### 审核通过后:

- 应用出现在 Google Play 商店
- 用户可以搜索和下载
- 开始收集用户反馈和评分

### 如果审核被拒:

- 收到详细的拒绝原因
- 根据反馈修改应用或描述
- 重新提交审核

## 🚨 常见问题和注意事项

### 1. 账号风险提示

- 使用真实信息注册
- 避免使用 VPN 或代理
- 确保支付信息真实有效

### 2. 审核失败常见原因

- 应用功能描述不准确
- 缺少必要的隐私政策
- 权限使用说明不清晰
- 应用崩溃或功能异常

### 3. 优化建议

- 提供详细的功能描述
- 确保应用稳定运行
- 及时回复 Google 的审核反馈
- 保持联系邮箱的活跃状态

## 📞 需要帮助?

如果在上传过程中遇到问题:

1. 查看 Google Play Console 的帮助文档
2. 联系 Google Play 开发者支持
3. 参考在线开发者社区

祝你上架成功！🎉
