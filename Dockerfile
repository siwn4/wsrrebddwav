FROM lmentor/webdavsim:latest

# 安装 git（用于备份到 GitHub）
RUN apk add --no-cache git || apt-get update && apt-get install -y git || true

# 创建存储目录并赋予权限
RUN mkdir -p /app/tvbox.backup && \
    chmod -R 777 /app/tvbox.backup && \
    chmod -R 777 /tmp

# 设置工作目录
WORKDIR /app

# 暴露端口（ 默认 7860）
EXPOSE 7860

# 默认环境变量
ENV PORT=7860
ENV BACKUP_INTERVAL=3600

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
