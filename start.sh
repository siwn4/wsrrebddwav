#!/bin/sh

# ============================================
# WebDAV 服务启动脚本（基于 lmentory/wee）
# ============================================

export PORT=${PORT:-5000}
export BACKUP_INTERVAL=${BACKUP_INTERVAL:-3600}
export WD_USERNAME=${USERNAME:-admin}
export WD_PASSWORD=${PASSWORD:-admin123}

echo "=========================================="
echo "🚀 WebDAV 服务启动中..."
echo "📌 端口: $PORT"
echo "👤 用户: $WD_USERNAME"
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
    echo "🔄 后台备份已启动（每 ${BACKUP_INTERVAL} 秒）"
fi

# ============================================
# 启动 WebDAV 主程序（二进制版本）
# ============================================
cd /app

# 检测架构
machine=$(uname -m)
if echo "$machine" | grep -qE "arm|aarch"; then
    arch="arm64"
else
    arch="amd64"
fi

echo "🔧 系统架构: $arch"

# 确保二进制文件有执行权限
chmod 755 webdav_simulator.$arch 2>/dev/null || true

# 创建临时目录
rm -rf tmp.${PORT}
mkdir -p tmp.${PORT}
chmod 777 tmp.${PORT}
export TMPDIR=tmp.${PORT}

echo "🌐 启动 WebDAV..."

# 启动主程序（带用户名密码）
exec ./webdav_simulator.$arch \
    --port ${PORT} \
    --username "${WD_USERNAME}" \
    --password "${WD_PASSWORD}" \
    --alist_config alistservers.txt \
    --proxymode 1 \
    'xy115-all.txt.xz#xy-dy.txt.xz#xy-dsj.txt.xz#xy115-music.txt.xz'
