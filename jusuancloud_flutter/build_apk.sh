#!/bin/bash

echo "开始构建聚算云Android APK..."

# 检查是否安装了Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter SDK"
    echo "📖 安装指南: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 检查是否安装了Android SDK
if [ -z "$ANDROID_HOME" ]; then
    echo "❌ Android SDK未配置，请设置ANDROID_HOME环境变量"
    exit 1
fi

echo "✅ 开发环境检查通过"

# 清理项目
echo "🧹 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取Flutter依赖..."
flutter pub get

# 检查Flutter状态
echo "🔍 检查Flutter状态..."
flutter doctor

# 构建APK
echo "🔨 开始构建APK..."
flutter build apk --release

# 检查构建结果
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "🎉 APK构建成功！"
    echo "📍 文件位置: build/app/outputs/flutter-apk/app-release.apk"
    
    # 重命名APK
    cp build/app/outputs/flutter-apk/app-release.apk "聚算云_v1.0.5_Android.apk"
    echo "📦 已重命名为: 聚算云_v1.0.5_Android.apk"
    
    # 显示文件信息
    echo "📊 APK文件信息:"
    ls -lh "聚算云_v1.0.5_Android.apk"
    
else
    echo "❌ APK构建失败"
    exit 1
fi

echo "✨ 构建完成！"