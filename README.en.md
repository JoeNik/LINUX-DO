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

## 📝 Description

The LINUX DO client developed using Flutter supports `Android` and `IOS`.

## ✨ Features

- Modern, intuitive user interface with dark and light themes
- Real-time discussions and notifications
- Offline reading capability
- Rich text editor for posting
- Media sharing (images, code snippets)
- User profiles and activity tracking
- Search functionality

## 📦 Project Structure

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

## 🔧 Installation

<details>
<summary><b>Requirements</b></summary>

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Development tools: Android Studio / VS Code
- iOS: Xcode 13.0+ (for iOS development)
- Android: Android SDK (for Android development)

```bash
# Verify Flutter is correctly installed
flutter --version

# Check your environment
flutter doctor -v
```
</details>

<details>
<summary><b>Setup Instructions</b></summary>
</br>

```bash
# Clone the repository
git clone https://github.com/R-lz/LINUX-DO.git
cd LINUX-DO

# Install dependencies
flutter pub get

# Generate code (routes, JSON serialization, etc.)
flutter pub run build_runner build --delete-conflicting-outputs
```
</details>

## ⚙️ Configuration

<details>
<summary><b>iOS Setup</b></summary>
</br>

    Make sure you have Xcode and CocoaPods installed

```bash
# Navigate to iOS directory
cd ios

# Clean CocoaPods cache
pod cache clean --all
rm -rf Pods Podfile.lock

# Install CocoaPods dependencies
pod install --repo-update

# Return to project root
cd ..
```

```bash
# Run in development mode
flutter run -d ios

# Build release version
flutter build ios --release
```
</details>

<details>
<summary><b>Android Setup</b></summary>
</br>

    Make sure you have JDK installed and environment variables (JAVA_HOME and PATH) configured

#### Generate signing key
```bash
mkdir -p keystore

keytool -genkey -v -keystore keystore/linux-do.jks -alias mykey -keyalg RSA -keysize 2048 -validity 10000
```

Follow the interactive prompts:
```bash
Enter keystore password:  [Enter Keystore password]
Re-enter new password:   [Re-enter the password]
What is your first and last name? 
... ...
```

Create key.properties file:
```bash
touch keystore/key.properties

cat > keystore/key.properties << EOF
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=mykey
storeFile=../keystore/linux-do.jks
EOF
```

```bash
# Run in development mode
flutter run -d android

# Build release APK
flutter build apk --release --split-per-abi
```
</details>

<details>
<summary><b>GitHub Actions CI/CD</b></summary>

#### For Android:
> Configure KEYSTORE_BASE64 and KEY_PROPERTIES secrets

```bash
# Generate base64 encoded keystore
base64 -i release.jks
```

Configuration steps:
- Open repository Settings
- Click `Secrets and variables` -> `New repository secret`
- Add two secrets:
  - Key: `KEYSTORE_BASE64` Value: <generated base64>
  - Key: `KEY_PROPERTIES` Value: <entire key.properties content>
- Go to Actions and run `build_android`

#### For iOS:
> Run `build_ios` directly (produces unsigned IPA)
</details>

## 🤝 Contributing

Every idea deserves to be heard, every line of code deserves respect.

- For feature suggestions or issues, please provide feedback through Issues
- Pull requests are welcome
- Thank you for your contributions!

If this project has helped you, please give it a Star ⭐️
Your recognition is our motivation to move forward.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 