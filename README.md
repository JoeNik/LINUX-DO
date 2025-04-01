# LINUX DO 🐧

<p align="center">
  <picture>
    <source 
      srcset="assets/images/dark/logo.webp" 
      media="(prefers-color-scheme: dark)"
    />
    <img 
      src="assets/images/light/logo.webp" 
      width="200" 
      alt="LINUX DO Logo"
    />
  </picture>
</p>

---

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.27.2-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6.1-red.svg)](https://dart.dev)
[![App Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/R-lz/LINUX-DO/main/pubspec.yaml&query=$.version&label=Version&color=orange)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![EN](https://img.shields.io/badge/English-README-blue.svg)](README.en.md)

</div>


## 🌟 这是什么？

使用Flutter开发的LINUX DO客户端,支持 `Android` `IOS`.


## 📦 项目结构

```
lib/
├── 🏛 const/          
├── 🧠 controller/      
├── 🗃 models/         
├── 🌐 net/          
├── 📱 pages/        
├── 🗺 routes/       
├── ⚙️ utils/         
└── 🎨 widgets/       
```

## 🚀 启程指南

### 环境准备

```yaml
必要条件:
  - Flutter: ">=3.0.0 <4.0.0"
  - Dart: ">=3.0.0 <4.0.0"
  - 开发工具: Android Studio / VS Code
  - iOS: Xcode 13.0+（用于iOS开发）
  - Android: Android SDK（用于Android开发）
```

    安装flutter
```bash
# 检查安装结果
flutter --version

# 检查环境
flutter doctor -v
```

### 🎯 开发环境配置

#### 1. 项目获取
```bash
# 克隆项目
git clone https://github.com/R-lz/LINUX-DO.git
cd LINUX-DO

# 安装依赖
flutter pub get
```

#### 2. 代码生成
```bash
# 生成路由、JSON序列化等代码
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 3. 平台特定配置

<details>
<summary>iOS 配置</summary>
</br>

    确保系统中安装了xcode,cocoapods

```bash
# 进入 iOS 目录
cd ios

pod cache clean --all
rm -rf Pods Podfile.lock

pod install --repo-update

cd ..
```
</details>

---


<details>
<summary>Android 配置</summary>
</br>

    确保你的系统中已安装JDK，并配置了环境变量（JAVA_HOME 和 PATH）

#### 生成签名文件
```bash
mkdir -p keystore
```

```bash
keytool -genkey -v -keystore keystore/linux-do.jks -alias mykey -keyalg RSA -keysize 2048 -validity 10000
```

继续交互式
``` bash
Enter keystore password:  [输入 Keystore 密码]
Re-enter new password:   [再次输入确认密码]
What is your first and last name? 
... ...
```
创建key.properties
```bash
touch keystore/key.properties

cat > keystore/key.properties << EOF
storePassword=<你的Keystore密码>
keyPassword=<你的密钥密码>
keyAlias=mykey
storeFile=../keystore/linux-do.jks
EOF
```

</details>


### 🚀 启动项目

#### iOS
```bash
# 开发版本
flutter run -d ios

# 发布版本
flutter build ios --release
```

#### Android
```bash
# 开发版本
flutter run -d android

# 安卓打包
flutter build apk --release --split-per-abi
```


<details>
<summary>使用Github Actions编译打包</summary>

#### Android:
    配置 KEYSTORE_BASE64 | KEY_PROPERTIES

```bash
# 生成base64
base64 -i release.jks
```
配置步骤:
- 打开仓库Settings
- 点击 `Secrets and variables` -> `New repository secret`
- 添加两个Secret
- 添加 Key: `KEYSTORE_BASE64` Value:<生成的base64>
- 添加KEY_PROPERTIES 复制整个`key.properties`文本内容
- 转到Actions运行`build_android`


#### IOS:
    ios为未签名的IPA,直接运行`build_ios`
    
</details>


---


## 🤝 参与贡献

每一个想法都值得被倾听，每一行代码都应该被尊重。

- 发现任何问题或功能上的建议,请通过Issues反馈
- 欢迎提交PR
- 感谢你对项目的贡献！


如果这个项目有帮助到你，请献上你的 Star ⭐️
你的认可，是我们前进的动力。

## 📜 开源协议

本项目采用MIT许可证 - 请参阅[LICENSE](LICENSE)文件以获取详细信息。

# 应用内更新功能

## 功能介绍

应用内更新功能允许应用自动检查新版本并提示用户更新。系统支持以下特性：

- 检查应用最新版本
- 显示版本更新内容
- 支持强制更新和可选更新
- 集成Google Play商店的In-App Update API（Android）
- 引导用户前往App Store（iOS）
- 支持自定义下载链接（针对非商店分发）

## 使用方法

### 后端API

后端提供以下API接口用于检查更新：

```
GET /api/version/check/{platform}
```

**参数：**
- `platform`: 平台标识，可选值为 `android` 或 `ios`
- `current_version`: 当前应用版本号（如"1.0.0"）
- `current_version_code`: 当前应用版本代码（整数）

**返回内容：**
```json
{
    "has_update": true,
    "latest_version": "1.1.0",
    "download_url": "https://example.com/app.apk",
    "release_notes": "- 新增功能A\n- 修复Bug B",
    "is_force_update": false,
    "min_required_version": "1.0.0"
}
```

### 集成说明

1. **初始化**：应用启动时，在`HomeController`中会自动调用`checkAppVersion()`方法检查更新

2. **更新流程**：
   - Android系统会优先使用Google Play的应用内更新机制
   - 如果Google Play不可用或iOS系统，会显示自定义更新对话框
   - 强制更新时用户无法关闭对话框
   
3. **配置参数**：
   - 在`HttpConfig`类中配置iOS App Store ID
   - 通过后端API返回自定义下载链接

## 开发者指南

### 添加依赖

```yaml
dependencies:
  in_app_update: ^4.2.3
  package_info_plus: ^8.0.0
```

### 测试更新

要测试强制更新功能，可以在后端设置：
```json
{
  "is_force_update": true
}
```

对于Android平台，Google Play开发者控制台需进行以下设置：
1. 发布新版本到内部测试轨道
2. 设置更新优先级为"立即更新"

## 注意事项

- Android设备需要安装Google Play服务才能使用Google Play的应用内更新功能
- iOS设备只能引导用户前往App Store，无法在应用内直接更新
- 强制更新功能仅在用户无法继续使用旧版本的场景下使用