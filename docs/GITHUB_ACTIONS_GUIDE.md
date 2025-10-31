# GitHub Actions 构建与监控指南

本文档说明如何使用 GitHub Actions 自动构建 Android 和 iOS 应用，以及如何使用 `gh` CLI 监控构建状态。

## 📋 目录

- [工作流说明](#工作流说明)
- [触发构建](#触发构建)
- [监控构建状态](#监控构建状态)
- [下载构建产物](#下载构建产物)
- [故障排查](#故障排查)

## 🔧 工作流说明

### Android 构建 (`build-android.yml`)

- **运行环境**: Ubuntu Latest
- **JDK 版本**: 17 (Temurin)
- **构建目标**: 
  - `test-app-maven-central` (Debug 和 Release)
- **产物**: APK 文件
- **保留时间**: 7 天

### iOS 构建 (`build-ios.yml`)

- **运行环境**: macOS Latest
- **Xcode 版本**: 15.2
- **构建目标**: 
  - `test-app-cocoapods` (使用 CocoaPods)
- **产物**: .app 文件
- **保留时间**: 7 天
- **注意**: 不包含代码签名（仅用于 CI 构建）

## 🚀 触发构建

### 自动触发

工作流会在以下情况自动触发：

1. **推送到主分支或开发分支**
   ```bash
   git push origin main
   git push origin develop
   ```

2. **创建 Pull Request 到主分支**
   ```bash
   gh pr create --base main --head your-branch
   ```

### 手动触发

使用 GitHub 网页界面或 `gh` CLI：

```bash
# 触发 Android 构建
gh workflow run build-android.yml

# 触发 iOS 构建
gh workflow run build-ios.yml

# 触发特定分支的构建
gh workflow run build-android.yml --ref develop
```

## 📊 监控构建状态

### 使用监控脚本

我们提供了一个便捷的监控脚本 `scripts/monitor-actions.sh`：

#### 1. 安装 gh CLI

如果尚未安装：

```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

#### 2. 认证 gh CLI

```bash
gh auth login
```

#### 3. 使用监控脚本

```bash
# 显示构建摘要
./scripts/monitor-actions.sh

# 列出所有工作流
./scripts/monitor-actions.sh --list

# 显示所有工作流状态
./scripts/monitor-actions.sh --status

# 监控特定工作流
./scripts/monitor-actions.sh --watch build-android.yml

# 持续监控模式（每30秒刷新）
./scripts/monitor-actions.sh --follow

# 显示最近 10 次运行
./scripts/monitor-actions.sh --runs 10

# 显示帮助
./scripts/monitor-actions.sh --help
```

### 使用 gh CLI 直接命令

```bash
# 查看所有工作流运行
gh run list

# 查看特定工作流
gh run list --workflow=build-android.yml

# 查看正在运行的作业
gh run list --status in_progress

# 查看失败的运行
gh run list --status failure

# 查看特定运行的详情
gh run view <run-id>

# 实时查看运行日志
gh run watch

# 查看特定运行的日志
gh run view <run-id> --log
```

## 📦 下载构建产物

### 使用 gh CLI

```bash
# 列出最近运行的产物
gh run list --limit 5

# 下载特定运行的所有产物
gh run download <run-id>

# 下载特定产物
gh run download <run-id> --name app-maven-central-debug

# 下载到指定目录
gh run download <run-id> --dir ./downloads
```

### 使用 GitHub 网页界面

1. 访问仓库的 Actions 页面
2. 选择对应的工作流运行
3. 在页面底部的 "Artifacts" 部分下载

## 🎯 可用的产物

### Android

- `app-maven-central-debug`: Debug 版本 APK
- `app-maven-central-release`: Release 版本 APK

### iOS

- `ios-app-cocoapods`: iOS .app 文件

## 🔍 故障排查

### Android 构建失败

1. **检查 Gradle 版本兼容性**
   ```bash
   cd android
   ./gradlew --version
   ```

2. **清理并重新构建**
   ```bash
   cd android
   ./gradlew clean
   ./gradlew build
   ```

3. **检查依赖问题**
   ```bash
   cd android
   ./gradlew dependencies
   ```

### iOS 构建失败

1. **检查 CocoaPods**
   ```bash
   cd ios/test-app-cocoapods
   pod --version
   pod install --repo-update
   ```

2. **检查 Xcode 版本**
   ```bash
   xcodebuild -version
   ```

3. **清理构建缓存**
   ```bash
   cd ios/test-app-cocoapods
   rm -rf build
   xcodebuild clean
   ```

### 查看详细日志

```bash
# 查看特定运行的完整日志
gh run view <run-id> --log

# 查看特定作业的日志
gh run view <run-id> --job <job-id> --log

# 实时跟踪日志
gh run watch <run-id>
```

## 📈 监控最佳实践

1. **设置通知**: 在 GitHub 仓库设置中配置 Actions 失败通知
2. **定期检查**: 使用持续监控模式关注关键构建
3. **分析趋势**: 定期查看失败构建的历史记录
4. **快速响应**: 构建失败时立即查看日志并修复

## 🔗 相关链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [GitHub CLI 文档](https://cli.github.com/manual/)
- [FFmpegKit 官方仓库](https://github.com/arthenica/ffmpeg-kit)

## 📝 快速参考

### 常用命令速查

```bash
# 监控
./scripts/monitor-actions.sh --follow          # 持续监控
gh run watch                                    # 实时监控最新运行

# 触发构建
gh workflow run build-android.yml              # 触发 Android 构建
gh workflow run build-ios.yml                  # 触发 iOS 构建

# 查看状态
gh run list --limit 5                          # 最近 5 次运行
gh run list --status failure                   # 失败的运行

# 下载产物
gh run download <run-id>                       # 下载所有产物
gh run download <run-id> --name <artifact>     # 下载特定产物

# 查看日志
gh run view <run-id> --log                     # 查看完整日志
gh run view <run-id> --web                     # 在浏览器中打开
```

---

**注意**: 确保你有适当的权限访问仓库的 Actions 和产物。
