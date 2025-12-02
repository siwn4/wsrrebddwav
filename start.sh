#!/bin/sh

# ============================================
# WebDAV 服务启动脚本 (lmentory/wee)
# ============================================

export PORT=${PORT:-5000}
export BACKUP_INTERVAL=${BACKUP_INTERVAL:-3600}

echo "=========================================="
echo "🚀 WebDAV 服务启动中..."
echo "📌 端口: $PORT"
echo "👤 用户: $USERNAME"
echo "📁 存储路径: /app/tvbox.backup"
echo "=========================================="

# 确保存储目录存在
mkdir -p /app/tvbox.backup
chmod -R 777 /app/tvbox.backup

# ============================================
# 从 GitHub 恢复数据
# ============================================
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_REPO" ]; then
    echo "📥 从 GitHub 恢复数据..."
    
    git config --global user.email "backup@webdav.local"
    git config --global user.name "WebDAV Backup"
    
    rm -rf /tmp/repo
    if git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" /tmp/repo 2>/dev/null; then
        cp -r /tmp/repo/* /app/tvbox.backup/ 2>/dev/null || true
        rm -rf /app/tvbox.backup/.git
        echo "✅ 数据恢复完成！"
    else
        echo "⚠️ 备份仓库为空，将创建新备份"
    fi
else
    echo "⚠️ 未配置 GitHub 备份，数据重启后会丢失"
fi

# ============================================
# 后台定时备份
# ============================================
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_REPO" ]; then
    (
        sleep 60
        while true; do
            echo "📤 备份到 GitHub..."
            
            cd /tmp/repo 2>/dev/null || {
                rm -rf /tmp/repo
                mkdir -p /tmp/repo
                cd /tmp/repo
                git init
                git remote add origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git"
            }
            
            cp -r /app/tvbox.backup/* . 2>/dev/null || true
            rm -rf .git/index.lock 2>/dev/null
            
            git add -A
            if git commit -m "🔄 Backup $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null; then
                git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || git push --set-upstream origin main 2>/dev/null
                echo "✅ 备份成功！"
            else
                echo "ℹ️ 无新数据"
            fi
            
            sleep $BACKUP_INTERVAL
        done
    ) &
    echo "🔄 后台备份已启动"
fi

# ============================================
# 启动主程序（查找原镜像的启动方式）
# ============================================
echo "🌐 启动 WebDAV..."

# 查看原镜像有什么文件
echo "📂 /app 目录内容："
ls -la /app/ 2>/dev/null || true

# 尝试常见的启动方式
if [ -f "/app/app.py" ]; then
    exec python /app/app.py
elif [ -f "/app/main.py" ]; then
    exec python /app/main.py
elif [ -f "/app/server.py" ]; then
    exec python /app/server.py
elif [ -f "/app/run.py" ]; then
    exec python /app/run.py
elif [ -f "/entrypoint.sh" ]; then
    exec /entrypoint.sh
elif [ -f "/start.sh" ] && [ "/start.sh" != "$0" ]; then
    exec /start.sh
else
    # 如果找不到，尝试直接运行原镜像的 CMD
    echo "尝试运行原镜像默认命令..."
    exec "$@"
fi
