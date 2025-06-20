#!/bin/bash

echo "📱 Android Flutter 应用监控"
echo "============================"

echo ""
echo "🔍 Android 设备状态:"
adb devices

echo ""
echo "🚀 Flutter 进程状态:"
ps aux | grep flutter | grep -v grep | head -3

echo ""
echo "📊 实时日志 (最新20行):"
echo "使用 Ctrl+C 停止日志监控"
echo "------------------------"

# 显示实时日志
flutter logs 