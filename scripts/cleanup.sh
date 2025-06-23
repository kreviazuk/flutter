#!/bin/bash

# 🧹 清理过时脚本文件
# 删除不再需要的Ubuntu/通用版本脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 开始清理过时的脚本文件...${NC}"

# 要删除的文件列表
FILES_TO_DELETE=(
    "scripts/init-server.sh"
    "scripts/server-setup.sh" 
    "scripts/quick-deploy.sh"
    "scripts/app.sh"
)

# 创建备份目录
echo -e "${BLUE}📦 创建备份目录...${NC}"
mkdir -p backups/old_scripts

# 移动文件到备份目录
echo -e "${BLUE}🔄 移动文件到备份目录...${NC}"
for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${YELLOW}📁 备份: $file${NC}"
        mv "$file" "backups/old_scripts/$(basename $file)"
    else
        echo -e "${YELLOW}⚠️  文件不存在: $file${NC}"
    fi
done

echo -e "${GREEN}✅ 清理完成！${NC}"
echo -e "${BLUE}📋 清理结果:${NC}"
echo -e "  • 已备份 ${#FILES_TO_DELETE[@]} 个文件到 ${YELLOW}backups/old_scripts/${NC}"
echo -e "  • 删除了过时的Ubuntu/通用版本脚本"
echo -e "  • 保留了Rocky Linux专用脚本"

echo -e "${BLUE}📁 当前有效的脚本文件:${NC}"
ls -la scripts/ | grep -E "\.(sh)$" | sed 's/^/  /'

echo -e "${GREEN}🎉 项目脚本已整理完毕！${NC}"
echo -e "${YELLOW}💡 提示: 备份文件保存在 backups/old_scripts/ 目录中${NC}" 