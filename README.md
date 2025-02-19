# LINUX DO 🐧


<p align="center">
  <img src="assets/images/light/search-banner.png" width="100%" alt="LINUX DO Logo">
</p>

<p align="center">
  <img src="assets/images/light/logo.webp" width="200" alt="LINUX DO Logo">
</p>

> 在这个数字化的星球上，我们正在构建一个独特的技术乌托邦。
> 
> "真诚、友善、团结、专业，共建你我引以为荣之社区。" （ 虽然有点严肃，但我们是认真的！）

## 🌟 这是什么？

在这个信息爆炸的时代，我们不缺乏社区，但我们缺少一个真正懂技术人的家。LINUX DO 连接技术灵魂的桥梁.... 咳咳,这是一个使用Flutter开发的(套壳儿的)LINUX DO ()社区。理论支持其他Discourse部署的社区。



## 🛠 技术栈


```dart
class TechnologyStack {
  final framework = "Flutter 3.0+";  
  final stateManagement = "GetX";    
  final networking = "Dio";  
  final ui = {
    "设计语言": "Material You",
    "适配框架": "flutter_screenutil",
    "动画系统": "自研引擎"
  };
  final api = "LINUX DO API";
  ... ...
}
```

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
  - CocoaPods: ">=1.11.0" (仅 iOS/macOS)
  - Android SDK: ">=31" (仅 Android)
  - Xcode: ">=13.0" (仅 iOS/macOS)
```

### 🎯 开发环境配置

#### 1. 项目获取
```bash
# 克隆项目
git clone https://github.com/R-lz/Linux-DO.git
cd linux-do

# 安装依赖
flutter pub get
```

#### 2. 代码生成
```bash
# 生成路由、JSON序列化等代码
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 3. 平台特定配置

##### iOS/macOS 配置
```bash
# 进入 iOS 目录
cd ios

# 清理 CocoaPods 缓存
pod cache clean --all
rm -rf Pods Podfile.lock

# 安装 CocoaPods 依赖
pod install --repo-update

# 返回项目根目录
cd ..
```

##### Android 配置
1. 打开 `android/app/build.gradle`
2. 配置应用信息：
```gradle
android {
    defaultConfig {
        applicationId "xxx.xxx"
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

### 🚀 启动项目

#### iOS
```bash
# 开发版本
flutter run -d ios

# 发布版本
flutter build ios --release
flutter build ipa --release
```

#### Android
```bash
# 开发版本
flutter run -d android

# 发布版本
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

#### macOS
```bash
# 开发版本
flutter run -d macos

# 发布版本
flutter build macos --release
```

## 🤝 参与贡献

每一个想法都值得被倾听，每一行代码都应该被尊重。

1. Fork 项目
2. 创建分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add some amazing feature'`
4. 推送分支：`git push origin feature/amazing-feature`
5. 提交 Pull Request


## 🎭 写在最后

> 项目还在开发中，距离正式版还有很多需要改进的地方。所以如果你对项目有任何建议、意见或者想法，欢迎提交PR，本项目的每一行代码都承载着对L站的热爱。
> 每一个小小的贡献都会让它变得更接近理想。很期待能有你的加入，一起改进、一起成长。

---

如果这个项目让你感到愉悦，请献上你的 Star ⭐️
你的认可，是我(们)前进的动力。


## 📜 开源协议

本项目采用MIT许可证 - 请参阅[LICENSE](LICENSE)文件以获取详细信息。