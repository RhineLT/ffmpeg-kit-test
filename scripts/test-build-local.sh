#!/bin/bash

# 本地构建测试脚本 - 在推送前验证构建

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              本地构建测试 - Android & iOS                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查参数
BUILD_ANDROID=false
BUILD_IOS=false

if [ "$#" -eq 0 ]; then
    echo -e "${YELLOW}用法: $0 [android|ios|all]${NC}"
    echo ""
    echo "选项:"
    echo "  android  - 仅构建 Android"
    echo "  ios      - 仅构建 iOS"
    echo "  all      - 构建全部"
    exit 1
fi

case "$1" in
    android)
        BUILD_ANDROID=true
        ;;
    ios)
        BUILD_IOS=true
        ;;
    all)
        BUILD_ANDROID=true
        BUILD_IOS=true
        ;;
    *)
        echo -e "${RED}错误: 未知选项 '$1'${NC}"
        exit 1
        ;;
esac

# 构建 Android
if [ "$BUILD_ANDROID" = true ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📱 开始构建 Android 应用...${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    cd android
    
    # 检查 Java 版本
    echo -e "${BLUE}检查 Java 版本...${NC}"
    java -version
    
    # 清理
    echo -e "${BLUE}清理旧构建...${NC}"
    ./gradlew clean
    
    # 构建 Debug
    echo -e "${BLUE}构建 test-app-maven-central (Debug)...${NC}"
    ./gradlew :test-app-maven-central:assembleDebug
    
    # 构建 Release
    echo -e "${BLUE}构建 test-app-maven-central (Release)...${NC}"
    ./gradlew :test-app-maven-central:assembleRelease
    
    echo -e "${GREEN}✓ Android 构建成功！${NC}"
    echo ""
    echo -e "${BLUE}构建产物位置:${NC}"
    find test-app-maven-central/build/outputs/apk -name "*.apk" -exec echo "  - {}" \;
    echo ""
    
    cd ..
fi

# 构建 iOS
if [ "$BUILD_IOS" = true ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🍎 开始构建 iOS 应用...${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 检查操作系统
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${YELLOW}⚠ 警告: iOS 构建需要在 macOS 上运行${NC}"
        echo -e "${YELLOW}跳过 iOS 构建...${NC}"
    else
        cd ios/test-app-cocoapods
        
        # 显示 Xcode 版本
        echo -e "${BLUE}检查 Xcode 版本...${NC}"
        xcodebuild -version
        
        # 安装 CocoaPods 依赖
        echo -e "${BLUE}安装 CocoaPods 依赖...${NC}"
        pod install --repo-update
        
        # 构建
        echo -e "${BLUE}构建 FFmpegKitIOS...${NC}"
        xcodebuild -workspace FFmpegKitIOS.xcworkspace \
            -scheme FFmpegKitIOS \
            -configuration Release \
            -sdk iphoneos \
            -derivedDataPath build \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGN_IDENTITY="" \
            | xcpretty || xcodebuild -workspace FFmpegKitIOS.xcworkspace \
            -scheme FFmpegKitIOS \
            -configuration Release \
            -sdk iphoneos \
            -derivedDataPath build \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGN_IDENTITY=""
        
        echo -e "${GREEN}✓ iOS 构建成功！${NC}"
        echo ""
        echo -e "${BLUE}构建产物位置:${NC}"
        find build/Build/Products -name "*.app" -exec echo "  - {}" \; 2>/dev/null || echo "  构建产物在 build/ 目录中"
        echo ""
        
        cd ../..
    fi
fi

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 构建测试完成！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}💡 下一步:${NC}"
echo -e "  1. 检查构建产物"
echo -e "  2. 如果一切正常，提交代码: ${YELLOW}git add . && git commit -m 'your message'${NC}"
echo -e "  3. 推送到仓库: ${YELLOW}git push${NC}"
echo -e "  4. 使用以下命令监控 CI 构建: ${YELLOW}./scripts/quick-status.sh${NC}"
echo ""
