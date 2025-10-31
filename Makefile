.PHONY: help status watch trigger-android trigger-ios download list local-android local-ios logs

# 默认目标
help:
	@echo "GitHub Actions CI/CD 管理命令"
	@echo ""
	@echo "监控命令:"
	@echo "  make status          - 显示构建状态概览"
	@echo "  make watch           - 持续监控所有工作流"
	@echo "  make list            - 列出所有工作流运行"
	@echo "  make logs RUN=<id>   - 查看特定运行的日志"
	@echo ""
	@echo "触发命令:"
	@echo "  make trigger-android - 触发 Android 构建"
	@echo "  make trigger-ios     - 触发 iOS 构建"
	@echo "  make trigger-all     - 触发所有构建"
	@echo ""
	@echo "产物命令:"
	@echo "  make download RUN=<id> - 下载构建产物"
	@echo "  make artifacts         - 列出可用产物"
	@echo ""
	@echo "本地测试:"
	@echo "  make local-android   - 本地构建 Android"
	@echo "  make local-ios       - 本地构建 iOS"
	@echo "  make local-all       - 本地构建全部"
	@echo ""
	@echo "示例:"
	@echo "  make status                    # 快速查看状态"
	@echo "  make trigger-android           # 触发 Android 构建"
	@echo "  make download RUN=123456789    # 下载特定运行的产物"
	@echo "  make logs RUN=123456789        # 查看运行日志"

# 监控命令
status:
	@./scripts/quick-status.sh

watch:
	@./scripts/monitor-actions.sh --follow

list:
	@gh run list --limit 10

logs:
ifndef RUN
	@echo "错误: 请指定运行 ID"
	@echo "用法: make logs RUN=<run-id>"
	@echo "使用 'make list' 查看可用的运行 ID"
else
	@gh run view $(RUN) --log
endif

# 触发命令
trigger-android:
	@echo "触发 Android 构建..."
	@gh workflow run build-android.yml
	@echo "✓ 已触发 Android 构建"
	@echo "使用 'make status' 查看状态"

trigger-ios:
	@echo "触发 iOS 构建..."
	@gh workflow run build-ios.yml
	@echo "✓ 已触发 iOS 构建"
	@echo "使用 'make status' 查看状态"

trigger-all: trigger-android trigger-ios
	@echo ""
	@echo "✓ 已触发所有构建"

# 产物命令
download:
ifndef RUN
	@echo "错误: 请指定运行 ID"
	@echo "用法: make download RUN=<run-id>"
	@echo "使用 'make list' 查看可用的运行 ID"
else
	@echo "下载运行 $(RUN) 的产物..."
	@gh run download $(RUN)
	@echo "✓ 产物已下载"
endif

artifacts:
	@echo "最近运行的产物:"
	@gh run list --limit 5

# 本地测试
local-android:
	@./scripts/test-build-local.sh android

local-ios:
	@./scripts/test-build-local.sh ios

local-all:
	@./scripts/test-build-local.sh all

# 实时监控（打开浏览器）
web:
	@gh run list --web

# 查看工作流状态
workflows:
	@gh workflow list

# 取消运行
cancel:
ifndef RUN
	@echo "错误: 请指定运行 ID"
	@echo "用法: make cancel RUN=<run-id>"
else
	@gh run cancel $(RUN)
	@echo "✓ 已取消运行 $(RUN)"
endif

# 重新运行失败的作业
rerun:
ifndef RUN
	@echo "错误: 请指定运行 ID"
	@echo "用法: make rerun RUN=<run-id>"
else
	@gh run rerun $(RUN)
	@echo "✓ 已重新运行 $(RUN)"
endif

# 查看特定工作流
watch-android:
	@./scripts/monitor-actions.sh --watch build-android.yml

watch-ios:
	@./scripts/monitor-actions.sh --watch build-ios.yml

# 清理本地构建
clean:
	@echo "清理本地构建产物..."
	@cd android && ./gradlew clean || true
	@rm -rf ios/test-app-cocoapods/build || true
	@echo "✓ 清理完成"

# 查看 gh 认证状态
auth:
	@gh auth status

# 快速推送并监控
push:
	@echo "推送代码到远程仓库..."
	@git push
	@echo ""
	@echo "等待 3 秒后开始监控..."
	@sleep 3
	@./scripts/quick-status.sh
