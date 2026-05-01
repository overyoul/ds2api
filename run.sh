#!/bin/bash
# 文件名: build-and-run.sh

set -e  # 遇到错误立即退出

echo "🔨 构建 Docker 镜像..."
docker build -t ds2api:latest .

echo "🧹 清理旧容器..."
docker stop ds2api 2>/dev/null || true
docker rm ds2api 2>/dev/null || true

echo "🚀 启动新容器..."
docker run -d \
    --name ds2api \
    --restart always \
    -p 8443:5001 \
    -v $(pwd)/config.json:/data/config.json \
    -e TZ=Asia/Shanghai \
    -e LOG_LEVEL=INFO \
    -e DS2API_ADMIN_KEY=123456 \
    ds2api:latest

echo "✅ 启动成功！"
echo "📝 查看日志: docker logs -f ds2api"
echo "🌐 访问地址: http://localhost:8443"