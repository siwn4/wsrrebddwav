FROM lmentory/wee:latest

# 安装 git
RUN apk add --no-cache git bash 2>/dev/null || apt-get update && apt-get install -y git bash 2>/dev/null || true

# 创建存储目录
RUN mkdir -p /app/tvbox.backup && \
    chmod -R 777 /app/tvbox.backup && \
    chmod -R 777 /tmp

WORKDIR /app

EXPOSE 5000

ENV PORT=5000
ENV BACKUP_INTERVAL=3600

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 清除原 ENTRYPOINT，使用我们的脚本
ENTRYPOINT []
CMD ["/bin/sh", "/start.sh"]
