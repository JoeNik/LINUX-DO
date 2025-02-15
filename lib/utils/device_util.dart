import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceUtil {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static PackageInfo? _packageInfo;

  /// 初始化
  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 获取应用包名
  static String get packageName => _packageInfo?.packageName ?? '';

  /// 获取应用版本号
  static String get version => _packageInfo?.version ?? '';

  /// 获取应用构建号
  static String get buildNumber => _packageInfo?.buildNumber ?? '';

  /// 获取应用名称
  static String get appName => _packageInfo?.appName ?? '';

  /// 是否是Android设备
  static bool get isAndroid => Platform.isAndroid;

  /// 是否是iOS设备
  static bool get isIOS => Platform.isIOS;

  /// 是否是Web
  static bool get isWeb => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// 获取Android设备信息
  static Future<AndroidDeviceInfo> getAndroidDeviceInfo() async {
    return await _deviceInfo.androidInfo;
  }

  /// 获取iOS设备信息
  static Future<IosDeviceInfo> getIOSDeviceInfo() async {
    return await _deviceInfo.iosInfo;
  }

  /// 获取设备唯一标识
  static Future<String> getDeviceId() async {
    if (isAndroid) {
      final androidInfo = await getAndroidDeviceInfo();
      return androidInfo.id;
    } else if (isIOS) {
      final iosInfo = await getIOSDeviceInfo();
      return iosInfo.identifierForVendor ?? '';
    }
    return '';
  }

  /// 获取设备名称
  static Future<String> getDeviceName() async {
    if (isAndroid) {
      final androidInfo = await getAndroidDeviceInfo();
      return androidInfo.model;
    } else if (isIOS) {
      final iosInfo = await getIOSDeviceInfo();
      return iosInfo.name;
    }
    return '';
  }

  /// 获取系统版本
  static Future<String> getSystemVersion() async {
    if (isAndroid) {
      final androidInfo = await getAndroidDeviceInfo();
      return androidInfo.version.release;
    } else if (isIOS) {
      final iosInfo = await getIOSDeviceInfo();
      return iosInfo.systemVersion;
    }
    return '';
  }

  /// 获取UserAgent
  static Future<String> getUserAgent() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String userAgent = '';

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      userAgent =
          'Mozilla/5.0 (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.version.sdkInt}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      userAgent =
          'Mozilla/5.0 (iPhone; CPU iPhone OS ${iosInfo.systemVersion.replaceAll('_', ' ')} like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/537.36';
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
      userAgent =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X ${macInfo.osRelease}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    }

    return userAgent;
  }
} 