#!/bin/bash

# 设置错误时退出
set -e

# 定义颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 输出带颜色的信息函数
print_message() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# 检查是否安装了 Flutter
if ! command -v flutter &> /dev/null; then
    echo "Flutter 未安装，请先安装 Flutter"
    exit 1
fi

# 清理旧的构建文件
print_message "清理旧的构建文件..."
flutter clean

# 获取依赖
print_message "获取 Flutter 依赖..."
flutter pub get

# 构建 iOS 版本
print_message "开始构建 iOS 版本..."
flutter build ios --release --no-codesign

# 创建输出目录
OUTPUT_DIR="build/ios/unsigned_ipa"
mkdir -p "$OUTPUT_DIR"

# 创建 Payload 目录
print_message "创建 Payload 目录..."
mkdir -p "build/ios/unsigned_ipa/Payload"

# 复制 .app 文件到 Payload 目录
print_message "复制 .app 文件..."
cp -r "build/ios/iphoneos/Runner.app" "build/ios/unsigned_ipa/Payload"

# 切换到输出目录
cd "$OUTPUT_DIR"

# 打包成 .ipa 文件
print_message "正在打包 IPA..."
zip -r "unsigned_app.ipa" "Payload"

# 清理临时文件
print_message "清理临时文件..."
rm -rf "Payload"

print_message "构建完成！"
print_message "无签名 IPA 文件位置: ${PWD}/unsigned_app.ipa"

# 检查文件是否存在
if [ -f "unsigned_app.ipa" ]; then
    print_message "✅ IPA 文件生成成功"
else
    print_warning "❌ IPA 文件生成失败"
    exit 1
fi
