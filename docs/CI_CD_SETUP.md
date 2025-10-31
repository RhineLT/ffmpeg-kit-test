# GitHub Actions CI/CD 配置完成

## 📦 已创建的文件

### 1. GitHub Actions 工作流

#### `.github/workflows/build-android.yml`
- **功能**: 自动构建 Android 应用
- **触发条件**: 
  - 推送到 `main` 或 `develop` 分支
  - Pull Request 到 `main` 分支
  - 手动触发
- **构建产物**: 
  - `app-maven-central-debug` (Debug APK)
  - `app-maven-central-release` (Release APK)

#### `.github/workflows/build-ios.yml`
- **功能**: 自动构建 iOS 应用
- **触发条件**: 
  - 推送到 `main` 或 `develop` 分支
  - Pull Request 到 `main` 分支
  - 手动触发
- **构建产物**: 
  - `ios-app-cocoapods` (iOS .app 文件)

### 2. 监控脚本

#### `scripts/quick-status.sh` ⭐ 推荐
**快速状态查看工具** - 最常用的监控脚本

```bash
./scripts/quick-status.sh
```

**显示内容**:
- ✅ Android 构建状态（最近 3 次）
- ✅ iOS 构建状态（最近 3 次）
- ✅ 正在运行的作业
- ✅ 最近的失败构建
- ✅ 常用命令提示

#### `scripts/monitor-actions.sh`
**完整功能监控工具** - 高级监控功能

```bash
# 显示帮助
./scripts/monitor-actions.sh --help

# 列出所有工作流
./scripts/monitor-actions.sh --list

# 显示构建摘要
./scripts/monitor-actions.sh --status

# 监控特定工作流
./scripts/monitor-actions.sh --watch build-android.yml

# 持续监控模式（每30秒刷新）
./scripts/monitor-actions.sh --follow

# 显示最近 N 次运行
./scripts/monitor-actions.sh --runs 10
```

#### `scripts/test-build-local.sh`
**本地构建测试工具** - 推送前验证

```bash
# 构建 Android
./scripts/test-build-local.sh android

# 构建 iOS（需要 macOS）
./scripts/test-build-local.sh ios

# 构建全部
./scripts/test-build-local.sh all
```

### 3. 文档

#### `docs/GITHUB_ACTIONS_GUIDE.md`
完整的 GitHub Actions 使用指南，包含：
- 工作流详细说明
- 触发构建方法
- 监控命令参考
- 下载产物指南
- 故障排查步骤
- 快速参考命令

#### `README.md` (已更新)
主 README 添加了 CI/CD 部分，快速链接到工作流和监控工具。

---

## 🚀 快速开始

### 第一步：验证 gh CLI

```bash
gh --version
gh auth status
```

如果未认证，运行：
```bash
gh auth login
```

### 第二步：查看当前状态

```bash
./scripts/quick-status.sh
```

### 第三步：手动触发构建（可选）

```bash
# 触发 Android 构建
gh workflow run build-android.yml

# 触发 iOS 构建
gh workflow run build-ios.yml
```

### 第四步：监控构建

```bash
# 简单查看
./scripts/quick-status.sh

# 持续监控
./scripts/monitor-actions.sh --follow

# 或使用 gh 原生命令
gh run watch
```

### 第五步：下载构建产物

```bash
# 列出最近的运行
gh run list --limit 5

# 下载特定运行的产物
gh run download <run-id>

# 下载特定产物到指定目录
gh run download <run-id> --name app-maven-central-debug --dir ./downloads
```

---

## 📊 工作流程图

```
┌─────────────────┐
│  代码推送/PR    │
└────────┬────────┘
         │
         ├─────────────────────────────────────┐
         │                                     │
         ▼                                     ▼
┌─────────────────┐                  ┌─────────────────┐
│  Android 构建    │                  │   iOS 构建      │
│  ├─ JDK 17      │                  │  ├─ Xcode 15.2  │
│  ├─ Gradle      │                  │  ├─ CocoaPods   │
│  └─ APK 生成    │                  │  └─ .app 生成   │
└────────┬────────┘                  └────────┬────────┘
         │                                     │
         ├─────────────────┬───────────────────┤
         │                 │                   │
         ▼                 ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Debug APK      │ │  Release APK    │ │   iOS .app      │
└─────────────────┘ └─────────────────┘ └─────────────────┘
         │                 │                   │
         └─────────────────┴───────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  产物上传至      │
                  │  GitHub Actions  │
                  │  保留 7 天       │
                  └─────────────────┘
```

---

## 🔍 监控命令速查表

| 需求 | 命令 |
|------|------|
| 快速查看状态 | `./scripts/quick-status.sh` |
| 持续监控 | `./scripts/monitor-actions.sh --follow` |
| 列出所有运行 | `gh run list` |
| 查看正在运行 | `gh run list --status in_progress` |
| 查看失败运行 | `gh run list --status failure` |
| 查看运行详情 | `gh run view <run-id>` |
| 查看日志 | `gh run view <run-id> --log` |
| 实时跟踪 | `gh run watch` |
| 下载产物 | `gh run download <run-id>` |
| 触发 Android | `gh workflow run build-android.yml` |
| 触发 iOS | `gh workflow run build-ios.yml` |
| 列出工作流 | `gh workflow list` |
| 本地测试构建 | `./scripts/test-build-local.sh android` |

---

## ⚙️ 高级配置

### 修改构建触发条件

编辑 `.github/workflows/build-*.yml`，修改 `on` 部分：

```yaml
on:
  push:
    branches: [ main, develop, feature/* ]  # 添加更多分支
  pull_request:
    branches: [ main, develop ]
  schedule:
    - cron: '0 0 * * 0'  # 每周日午夜运行
  workflow_dispatch:  # 允许手动触发
```

### 添加构建通知

可以在工作流中添加 Slack、Discord 或邮件通知步骤。

### 增加产物保留时间

修改 `retention-days` 值：

```yaml
- name: Upload APK artifacts
  uses: actions/upload-artifact@v4
  with:
    name: app-debug
    path: android/test-app-maven-central/build/outputs/apk/debug/*.apk
    retention-days: 30  # 从 7 天改为 30 天
```

---

## 🐛 常见问题

### Q: 构建失败了怎么办？
A: 
1. 运行 `./scripts/quick-status.sh` 查看状态
2. 使用 `gh run view <run-id> --log` 查看详细日志
3. 使用 `./scripts/test-build-local.sh` 在本地复现问题

### Q: 如何只构建 Android 而不构建 iOS？
A: 
- 方法 1: 手动触发特定工作流 `gh workflow run build-android.yml`
- 方法 2: 创建 Pull Request 时只修改 Android 相关文件

### Q: 产物在哪里下载？
A: 
1. GitHub 网页: Actions → 选择运行 → 页面底部 Artifacts
2. CLI: `gh run download <run-id>`

### Q: 如何查看历史构建记录？
A: 
```bash
gh run list --limit 50  # 查看最近 50 次运行
```

---

## 📞 获取帮助

- 查看 [GitHub Actions 文档](https://docs.github.com/en/actions)
- 查看 [gh CLI 文档](https://cli.github.com/manual/)
- 查看项目详细指南: `docs/GITHUB_ACTIONS_GUIDE.md`

---

**提示**: 所有监控脚本都已设置可执行权限，可直接运行。
