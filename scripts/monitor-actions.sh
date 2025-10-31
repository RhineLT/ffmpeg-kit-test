#!/bin/bash

# GitHub Actions 监控脚本
# 使用 gh CLI 监控构建状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查 gh CLI 是否已安装
if ! command -v gh &> /dev/null; then
    echo -e "${RED}错误: gh CLI 未安装${NC}"
    echo "请访问 https://cli.github.com/ 安装 gh CLI"
    exit 1
fi

# 检查是否已认证
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}警告: gh CLI 未认证${NC}"
    echo "请运行: gh auth login"
    exit 1
fi

# 显示帮助信息
show_help() {
    echo "GitHub Actions 监控脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示帮助信息"
    echo "  -l, --list              列出所有工作流"
    echo "  -w, --watch [workflow]  监控特定工作流 (默认: 所有)"
    echo "  -r, --runs [n]          显示最近 n 次运行 (默认: 5)"
    echo "  -s, --status            显示当前工作流状态"
    echo "  -f, --follow            持续监控模式 (每30秒刷新)"
    echo ""
    echo "示例:"
    echo "  $0 --list                      # 列出所有工作流"
    echo "  $0 --status                    # 显示当前状态"
    echo "  $0 --watch build-android.yml   # 监控 Android 构建"
    echo "  $0 --follow                    # 持续监控所有工作流"
}

# 列出所有工作流
list_workflows() {
    echo -e "${BLUE}=== 可用的工作流 ===${NC}"
    gh workflow list
}

# 显示工作流运行状态
show_status() {
    local workflow=$1
    local limit=${2:-5}
    
    if [ -z "$workflow" ]; then
        echo -e "${BLUE}=== 所有工作流的最近运行状态 ===${NC}"
        gh run list --limit "$limit"
    else
        echo -e "${BLUE}=== 工作流 '$workflow' 的最近运行状态 ===${NC}"
        gh run list --workflow="$workflow" --limit "$limit"
    fi
}

# 显示详细的运行信息
show_run_details() {
    local run_id=$1
    echo -e "${BLUE}=== 运行详情 (ID: $run_id) ===${NC}"
    gh run view "$run_id"
}

# 监控模式
watch_mode() {
    local workflow=$1
    local interval=${2:-30}
    
    echo -e "${GREEN}开始监控模式...${NC}"
    echo -e "${YELLOW}按 Ctrl+C 退出${NC}"
    echo ""
    
    while true; do
        clear
        echo -e "${BLUE}=== GitHub Actions 状态监控 ===${NC}"
        echo -e "${YELLOW}刷新时间: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
        echo ""
        
        # 显示工作流状态
        if [ -z "$workflow" ]; then
            echo -e "${BLUE}--- 所有工作流 ---${NC}"
            gh run list --limit 10
        else
            echo -e "${BLUE}--- 工作流: $workflow ---${NC}"
            gh run list --workflow="$workflow" --limit 10
        fi
        
        echo ""
        echo -e "${BLUE}--- 当前正在运行的作业 ---${NC}"
        gh run list --status in_progress --limit 5 2>/dev/null || echo "无正在运行的作业"
        
        echo ""
        echo -e "${YELLOW}下次刷新: ${interval}秒后... (按 Ctrl+C 退出)${NC}"
        sleep "$interval"
    done
}

# 显示构建摘要
show_build_summary() {
    echo -e "${BLUE}=== 构建摘要 ===${NC}"
    echo ""
    
    echo -e "${GREEN}Android 构建:${NC}"
    gh run list --workflow="build-android.yml" --limit 1 2>/dev/null || echo "  未找到构建记录"
    
    echo ""
    echo -e "${GREEN}iOS 构建:${NC}"
    gh run list --workflow="build-ios.yml" --limit 1 2>/dev/null || echo "  未找到构建记录"
    
    echo ""
    echo -e "${BLUE}最近的失败构建:${NC}"
    gh run list --status failure --limit 3 2>/dev/null || echo "  无失败记录"
}

# 主逻辑
main() {
    if [ $# -eq 0 ]; then
        show_build_summary
        exit 0
    fi
    
    case "$1" in
        -h|--help)
            show_help
            ;;
        -l|--list)
            list_workflows
            ;;
        -w|--watch)
            show_status "$2" "${3:-5}"
            ;;
        -s|--status)
            show_build_summary
            ;;
        -f|--follow)
            watch_mode "$2" 30
            ;;
        -r|--runs)
            show_status "" "$2"
            ;;
        *)
            echo -e "${RED}未知选项: $1${NC}"
            echo "使用 --help 查看帮助信息"
            exit 1
            ;;
    esac
}

main "$@"
