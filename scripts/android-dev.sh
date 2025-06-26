#!/bin/bash

# 🤖 Flutter跑步应用 - Android开发环境启动脚本
# 使用方法: ./scripts/android-dev.sh [options]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🤖 Flutter跑步应用 - Android开发环境管理工具${NC}"
    echo ""
    echo -e "${YELLOW}🚀 基本运行:${NC}"
    echo "  ./scripts/android-dev.sh                    # 启动开发环境"
    echo "  ./scripts/android-dev.sh dev                # 启动开发环境（完整检查）"
    echo "  ./scripts/android-dev.sh quick              # 快速启动（跳过检查）"
    echo "  ./scripts/android-dev.sh full               # 启动前端+后端完整开发环境"
    echo ""
    echo -e "${YELLOW}🔧 开发选项:${NC}"
    echo "  ./scripts/android-dev.sh debug              # 调试模式启动"
    echo "  ./scripts/android-dev.sh profile            # 性能分析模式"
    echo "  ./scripts/android-dev.sh release            # Release模式启动"
    echo "  ./scripts/android-dev.sh hot-reload         # 启用热重载模式"
    echo ""
    echo -e "${YELLOW}🖥️  后端服务:${NC}"
    echo "  ./scripts/android-dev.sh backend            # 仅启动后端服务"
    echo "  ./scripts/android-dev.sh backend-stop       # 停止后端服务"
    echo "  ./scripts/android-dev.sh backend-status     # 查看后端服务状态"
    echo ""
    echo -e "${YELLOW}📱 设备管理:${NC}"
    echo "  ./scripts/android-dev.sh devices            # 列出所有设备"
    echo "  ./scripts/android-dev.sh emulator           # 启动默认模拟器"
    echo "  ./scripts/android-dev.sh choose             # 选择特定设备"
    echo ""
    echo -e "${YELLOW}🛠 维护工具:${NC}"
    echo "  ./scripts/android-dev.sh clean              # 清理项目"
    echo "  ./scripts/android-dev.sh deps               # 安装依赖"
    echo "  ./scripts/android-dev.sh check              # 环境检查"
    echo "  ./scripts/android-dev.sh logs               # 查看日志"
    echo ""
    echo -e "${YELLOW}📦 构建工具:${NC}"
    echo "  ./scripts/android-dev.sh build-apk          # 构建APK"
    echo "  ./scripts/android-dev.sh build-aab          # 构建AAB"
    echo "  ./scripts/android-dev.sh install            # 构建并安装"
}

# 检查Flutter环境
check_flutter_env() {
    echo -e "${BLUE}🔍 检查Flutter环境...${NC}"
    
    # 检查Flutter是否安装
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter未安装或未添加到PATH中${NC}"
        echo -e "${YELLOW}请安装Flutter: https://flutter.dev/docs/get-started/install${NC}"
        exit 1
    fi
    
    # 显示Flutter版本
    echo -e "${GREEN}✅ Flutter版本:${NC}"
    flutter --version | head -1
    
    # 检查Flutter Doctor
    echo -e "${BLUE}🩺 运行Flutter Doctor...${NC}"
    flutter doctor --android-licenses &> /dev/null || true
    
    local doctor_result=$(flutter doctor 2>&1)
    if echo "$doctor_result" | grep -q "No issues found"; then
        echo -e "${GREEN}✅ Flutter环境完全正常${NC}"
    else
        echo -e "${YELLOW}⚠️  Flutter环境检查结果:${NC}"
        echo "$doctor_result"
        echo ""
        echo -e "${YELLOW}💡 建议运行: flutter doctor 来查看详细信息${NC}"
    fi
}

# 检查Android环境
check_android_env() {
    echo -e "${BLUE}🔍 检查Android开发环境...${NC}"
    
    # 检查Android SDK
    if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
        echo -e "${YELLOW}⚠️  ANDROID_HOME或ANDROID_SDK_ROOT环境变量未设置${NC}"
    else
        echo -e "${GREEN}✅ Android SDK路径: ${ANDROID_HOME:-$ANDROID_SDK_ROOT}${NC}"
    fi
    
    # 检查ADB
    if command -v adb &> /dev/null; then
        echo -e "${GREEN}✅ ADB已安装${NC}"
    else
        echo -e "${YELLOW}⚠️  ADB未找到，可能需要添加到PATH中${NC}"
    fi
}

# 检查后端环境
check_backend_env() {
    echo -e "${BLUE}🔍 检查后端开发环境...${NC}"
    
    # 检查Node.js
    if command -v node &> /dev/null; then
        echo -e "${GREEN}✅ Node.js版本: $(node --version)${NC}"
    else
        echo -e "${RED}❌ Node.js未安装${NC}"
        return 1
    fi
    
    # 检查pnpm
    if command -v pnpm &> /dev/null; then
        echo -e "${GREEN}✅ pnpm版本: $(pnpm --version)${NC}"
    else
        echo -e "${RED}❌ pnpm未安装，请运行: npm install -g pnpm${NC}"
        return 1
    fi
    
    # 检查后端目录
    if [ -d "$PROJECT_ROOT/backend" ]; then
        echo -e "${GREEN}✅ 后端目录存在${NC}"
    else
        echo -e "${RED}❌ 后端目录不存在${NC}"
        return 1
    fi
    
    # 检查package.json
    if [ -f "$PROJECT_ROOT/backend/package.json" ]; then
        echo -e "${GREEN}✅ package.json存在${NC}"
    else
        echo -e "${RED}❌ backend/package.json不存在${NC}"
        return 1
    fi
}

# 获取所有Android设备
get_all_devices() {
    flutter devices | grep -E "(android|emulator)" || echo ""
}

# 列出所有设备
list_devices() {
    echo -e "${BLUE}📱 可用的Android设备和模拟器:${NC}"
    local devices=$(get_all_devices)
    
    if [ -z "$devices" ]; then
        echo -e "${RED}❌ 没有找到任何Android设备或模拟器${NC}"
        echo -e "${YELLOW}💡 请启动Android模拟器或连接Android设备${NC}"
        echo -e "${YELLOW}💡 或运行: ./scripts/android-dev.sh emulator${NC}"
        return 1
    fi
    
    echo "$devices"
    echo ""
    echo -e "${CYAN}设备数量: $(echo "$devices" | wc -l)${NC}"
}

# 获取第一个可用设备
get_first_device() {
    local devices=$(get_all_devices)
    if [ -z "$devices" ]; then
        echo -e "${RED}❌ 没有找到Android设备或模拟器${NC}"
        echo -e "${YELLOW}请启动Android模拟器或连接Android设备${NC}"
        exit 1
    fi
    
    local device_id=$(echo "$devices" | head -1 | sed 's/.*• \([^ ]*\) •.*/\1/')
    echo "$device_id"
}

# 选择设备
choose_device() {
    echo -e "${BLUE}📱 选择设备:${NC}"
    local devices=$(get_all_devices)
    
    if [ -z "$devices" ]; then
        echo -e "${RED}❌ 没有找到任何设备${NC}"
        exit 1
    fi
    
    echo "$devices" | nl -w2 -s') '
    echo ""
    read -p "请选择设备编号: " choice
    
    local device_id=$(echo "$devices" | sed -n "${choice}p" | sed 's/.*• \([^ ]*\) •.*/\1/')
    if [ -z "$device_id" ]; then
        echo -e "${RED}❌ 无效的选择${NC}"
        exit 1
    fi
    
    echo "$device_id"
}

# 启动Android模拟器
start_emulator() {
    echo -e "${BLUE}🚀 启动Android模拟器...${NC}"
    
    # 检查是否已有模拟器运行
    local running_emulators=$(adb devices | grep emulator | wc -l)
    if [ "$running_emulators" -gt 0 ]; then
        echo -e "${GREEN}✅ 已有模拟器在运行${NC}"
        return 0
    fi
    
    # 获取可用的AVD
    local avds=$(avdmanager list avd | grep "Name:" | sed 's/.*Name: //')
    if [ -z "$avds" ]; then
        echo -e "${RED}❌ 没有找到可用的AVD${NC}"
        echo -e "${YELLOW}请使用Android Studio创建AVD${NC}"
        exit 1
    fi
    
    # 使用第一个可用的AVD
    local avd_name=$(echo "$avds" | head -1)
    echo -e "${BLUE}🚀 启动AVD: $avd_name${NC}"
    
    # 在后台启动模拟器
    emulator -avd "$avd_name" -no-audio -no-boot-anim &
    
    # 等待模拟器启动
    echo -e "${YELLOW}⏳ 等待模拟器启动...${NC}"
    local timeout=120
    local count=0
    
    while [ $count -lt $timeout ]; do
        if adb devices | grep -q "device$"; then
            echo -e "${GREEN}✅ 模拟器启动成功${NC}"
            return 0
        fi
        sleep 2
        count=$((count + 2))
        echo -ne "\r${YELLOW}⏳ 等待模拟器启动... ${count}s${NC}"
    done
    
    echo -e "\n${RED}❌ 模拟器启动超时${NC}"
    exit 1
}

# 清理项目
clean_project() {
    echo -e "${BLUE}🧹 清理项目...${NC}"
    cd "$PROJECT_ROOT"
    
    flutter clean
    flutter pub get
    
    # 清理Android构建缓存
    if [ -d "android" ]; then
        cd android
        ./gradlew clean || true
        cd ..
    fi
    
    echo -e "${GREEN}✅ 项目清理完成${NC}"
}

# 安装依赖
install_dependencies() {
    echo -e "${BLUE}📦 安装依赖...${NC}"
    cd "$PROJECT_ROOT"
    
    flutter pub get
    
    # 生成本地化文件
    if [ -f "lib/l10n.yaml" ]; then
        echo -e "${BLUE}🌐 生成本地化文件...${NC}"
        flutter gen-l10n
    fi
    
    echo -e "${GREEN}✅ 依赖安装完成${NC}"
}

# 运行应用
run_app() {
    local mode="$1"
    local device_id="$2"
    
    cd "$PROJECT_ROOT"
    
    # 确保依赖已安装
    flutter pub get
    
    case "$mode" in
        "debug"|"")
            echo -e "${BLUE}🚀 启动Flutter应用 - Debug模式${NC}"
            flutter run -d "$device_id" --debug
            ;;
        "profile")
            echo -e "${BLUE}🚀 启动Flutter应用 - Profile模式${NC}"
            flutter run -d "$device_id" --profile
            ;;
        "release")
            echo -e "${BLUE}🚀 启动Flutter应用 - Release模式${NC}"
            flutter run -d "$device_id" --release
            ;;
        "hot-reload")
            echo -e "${BLUE}🚀 启动Flutter应用 - 热重载模式${NC}"
            flutter run -d "$device_id" --debug --hot
            ;;
        *)
            echo -e "${RED}❌ 不支持的运行模式: $mode${NC}"
            exit 1
            ;;
    esac
}

# 构建应用
build_app() {
    local type="$1"
    cd "$PROJECT_ROOT"
    
    echo -e "${BLUE}🔨 清理项目...${NC}"
    flutter clean && flutter pub get
    
    case "$type" in
        "apk")
            echo -e "${BLUE}🔨 构建Debug APK...${NC}"
            flutter build apk --debug
            echo -e "${GREEN}✅ APK构建完成: build/app/outputs/flutter-apk/app-debug.apk${NC}"
            ;;
        "apk-release")
            echo -e "${BLUE}🔨 构建Release APK...${NC}"
            flutter build apk --release
            echo -e "${GREEN}✅ Release APK构建完成: build/app/outputs/flutter-apk/app-release.apk${NC}"
            ;;
        "aab")
            echo -e "${BLUE}🔨 构建App Bundle...${NC}"
            flutter build appbundle --release
            echo -e "${GREEN}✅ AAB构建完成: build/app/outputs/bundle/release/app-release.aab${NC}"
            ;;
        *)
            echo -e "${RED}❌ 不支持的构建类型: $type${NC}"
            exit 1
            ;;
    esac
}

# 构建并安装
build_and_install() {
    local device_id=$(get_first_device)
    
    echo -e "${BLUE}🔨 构建并安装应用...${NC}"
    cd "$PROJECT_ROOT"
    
    flutter clean && flutter pub get
    flutter build apk --debug
    flutter install -d "$device_id"
    
    echo -e "${GREEN}✅ 应用安装完成${NC}"
}

# 查看日志
view_logs() {
    echo -e "${BLUE}📋 查看应用日志...${NC}"
    echo -e "${YELLOW}按Ctrl+C退出日志查看${NC}"
    flutter logs
}

# 启动后端服务
start_backend() {
    echo -e "${BLUE}🖥️  启动后端服务...${NC}"
    
    # 检查后端环境
    if ! check_backend_env; then
        exit 1
    fi
    
    cd "$PROJECT_ROOT/backend"
    
    # 检查是否已有后端服务运行
    if check_backend_status_quiet; then
        echo -e "${YELLOW}⚠️  后端服务已在运行 (PID: $(get_backend_pid))${NC}"
        echo -e "${YELLOW}如需重启，请先运行: ./scripts/android-dev.sh backend-stop${NC}"
        return 0
    fi
    
    # 安装依赖
    echo -e "${BLUE}📦 安装后端依赖...${NC}"
    pnpm install
    
    # 生成Prisma客户端
    if [ -f "prisma/schema.prisma" ]; then
        echo -e "${BLUE}🔨 生成Prisma客户端...${NC}"
        pnpm db:generate
    fi
    
    # 在后台启动服务
    echo -e "${BLUE}🚀 启动后端服务...${NC}"
    nohup pnpm dev > backend.log 2>&1 &
    local backend_pid=$!
    
    # 保存PID
    echo $backend_pid > "$PROJECT_ROOT/.backend.pid"
    
    # 等待服务启动
    echo -e "${YELLOW}⏳ 等待后端服务启动...${NC}"
    sleep 3
    
    if check_backend_status_quiet; then
        echo -e "${GREEN}✅ 后端服务启动成功！${NC}"
        echo -e "${GREEN}🌐 服务地址: http://localhost:3001${NC}"
        echo -e "${GREEN}📋 PID: $(get_backend_pid)${NC}"
        echo -e "${CYAN}💡 查看日志: tail -f backend/backend.log${NC}"
    else
        echo -e "${RED}❌ 后端服务启动失败${NC}"
        echo -e "${YELLOW}请查看日志: cat backend/backend.log${NC}"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
}

# 停止后端服务
stop_backend() {
    echo -e "${BLUE}🛑 停止后端服务...${NC}"
    
    local pid_file="$PROJECT_ROOT/.backend.pid"
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo -e "${GREEN}✅ 后端服务已停止 (PID: $pid)${NC}"
        else
            echo -e "${YELLOW}⚠️  进程 $pid 不存在${NC}"
        fi
        rm -f "$pid_file"
    else
        echo -e "${YELLOW}⚠️  没有找到后端服务PID文件${NC}"
    fi
    
    # 清理可能残留的Node.js进程
    pkill -f "pnpm dev" 2>/dev/null || true
    pkill -f "nodemon server.js" 2>/dev/null || true
    
    echo -e "${GREEN}✅ 后端服务清理完成${NC}"
}

# 获取后端服务PID
get_backend_pid() {
    local pid_file="$PROJECT_ROOT/.backend.pid"
    if [ -f "$pid_file" ]; then
        cat "$pid_file"
    else
        echo ""
    fi
}

# 检查后端服务状态（静默）
check_backend_status_quiet() {
    local pid=$(get_backend_pid)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# 检查后端服务状态
check_backend_status() {
    echo -e "${BLUE}🔍 检查后端服务状态...${NC}"
    
    local pid=$(get_backend_pid)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        echo -e "${GREEN}✅ 后端服务正在运行${NC}"
        echo -e "${GREEN}📋 PID: $pid${NC}"
        echo -e "${GREEN}🌐 服务地址: http://localhost:3000${NC}"
        echo -e "${CYAN}💡 查看日志: tail -f backend/backend.log${NC}"
        echo -e "${CYAN}💡 停止服务: ./scripts/android-dev.sh backend-stop${NC}"
    else
        echo -e "${RED}❌ 后端服务未运行${NC}"
        echo -e "${CYAN}💡 启动服务: ./scripts/android-dev.sh backend${NC}"
    fi
}

# 启动完整开发环境（前端+后端）
start_full_dev() {
    echo -e "${PURPLE}🚀 启动完整开发环境...${NC}"
    
    # 检查环境
    check_flutter_env
    check_android_env
    check_backend_env || exit 1
    
    # 启动后端服务
    echo -e "\n${BLUE}步骤 1/3: 启动后端服务${NC}"
    start_backend
    
    # 检查设备
    echo -e "\n${BLUE}步骤 2/3: 检查Android设备${NC}"
    list_devices
    local device_id=$(get_first_device)
    echo -e "${GREEN}✅ 使用设备: $device_id${NC}"
    
    # 启动前端应用
    echo -e "\n${BLUE}步骤 3/3: 启动Flutter应用${NC}"
    echo -e "${GREEN}🎯 完整开发环境准备就绪！${NC}"
    echo -e "${CYAN}💡 后端服务: http://localhost:3001${NC}"
    echo -e "${CYAN}💡 停止后端: ./scripts/android-dev.sh backend-stop${NC}"
    
    run_app "debug" "$device_id"
}

# 主函数
main() {
    local command="${1:-dev}"
    
    case "$command" in
        "help"|"-h"|"--help")
            show_help
            ;;
        "dev"|"")
            check_flutter_env
            check_android_env
            list_devices
            local device_id=$(get_first_device)
            echo -e "${GREEN}✅ 使用设备: $device_id${NC}"
            run_app "debug" "$device_id"
            ;;
        "quick")
            local device_id=$(get_first_device)
            echo -e "${GREEN}🚀 快速启动，使用设备: $device_id${NC}"
            run_app "debug" "$device_id"
            ;;
        "debug")
            local device_id=$(get_first_device)
            run_app "debug" "$device_id"
            ;;
        "profile")
            local device_id=$(get_first_device)
            run_app "profile" "$device_id"
            ;;
        "release")
            local device_id=$(get_first_device)
            run_app "release" "$device_id"
            ;;
        "hot-reload")
            local device_id=$(get_first_device)
            run_app "hot-reload" "$device_id"
            ;;
        "devices")
            list_devices
            ;;
        "emulator")
            start_emulator
            ;;
        "choose")
            local device_id=$(choose_device)
            echo -e "${GREEN}✅ 选择的设备: $device_id${NC}"
            run_app "debug" "$device_id"
            ;;
        "clean")
            clean_project
            ;;
        "deps")
            install_dependencies
            ;;
        "check")
            check_flutter_env
            check_android_env
            check_backend_env
            list_devices
            ;;
        "logs")
            view_logs
            ;;
        "backend")
            start_backend
            ;;
        "backend-stop")
            stop_backend
            ;;
        "backend-status")
            check_backend_status
            ;;
        "full")
            start_full_dev
            ;;
        "build-apk")
            build_app "apk"
            ;;
        "build-apk-release")
            build_app "apk-release"
            ;;
        "build-aab")
            build_app "aab"
            ;;
        "install")
            build_and_install
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $command${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@" 