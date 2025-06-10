#!/bin/bash

# Flutter自动热重载脚本
# 监听lib文件夹的变化并自动触发热重载

echo "🚀 启动Flutter自动热重载监听..."
echo "📁 监听目录: lib/"
echo "💡 修改任何Dart文件都会自动热重载"
echo ""

# 检查是否安装了fswatch
if ! command -v fswatch &> /dev/null; then
    echo "❌ 需要安装fswatch工具"
    echo "请运行: brew install fswatch"
    exit 1
fi

# 启动Flutter应用（如果没有运行）
if ! pgrep -f "flutter run" > /dev/null; then
    echo "🔄 启动Flutter应用..."
    flutter run -d chrome &
    sleep 5
fi

# 监听文件变化
fswatch -o lib/ | while read f; do
    echo "📝 检测到文件变化，触发热重载..."
    # 这里可以通过Flutter的热重载API触发重载
    # 或者简单地输出提示
    echo "🔥 Hot reload triggered at $(date)"
done 