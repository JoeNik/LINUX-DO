import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/http_client.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/const/app_const.dart';

import '../../net/http_config.dart';
import '../../utils/log.dart';
import '../../widgets/dis_color_picker.dart';
import '../web_page.dart';

class SettingsController extends BaseController {
  final isAnonymousMode = false.obs;
  final isDoNotDisturb = false.obs;
  final isTrackingEnabled = false.obs;
  final themeMode = ThemeMode.system.obs;
  final browserTips = false.obs;

  List<String> get themeModeOptions => [
    AppConst.settings.themeSystem,
    AppConst.settings.themeLight,
    AppConst.settings.themeDark,
  ];

  String get selectedThemeMode {
    switch (themeMode.value) {
      case ThemeMode.system:
        return AppConst.settings.themeSystem;
      case ThemeMode.light:
        return AppConst.settings.themeLight;
      case ThemeMode.dark:
        return AppConst.settings.themeDark;
      }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    ever(themeMode, (ThemeMode mode) {
      Get.changeThemeMode(mode);
    });
  }

  void _loadSettings() {
    final savedThemeMode = StorageManager.getString(AppConst.identifier.theme);
    themeMode.value = _parseThemeMode(savedThemeMode);

    final savedBrowserTips = StorageManager.getBool(AppConst.identifier.browserTips) ?? false;
    browserTips.value = savedBrowserTips;
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(String? value) {
    if (value == null) return;
    
    ThemeMode newMode;
    String themeValue;
    
    if (value == AppConst.settings.themeSystem) {
      newMode = ThemeMode.system;
      themeValue = 'system';
    } else if (value == AppConst.settings.themeLight) {
      newMode = ThemeMode.light;
      themeValue = 'light';
    } else {
      newMode = ThemeMode.dark;
      themeValue = 'dark';
    }

    themeMode.value = newMode;
    StorageManager.setData(AppConst.identifier.theme, themeValue);
  }

  Future<void> logout() async {
    await WebPage.clearCache();
    await HttpClient.getInstance().clearCookies();
    await StorageManager.remove(AppConst.identifier.csrfToken);
    Get.find<GlobalController>().setIsLogin(false);
    Get.offAllNamed(Routes.LOGIN);
  }


  void showColorPicker() {
    DisColorPicker.show(
      selectedColor: primaryMaterial,
      onColorSelected: (color) {
        changeTheme(color);   
      },  
    );
  }

  void changeTheme(Color color) {
  try {
    ThemeData lightTheme = ThemeData(
      primaryColor: color,
      brightness: Brightness.light,
    );

    ThemeData darkTheme = ThemeData(
      primaryColor: color,
      brightness: Brightness.dark,
    );

    // 根据当前主题模式切换
    if (Get.isDarkMode) {
      Get.changeTheme(darkTheme);
    } else {
      Get.changeTheme(lightTheme);
    }

    // 返回上一页
    Get.back();

    // 保存颜色
    StorageManager.setData(AppConst.identifier.themeColor, color.toString());
  } catch (e, s) {
    l.e('changeTheme error: $e, $s');
  }
}


  /// 关于页面
  void toAbout() {
  }

  /// 常见问题页面
  void toFaq() {
    Get.toNamed(Routes.WEBVIEW, arguments: '${HttpConfig.baseUrl}${AppConst.faq}');
  }

  /// 更新浏览器提示  
  void updateBrowserTips(bool value) {
    browserTips.value = value;
    StorageManager.setData(AppConst.identifier.browserTips, value);
  }
} 