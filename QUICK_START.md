# 🚀 一分钟快速开始

## ⚡ 三条最常用的命令

```bash
# 1️⃣ 查看构建状态
make status

# 2️⃣ 触发构建
make trigger-android    # Android
make trigger-ios        # iOS

# 3️⃣ 下载产物
gh run list            # 查看运行 ID
gh run download <id>   # 下载
```

---

## 📝 完整命令速查

### 监控
```bash
make status         # 状态概览 ⭐ 最常用
make watch          # 持续监控
make list           # 列出运行
gh run watch        # 实时跟踪
```

### 触发
```bash
make trigger-android    # Android 构建
make trigger-ios        # iOS 构建
make trigger-all        # 全部构建
```

### 下载
```bash
gh run list                    # 列出运行
gh run download <run-id>       # 下载全部
gh run download <id> --name <artifact>  # 下载指定产物
```

### 日志
```bash
make logs RUN=<id>          # 查看日志
gh run view <id> --log      # 完整日志
```

### 本地测试
```bash
make local-android    # 本地构建 Android
make local-ios        # 本地构建 iOS
```

---

## 🎯 典型工作流

```bash
# 开发 → 测试 → 推送 → 监控 → 下载

# 1. 本地测试（推荐）
make local-android

# 2. 提交并推送
git add .
git commit -m "your message"
git push

# 3. 监控构建
make status        # 或 make watch

# 4. 下载产物
make list
make download RUN=<run-id>
```

---

## 📚 详细文档

- **完整指南**: `docs/GITHUB_ACTIONS_GUIDE.md`
- **快速参考**: `docs/QUICK_REFERENCE.md`
- **配置说明**: `docs/CI_CD_SETUP.md`
- **完成总结**: `docs/SETUP_COMPLETE.md`

---

## ✅ 首次使用检查

```bash
# 1. 验证 gh CLI
gh auth status

# 2. 如果未登录
gh auth login

# 3. 测试命令
make status

# 4. 查看帮助
make help
```

---

## 💡 提示

- 使用 `make help` 查看所有命令
- 使用 `make status` 是最快的查看方式
- 推送前用 `make local-android` 测试
- 出错时用 `make logs RUN=<id>` 查看详情

**现在就开始**: `make status` 🎉
