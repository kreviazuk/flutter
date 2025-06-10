#!/bin/bash

echo "🤖 智能热重载启动中..."
echo "📱 正在检查Android模拟器状态..."

# 检查fswatch是否安装
if ! command -v fswatch &> /dev/null; then
    echo "📦 正在安装文件监听工具fswatch..."
    brew install fswatch
fi

# 启动Android模拟器（如果未运行）
if ! flutter devices | grep -q "emulator"; then
    echo "🚀 启动Android模拟器..."
    flutter emulators --launch Medium_Phone_API_35 &
    sleep 15
fi

# 检查Flutter应用是否运行
if ! pgrep -f "flutter run" > /dev/null; then
    echo "🚀 启动Flutter应用..."
    flutter run -d emulator-5554 --hot &
    sleep 10
fi

echo ""
echo "✅ 智能热重载已启动！"
echo "🔥 现在您可以编辑代码，保存后将自动热重载"
echo "📁 监听目录: lib/"
echo "⏹️  按 Ctrl+C 停止监听"
echo ""

# 创建命名管道来发送命令到Flutter
FLUTTER_PIPE=$(mktemp -u)
mkfifo "$FLUTTER_PIPE"

# 启动监听器
fswatch -0 -r lib/ | while IFS= read -r -d '' file; do
    if [[ "$file" == *.dart ]]; then
        echo "📝 文件变化: $(basename "$file") ($(date '+%H:%M:%S'))"
        echo "🔄 触发热重载..."
        
        # 查找Flutter进程
        FLUTTER_PID=$(pgrep -f "flutter run")
        if [ ! -z "$FLUTTER_PID" ]; then
            # 发送 'r' 命令给Flutter进程
            echo "r" | nc localhost 12345 2>/dev/null || {
                # 如果网络方法失败，尝试直接发送信号
                kill -USR1 "$FLUTTER_PID" 2>/dev/null || echo "⚠️  无法触发热重载"
            }
            echo "✅ 热重载已触发"
        else
            echo "❌ Flutter应用未运行"
        fi
        echo ""
    fi
done 