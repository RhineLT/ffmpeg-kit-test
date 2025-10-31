#!/bin/bash

# 简化版 GitHub Actions 快速监控脚本

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           GitHub Actions 构建状态监控                          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查 gh CLI
if ! command -v gh &> /dev/null; then
    echo -e "${RED}✗ gh CLI 未安装${NC}"
    exit 1
fi

# 显示 Android 构建状态
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📱 Android 构建状态${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
gh run list --workflow=build-android.yml --limit 3 2>/dev/null || echo -e "${YELLOW}  暂无构建记录${NC}"
echo ""

# 显示 iOS 构建状态
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🍎 iOS 构建状态${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
gh run list --workflow=build-ios.yml --limit 3 2>/dev/null || echo -e "${YELLOW}  暂无构建记录${NC}"
echo ""

# 显示正在运行的作业
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚡ 正在运行的作业${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
RUNNING=$(gh run list --status in_progress --limit 5 2>/dev/null)
if [ -n "$RUNNING" ]; then
    echo "$RUNNING"
else
    echo -e "${GREEN}  ✓ 当前无正在运行的作业${NC}"
fi
echo ""

# 显示最近的失败
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}❌ 最近的失败构建${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
FAILURES=$(gh run list --status failure --limit 3 2>/dev/null)
if [ -n "$FAILURES" ]; then
    echo "$FAILURES"
else
    echo -e "${GREEN}  ✓ 最近无失败记录${NC}"
fi
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}💡 提示:${NC}"
echo -e "  • 查看详情: ${BLUE}gh run view <run-id>${NC}"
echo -e "  • 下载产物: ${BLUE}gh run download <run-id>${NC}"
echo -e "  • 实时监控: ${BLUE}gh run watch${NC}"
echo -e "  • 触发构建: ${BLUE}gh workflow run build-android.yml${NC}"
echo -e "  • 完整监控: ${BLUE}./scripts/monitor-actions.sh --follow${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
