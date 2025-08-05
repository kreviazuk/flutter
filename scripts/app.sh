#!/bin/bash

# 🚀 Flutter跑步应用统一管理脚本
# 使用方法: ./scripts/app.sh <command> [options]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🏃‍♂️ Flutter跑步应用管理工具${NC}"
    echo ""
    echo -e "${YELLOW}📱 运行应用:${NC}"
    echo "  ./scripts/app.sh run android-dev    # Android开发环境"
    echo "  ./scripts/app.sh run android-test   # Android测试环境(VPS)"
    echo "  ./scripts/app.sh run web-dev        # Web开发环境"
    echo "  ./scripts/app.sh run web-test       # Web测试环境(VPS)"
    echo "  ./scripts/app.sh run ios-dev        # iOS开发环境"
    echo ""
    echo -e "${YELLOW}🔨 构建应用:${NC}"
    echo "  ./scripts/app.sh build android      # 构建Android APK"
    echo "  ./scripts/app.sh build android-aab  # 构建Android Bundle"
    echo "  ./scripts/app.sh build ios          # 构建iOS应用"
    echo "  ./scripts/app.sh build web          # 构建Web应用"
    echo ""
    echo -e "${YELLOW}🚀 部署应用:${NC}"
    echo "  ./scripts/app.sh deploy vps <ip> <domain>  # 部署到VPS"
    echo "  ./scripts/app.sh deploy setup <domain>     # VPS服务器配置"
    echo ""
    echo -e "${YELLOW}🔧 开发工具:${NC}"
    echo "  ./scripts/app.sh dev start          # 启动开发环境(前后端)"
    echo "  ./scripts/app.sh dev backend        # 仅启动后端"
    echo "  ./scripts/app.sh dev clean          # 清理缓存"
    echo ""
    echo -e "${YELLOW}🧪 测试工具:${NC}"
    echo "  ./scripts/app.sh test api           # 测试API连接"
    echo "  ./scripts/app.sh test config        # 检查配置"
    echo ""
    echo -e "${YELLOW}📊 监控工具:${NC}"
    echo "  ./scripts/app.sh monitor android    # 监控Android应用"
    echo "  ./scripts/app.sh monitor logs       # 查看服务器日志"
}

# 检测Android设备
get_android_device() {
    local devices=$(flutter devices | grep "android")
    if [ -z "$devices" ]; then
        echo -e "${RED}❌ 没有找到Android设备或模拟器${NC}"
        echo -e "${YELLOW}请启动Android模拟器或连接Android设备${NC}"
        exit 1
    fi
    
    local device_id=$(flutter devices | grep "android" | head -1 | sed 's/.*• \([^ ]*\) •.*/\1/')
    echo "$device_id"
}

# 运行应用
run_app() {
    local platform="$1"
    local env="$2"
    
    cd "$PROJECT_ROOT"
    
    case "$platform-$env" in
        "android-dev")
            echo -e "${BLUE}🚀 启动Android应用 - 开发环境${NC}"
            local device_id=$(get_android_device)
            flutter clean && flutter pub get
            flutter run -d "$device_id"
            ;;
        "android-test")
            echo -e "${BLUE}🚀 启动Android应用 - VPS测试环境${NC}"
            echo -e "${YELLOW}API地址: https://proxy.lawrencezhouda.xyz:8443/api/auth${NC}"
            local device_id=$(get_android_device)
            flutter clean && flutter pub get
            flutter run -d "$device_id" \
                --dart-define=ENV=test \
                --dart-define=API_BASE_URL=https://proxy.lawrencezhouda.xyz:8443/api/auth
            ;;
        "web-dev")
            echo -e "${BLUE}🌐 启动Web应用 - 开发环境${NC}"
            flutter clean && flutter pub get
            flutter run -d chrome --web-port 8080
            ;;
        "web-test")
            echo -e "${BLUE}🌐 启动Web应用 - VPS测试环境${NC}"
            echo -e "${YELLOW}API地址: https://proxy.lawrencezhouda.xyz:8443/api/auth${NC}"
            flutter clean && flutter pub get
            flutter run -d chrome --web-port 8080 \
                --dart-define=ENV=test \
                --dart-define=API_BASE_URL=https://proxy.lawrencezhouda.xyz:8443/api/auth
            ;;
        "ios-dev")
            echo -e "${BLUE}📱 启动iOS应用 - 开发环境${NC}"
            flutter clean && flutter pub get
            flutter run -d ios
            ;;
        *)
            echo -e "${RED}❌ 不支持的平台: $platform-$env${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 构建应用
build_app() {
    local target="$1"
    cd "$PROJECT_ROOT"
    
    echo -e "${BLUE}🔨 清理缓存...${NC}"
    flutter clean && flutter pub get
    
    case "$target" in
        "android")
            echo -e "${BLUE}🔨 构建Android APK...${NC}"
            flutter build apk --release --dart-define=ENV=prod
            echo -e "${GREEN}✅ APK构建完成: build/app/outputs/flutter-apk/app-release.apk${NC}"
            ;;
        "android-aab")
            echo -e "${BLUE}🔨 构建Android Bundle...${NC}"
            flutter build appbundle --release --dart-define=ENV=prod
            echo -e "${GREEN}✅ AAB构建完成: build/app/outputs/bundle/release/app-release.aab${NC}"
            ;;
        "ios")
            echo -e "${BLUE}📱 构建iOS应用...${NC}"
            flutter build ios --release --dart-define=ENV=prod
            echo -e "${GREEN}✅ iOS构建完成，请使用Xcode打开 ios/Runner.xcworkspace${NC}"
            ;;
        "web")
            echo -e "${BLUE}🌐 构建Web应用...${NC}"
            flutter build web --release --dart-define=ENV=prod
            echo -e "${GREEN}✅ Web构建完成: build/web/${NC}"
            ;;
        *)
            echo -e "${RED}❌ 不支持的构建目标: $target${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 部署应用
deploy_app() {
    local action="$1"
    local server_ip="$2"
    local domain="$3"
    
    cd "$PROJECT_ROOT"
    
    case "$action" in
        "vps")
            if [ -z "$server_ip" ] || [ -z "$domain" ]; then
                echo -e "${RED}❌ 使用方法: ./scripts/app.sh deploy vps <服务器IP> <域名>${NC}"
                exit 1
            fi
            echo -e "${BLUE}🚀 部署到VPS服务器...${NC}"
            echo -e "${YELLOW}服务器IP: $server_ip${NC}"
            echo -e "${YELLOW}域名: $domain${NC}"
            
            # 构建应用
            flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=https://$domain/api/auth
            
            # 打包文件
            tar -czf backend.tar.gz backend/
            tar -czf frontend.tar.gz build/web/
            
            # 上传到服务器
            scp backend.tar.gz deploy@$server_ip:~/
            scp frontend.tar.gz deploy@$server_ip:~/
            scp scripts/server-setup.sh deploy@$server_ip:~/
            
            # 在服务器上执行部署
            ssh deploy@$server_ip "chmod +x ~/server-setup.sh && ~/server-setup.sh $domain"
            
            # 清理临时文件
            rm -f backend.tar.gz frontend.tar.gz
            
            echo -e "${GREEN}✅ 部署完成！${NC}"
            echo -e "${GREEN}🌐 访问地址: https://$domain${NC}"
            ;;
        *)
            echo -e "${RED}❌ 不支持的部署方式: $action${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 开发工具
dev_tools() {
    local action="$1"
    cd "$PROJECT_ROOT"
    
    case "$action" in
        "start")
            echo -e "${BLUE}🚀 启动完整开发环境...${NC}"
            echo -e "${YELLOW}后端: http://localhost:3000${NC}"
            echo -e "${YELLOW}前端: http://localhost:8080${NC}"
            
            # 启动后端（后台）
            (cd backend && pnpm dev) &
            
            # 等待后端启动
            sleep 3
            
            # 启动前端
            flutter run -d chrome --web-port 8080
            ;;
        "backend")
            echo -e "${BLUE}🚀 启动后端服务...${NC}"
            cd backend
            pnpm dev
            ;;
        "clean")
            echo -e "${BLUE}🧹 清理缓存...${NC}"
            flutter clean
            flutter pub get
            cd backend && pnpm install
            echo -e "${GREEN}✅ 清理完成${NC}"
            ;;
        *)
            echo -e "${RED}❌ 不支持的开发工具: $action${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 测试工具
test_tools() {
    local target="$1"
    
    case "$target" in
        "api")
            echo -e "${BLUE}🧪 测试API连接...${NC}"
            echo "测试本地API..."
            curl -f http://localhost:3000/health || echo "本地API连接失败"
            echo "测试VPS API..."
            curl -f https://proxy.lawrencezhouda.xyz:8443/api/health || echo "VPS API连接失败"
            ;;
        "config")
            echo -e "${BLUE}🔍 检查配置...${NC}"
            cd "$PROJECT_ROOT"
            flutter doctor
            echo -e "${GREEN}Flutter环境检查完成${NC}"
            ;;
        *)
            echo -e "${RED}❌ 不支持的测试目标: $target${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 监控工具
monitor_tools() {
    local target="$1"
    
    case "$target" in
        "android")
            echo -e "${BLUE}📊 监控Android应用...${NC}"
            flutter logs
            ;;
        "logs")
            echo -e "${BLUE}📊 查看服务器日志...${NC}"
            echo "请在VPS服务器上执行: su - deploy && pm2 logs running-tracker-api"
            ;;
        *)
            echo -e "${RED}❌ 不支持的监控目标: $target${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        "run")
            if [ $# -lt 1 ]; then
                echo -e "${RED}❌ 请指定运行平台，例如: android-dev, web-test${NC}"
                show_help
                exit 1
            fi
            local platform_env="$1"
            IFS='-' read -r platform env <<< "$platform_env"
            run_app "$platform" "$env"
            ;;
        "build")
            if [ $# -lt 1 ]; then
                echo -e "${RED}❌ 请指定构建目标，例如: android, ios, web${NC}"
                show_help
                exit 1
            fi
            build_app "$1"
            ;;
        "deploy")
            deploy_app "$@"
            ;;
        "dev")
            if [ $# -lt 1 ]; then
                echo -e "${RED}❌ 请指定开发工具，例如: start, backend, clean${NC}"
                show_help
                exit 1
            fi
            dev_tools "$1"
            ;;
        "test")
            if [ $# -lt 1 ]; then
                echo -e "${RED}❌ 请指定测试目标，例如: api, config${NC}"
                show_help
                exit 1
            fi
            test_tools "$1"
            ;;
        "monitor")
            if [ $# -lt 1 ]; then
                echo -e "${RED}❌ 请指定监控目标，例如: android, logs${NC}"
                show_help
                exit 1
            fi
            monitor_tools "$1"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $command${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 