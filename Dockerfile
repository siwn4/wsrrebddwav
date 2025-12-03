# 基于原镜像
FROM lmentory/wee:latest

# 安装 git 和 bash
RUN apk add --no-cache git bash 2>/dev/null || (apt-get update && apt-get install -y git bash) || true

# 创建必要目录并赋予权限
RUN mkdir -p /app/tvbox.backup /app/whoosh_index /app/htdocs /tmp && \
    chmod -R 777 /app /tmp

# 设置工作目录
WORKDIR /app

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 暴露端口
EXPOSE 5000 7860

# 默认环境变量
ENV PORT=5000 \
    BACKUP_INTERVAL=3600

# 启动入口
ENTRYPOINT ["/start.sh"]
