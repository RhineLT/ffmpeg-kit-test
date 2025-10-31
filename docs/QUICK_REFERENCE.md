# 🚀 GitHub Actions 快速参考卡

## 最常用命令（3 条）

```bash
# 1. 查看构建状态（最常用）
make status
# 或
./scripts/quick-status.sh

# 2. 触发构建
make trigger-android  # Android
make trigger-ios      # iOS

# 3. 下载构建产物
gh run list           # 查看运行列表
gh run download <id>  # 下载产物
```

---

## 📊 监控命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `make status` | 快速状态概览 | `make status` |
| `make watch` | 持续监控（30秒刷新） | `make watch` |
| `make list` | 列出最近10次运行 | `make list` |
| `gh run watch` | 实时跟踪最新运行 | `gh run watch` |
| `gh run list` | 查看所有运行 | `gh run list --limit 20` |

---

## 🎯 触发构建

| 命令 | 说明 |
|------|------|
| `make trigger-android` | 触发 Android 构建 |
| `make trigger-ios` | 触发 iOS 构建 |
| `make trigger-all` | 触发所有构建 |
| `gh workflow run build-android.yml` | 直接触发（gh） |

---

## 📦 下载产物

```bash
# 步骤 1: 查看运行列表
gh run list --limit 5

# 步骤 2: 下载特定运行
gh run download <run-id>

# 或使用 make
make download RUN=<run-id>

# 下载特定产物
gh run download <run-id> --name app-maven-central-debug
```

---

## 🔍 查看日志

```bash
# 查看运行详情
gh run view <run-id>

# 查看完整日志
gh run view <run-id> --log

# 使用 make
make logs RUN=<run-id>

# 在浏览器中打开
gh run view <run-id> --web
```

---

## 🛠️ 本地测试

```bash
# 构建前测试
make local-android    # 本地构建 Android
make local-ios        # 本地构建 iOS (需要 macOS)
make local-all        # 构建全部

# 或直接使用脚本
./scripts/test-build-local.sh android
```

---

## ⚙️ 工作流管理

```bash
# 列出所有工作流
gh workflow list
make workflows

# 查看工作流运行
gh workflow view build-android.yml

# 启用/禁用工作流
gh workflow enable build-android.yml
gh workflow disable build-android.yml
```

---

## 🔄 运行管理

```bash
# 取消运行
gh run cancel <run-id>
make cancel RUN=<run-id>

# 重新运行
gh run rerun <run-id>
make rerun RUN=<run-id>

# 查看正在运行的作业
gh run list --status in_progress

# 查看失败的运行
gh run list --status failure
```

---

## 🎨 状态过滤

```bash
# 按状态过滤
gh run list --status completed   # 已完成
gh run list --status in_progress # 进行中
gh run list --status success     # 成功
gh run list --status failure     # 失败

# 按工作流过滤
gh run list --workflow=build-android.yml
gh run list --workflow=build-ios.yml

# 组合使用
gh run list --workflow=build-android.yml --status failure --limit 5
```

---

## 📱 产物类型

### Android
- `app-maven-central-debug` - Debug APK
- `app-maven-central-release` - Release APK

### iOS
- `ios-app-cocoapods` - iOS .app 文件

---

## 🚦 Git 工作流

```bash
# 1. 本地测试
make local-android

# 2. 提交代码
git add .
git commit -m "feat: your changes"

# 3. 推送并监控
make push
# 或分步执行
git push
make status

# 4. 等待构建完成
make watch

# 5. 下载产物
make download RUN=<run-id>
```

---

## 💡 使用技巧

### 1. 创建别名
在 `~/.bashrc` 或 `~/.zshrc` 中添加：

```bash
alias ghs='cd /path/to/project && make status'
alias ghw='cd /path/to/project && make watch'
alias ght='cd /path/to/project && make trigger-all'
```

### 2. 监控特定工作流

```bash
# 只监控 Android
./scripts/monitor-actions.sh --watch build-android.yml

# 只监控 iOS
./scripts/monitor-actions.sh --watch build-ios.yml
```

### 3. 自动刷新

```bash
# 使用 watch 命令每 10 秒刷新
watch -n 10 './scripts/quick-status.sh'
```

---

## ❓ 常见问题

**Q: 如何查看为什么构建失败？**
```bash
gh run view <run-id> --log
```

**Q: 如何下载所有产物到特定目录？**
```bash
gh run download <run-id> --dir ./downloads
```

**Q: 如何只触发特定分支的构建？**
```bash
gh workflow run build-android.yml --ref feature-branch
```

**Q: 如何查看构建需要多长时间？**
```bash
gh run view <run-id>  # 查看 Duration 字段
```

---

## 📚 更多资源

- 完整指南: `docs/GITHUB_ACTIONS_GUIDE.md`
- 配置文档: `docs/CI_CD_SETUP.md`
- GitHub Actions 文档: https://docs.github.com/actions
- gh CLI 手册: https://cli.github.com/manual/

---

## 🎯 最佳实践

1. ✅ **推送前本地测试**: `make local-android`
2. ✅ **定期检查状态**: `make status`
3. ✅ **及时修复失败**: `gh run list --status failure`
4. ✅ **下载重要产物**: `gh run download <run-id>`
5. ✅ **使用持续监控**: `make watch` (关键时刻)

---

**记住**: 当有疑问时，运行 `make help` 或 `./scripts/monitor-actions.sh --help` ！
