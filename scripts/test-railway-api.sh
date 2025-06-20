#!/bin/bash

RAILWAY_URL="https://flutter-production-80de.up.railway.app"

echo "🚂 Railway API 测试脚本"
echo "========================="
echo "测试 URL: $RAILWAY_URL"
echo ""

# 测试健康检查端点
echo "🔍 测试健康检查端点..."
echo "GET $RAILWAY_URL/health"
echo ""

# 使用 curl 测试，显示详细信息
response=$(curl -s -w "HTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}s\n" "$RAILWAY_URL/health" 2>/dev/null)
http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
time_total=$(echo "$response" | grep "TIME_TOTAL:" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE:/d' | sed '/TIME_TOTAL:/d')

if [ "$http_code" = "200" ]; then
    echo "✅ 健康检查成功！"
    echo "📊 响应时间: $time_total"
    echo "📋 响应内容:"
    echo "$body" | jq . 2>/dev/null || echo "$body"
    echo ""
    
    # 测试注册接口
    echo "🔍 测试注册接口..."
    echo "POST $RAILWAY_URL/api/auth/register"
    
    register_response=$(curl -s -w "HTTP_CODE:%{http_code}\n" \
        -X POST "$RAILWAY_URL/api/auth/register" \
        -H "Content-Type: application/json" \
        -d '{
            "email": "test@example.com",
            "password": "123456",
            "username": "testuser"
        }' 2>/dev/null)
    
    register_code=$(echo "$register_response" | grep "HTTP_CODE:" | cut -d: -f2)
    register_body=$(echo "$register_response" | sed '/HTTP_CODE:/d')
    
    if [ "$register_code" = "201" ] || [ "$register_code" = "400" ]; then
        echo "✅ 注册接口响应正常 (HTTP $register_code)"
        echo "📋 响应内容:"
        echo "$register_body" | jq . 2>/dev/null || echo "$register_body"
    else
        echo "❌ 注册接口异常 (HTTP $register_code)"
        echo "$register_body"
    fi
    
else
    echo "❌ 健康检查失败！"
    echo "📊 HTTP 状态码: $http_code"
    echo "📊 响应时间: $time_total"
    echo "📋 响应内容: $body"
    echo ""
    echo "🔧 可能的问题："
    echo "1. Railway 服务正在重新部署"
    echo "2. 端口配置问题"
    echo "3. 应用启动失败"
    echo ""
    echo "💡 建议操作："
    echo "1. 等待 2-3 分钟后重新测试"
    echo "2. 检查 Railway 项目的 Deployments 日志"
    echo "3. 确认环境变量配置正确"
fi

echo ""
echo "🌐 你可以在浏览器中访问:"
echo "   $RAILWAY_URL/health"
echo ""
echo "🔧 如果问题持续，请检查 Railway 项目日志" 