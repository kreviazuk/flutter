# 🧹 脚本文件清理指南

## 📋 需要删除的文件

以下脚本文件已经过时或不再需要，建议删除以保持项目整洁：

### ❌ 要删除的文件

1. **`scripts/init-server.sh`** - Ubuntu/Debian 版本的服务器初始化脚本

   - **原因**: 您使用的是 Rocky Linux 服务器，应该使用 `init-server-rocky.sh`
   - **替代**: `scripts/init-server-rocky.sh`

2. **`scripts/server-setup.sh`** - Ubuntu/Debian 版本的服务器设置脚本

   - **原因**: 与 Rocky Linux 不兼容，使用了错误的包管理器和配置路径
   - **替代**: `scripts/server-setup-rocky.sh`

3. **`scripts/quick-deploy.sh`** - 通用快速部署脚本

   - **原因**: 功能重复，已被更完善的 `deploy-vps-rocky.sh` 替代
   - **替代**: `scripts/deploy-vps-rocky.sh`

4. **`scripts/app.sh`** - 大型多功能脚本
   - **原因**: 过于复杂，包含太多功能，不够专一
   - **替代**: 已拆分为专门的脚本，功能更清晰

### ✅ 保留的有用文件

1. **`scripts/deploy-vps-rocky.sh`** ⭐ - **主要部署脚本**

   - 用于完整部署前端和后端到 Rocky Linux 服务器

2. **`scripts/server-setup-rocky.sh`** - Rocky Linux 服务器设置

   - 在服务器端运行，配置 Nginx、PM2 等服务

3. **`scripts/init-server-rocky.sh`** - Rocky Linux 服务器初始化

   - 首次设置服务器时使用，安装基础软件

4. **`scripts/setup-ssh.sh`** - SSH 密钥配置

   - 用于配置免密 SSH 连接

5. **`scripts/update-email-config.sh`** ⭐ - **邮件配置更新**
   - 用于更新服务器邮件服务配置

## 🗑️ 执行清理

### 自动清理命令

```bash
# 删除不需要的脚本文件
rm -f scripts/init-server.sh
rm -f scripts/server-setup.sh
rm -f scripts/quick-deploy.sh
rm -f scripts/app.sh

echo "✅ 清理完成！已删除4个过时的脚本文件"
```

### 手动确认清理

如果您想逐个确认删除：

```bash
# 逐个删除并确认
rm -i scripts/init-server.sh
rm -i scripts/server-setup.sh
rm -i scripts/quick-deploy.sh
rm -i scripts/app.sh
```

## 📁 清理后的脚本目录结构

```
scripts/
├── deploy-vps-rocky.sh      ⭐ 主要部署脚本
├── server-setup-rocky.sh    🔧 服务器配置脚本
├── init-server-rocky.sh     🏗️  服务器初始化脚本
├── setup-ssh.sh             🔑 SSH配置脚本
└── update-email-config.sh   📧 邮件配置脚本
```

## 🎯 使用建议

### 日常使用的主要脚本

1. **完整部署** (最常用):

   ```bash
   ./scripts/deploy-vps-rocky.sh 104.225.147.57 myrunning.app
   ```

2. **更新邮件配置**:

   ```bash
   ./scripts/update-email-config.sh your_email@qq.com your_auth_code qq
   ```

3. **设置新服务器** (一次性):

   ```bash
   # 1. 首先SSH密钥设置
   ./scripts/setup-ssh.sh 104.225.147.57

   # 2. 然后服务器初始化（在服务器上运行）
   ssh root@104.225.147.57 'bash -s' < scripts/init-server-rocky.sh
   ```

### 备份建议

在删除前，您可以选择创建备份：

```bash
# 创建备份目录
mkdir -p backups/old_scripts

# 移动而不是删除（更安全）
mv scripts/init-server.sh backups/old_scripts/
mv scripts/server-setup.sh backups/old_scripts/
mv scripts/quick-deploy.sh backups/old_scripts/
mv scripts/app.sh backups/old_scripts/

echo "📦 脚本已备份到 backups/old_scripts/"
```

## ✨ 清理好处

1. **项目更整洁** - 减少混淆和错误使用
2. **维护更简单** - 只关注实际使用的脚本
3. **文档更清晰** - `DEVOPS_GUIDE.md` 中的命令都是有效的
4. **避免错误** - 不会意外使用 Ubuntu 脚本在 Rocky Linux 上

---

**建议**: 执行清理后，更新您的 `.gitignore` 文件，确保不再跟踪删除的文件。
