#!/bin/bash
# 文件名: build-and-run.sh

set -e

echo "🔨 构建 Docker 镜像..."
docker build -t ds2api:latest .

echo "📁 设置目录权限..."
mkdir -p data
chmod 777 data  # 给所有用户读写权限
touch config.json
chmod 666 config.json  # 如果需要容器写入配置

echo "🧹 清理旧容器..."
docker stop ds2api 2>/dev/null || true
docker rm ds2api 2>/dev/null || true

echo "🚀 启动新容器..."
docker run -d \
    --name ds2api \
    --restart always \
    -p 8443:5001 \
    -v $(pwd)/config.json:/data/config.json \
    -v $(pwd)/data:/app/data \
    -e TZ=Asia/Shanghai \
    -e LOG_LEVEL=INFO \
    -e DS2API_ADMIN_KEY=123456 \
    -e DS2API_CONFIG_PATH=/data/config.json \
    ds2api:latest

echo "✅ 启动成功！"
echo "📝 查看日志: docker logs -f ds2api"
echo "🌐 访问地址: http://localhost:8443"

# 检查权限问题
sleep 2
if ! docker ps | grep -q ds2api; then
    echo "❌ 容器退出，可能是权限问题"
    echo "查看日志："
    docker logs ds2api
fi