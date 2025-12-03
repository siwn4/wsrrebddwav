# ☁️ WebDAV 增强版 (支持+ 自动备份)

基于 `lmentory/wee` 改造，增加了 GitHub 自动备份功能，数据永不丢失！

## ✨ 特性
- ✅ **数据持久化**：自动备份 `/app/tvbox.backup` 到私有 GitHub 仓库
- ✅ **多平台兼容**
- ✅ **自定义端口**：支持通过环境变量修改监听端口
- ✅ **零配置启动**：内置默认参数，开箱即用


## 🛠️ 部署指南

### 1. 准备工作
1. 创建一个 **私有** GitHub 仓库用于存数据（例如 `my-data-backup`）
2. 生成一个 GitHub Token (勾选 `repo` 权限)

### 2. 部署
使用以下镜像地址：ghcr.io/你的用户名/仓库名:latest

### 3. 设置环境变量

#### 必填项
| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `USERNAME` | WebDAV 账号 | `admin` |
| `PASSWORD` | WebDAV 密码 | `123456` |
| `GITHUB_TOKEN` | 你的 GitHub Token | `ghp_xxxx...` |
| `GITHUB_REPO` | 数据备份仓库 | `zhangsan/my-data-backup` |

#### 选填项 (高级配置)
| 变量名 | 说明 | 默认值 | 适用场景 |
|--------|------|--------|----------|
| `PORT` | 服务监听端口 | `5000` | 可自定义 |
| `BACKUP_INTERVAL` | 自动备份间隔(秒) | `3600` | 需要更频繁备份时修改 |

### 4. 挂载地址

部署成功后，你的 WebDAV 地址为：
https://账号:密码@你的域名/tvbox.backup/任意文件夹名

