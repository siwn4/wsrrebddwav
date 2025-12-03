#!/bin/bash

# 环境变量
export PORT=${PORT:-5000}
export USERNAME=${USERNAME:-guest}
export PASSWORD=${PASSWORD:-guest_Api789}
export BACKUP_INTERVAL=${BACKUP_INTERVAL:-3600}

echo "=========================================="
echo "🚀 启动 WebDAV 增强版"
echo "📌 端口: $PORT"
echo "👤 用户: $USERNAME"
echo "=========================================="

# --------------------------------------------
# 1. 恢复备份 (从 GitHub)
# --------------------------------------------
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_REPO" ]; then
    echo "📥 [恢复] 正在拉取备份..."
    
    git config --global user.email "backup@webdav"
    git config --global user.name "WebDAV Backup"
    git config --global init.defaultBranch main
    
    rm -rf /tmp/repo
    if git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" /tmp/repo 2>/dev/null; then
        mkdir -p /app/tvbox.backup
        cp -r /tmp/repo/* /app/tvbox.backup/ 2>/dev/null || true
        rm -rf /app/tvbox.backup/.git
        echo "✅ [恢复] 成功！"
    else
        echo "⚠️ [恢复] 仓库为空或不可访问"
    fi

    # 启动后台备份进程
    (
        sleep 60
        while true; do
            echo "📤 [备份] 同步到 GitHub..."
            rm -rf /tmp/repo
            git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" /tmp/repo 2>/dev/null || {
                mkdir -p /tmp/repo && cd /tmp/repo && git init
                git remote add origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git"
            }
            
            cd /tmp/repo
            cp -r /app/tvbox.backup/* . 2>/dev/null || true
            git add -A
            
            if ! git diff --cached --quiet; then
                git commit -m "Backup $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null
                git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null
                echo "✅ [备份] 推送成功"
            fi
            sleep $BACKUP_INTERVAL
        done
    ) &
else
    echo "⚠️ [警告] 未配置 GITHUB_TOKEN，数据不保留！"
fi

# --------------------------------------------
# 2. 启动主程序
# --------------------------------------------
mkdir -p /app/htdocs /app/whoosh_index /app/tvbox.backup
chmod -R 777 /app

chmod +x /app/webdav_simulator.amd64
exec /app/webdav_simulator.amd64 \
    --port "$PORT" \
    --alist_config /app/alist.txt \
    --noindex \
    --username "$USERNAME" \
    --password "$PASSWORD" \
    /app/0.txt
