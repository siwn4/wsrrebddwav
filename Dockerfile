FROM lmentory/wee:latest

# 安装 git（用于备份）
RUN apk add --no-cache git 2>/dev/null || apt-get update && apt-get install -y git 2>/dev/null || true

# 创建存储目录并赋予权限
RUN mkdir -p /app/tvbox.backup && \
    chmod -R 777 /app/tvbox.backup && \
    chmod -R 777 /tmp

# 设置工作目录
WORKDIR /app

# 暴露端口
EXPOSE 5000

# 默认环境变量
ENV PORT=5000
ENV BACKUP_INTERVAL=3600

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
