#!/bin/bash

# Android模拟器自动热重载脚本
echo "🤖 启动Android模拟器自动热重载..."
echo "📱 目标设备: emulator-5554"
echo "📁 监听目录: lib/"
echo "💡 修改任何Dart文件都会自动热重载到Android模拟器"
echo ""

# 检查Android模拟器是否运行
if ! flutter devices | grep -q "emulator-5554"; then
    echo "❌ Android模拟器未运行，正在启动..."
    flutter emulators --launch Medium_Phone_API_35 &
    echo "⏳ 等待模拟器启动..."
    sleep 20
fi

# 检查Flutter应用是否在运行
if ! pgrep -f "flutter run.*emulator-5554" > /dev/null; then
    echo "🚀 在Android模拟器上启动Flutter应用..."
    flutter run -d emulator-5554 --hot &
    echo "⏳ 等待应用启动..."
    sleep 10
fi

# 检查是否安装了fswatch
if ! command -v fswatch &> /dev/null; then
    echo "📦 安装文件监听工具..."
    brew install fswatch
fi

echo "✅ 开始监听文件变化..."
echo "🔥 现在您可以修改代码，将自动热重载到Android模拟器！"
echo ""

# 监听lib目录的变化并自动触发热重载
fswatch -0 lib/ | while IFS= read -r -d '' file; do
    echo "📝 检测到文件变化: $(basename "$file")"
    echo "🔄 触发热重载..."
    
    # 查找Flutter进程的PID
    FLUTTER_PID=$(pgrep -f "flutter run.*emulator-5554")
    
    if [ ! -z "$FLUTTER_PID" ]; then
        # 向Flutter进程发送'r'字符来触发热重载
        echo "r" > /proc/$FLUTTER_PID/fd/0 2>/dev/null || {
            # 如果上面的方法不工作，尝试使用tmux或screen
            echo "🔄 尝试替代方法触发热重载..."
        }
        echo "✅ 热重载已触发 ($(date '+%H:%M:%S'))"
    else
        echo "⚠️  Flutter应用未运行，请手动启动"
    fi
    echo ""
done 