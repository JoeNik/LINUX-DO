import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/net/http_client.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/const/app_const.dart';

import '../../utils/log.dart';
import '../../widgets/dis_color_picker.dart';
import '../web_page.dart';

class SettingsController extends GetxController {
  final isAnonymousMode = false.obs;
  final isDoNotDisturb = false.obs;
  final isTrackingEnabled = false.obs;
  final themeMode = ThemeMode.system.obs;

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
    final savedThemeMode = StorageManager.getString(AppConst.identifier.theme) ?? 'system';
    l.e(savedThemeMode.toString());
    themeMode.value = _parseThemeMode(savedThemeMode);
  }

  ThemeMode _parseThemeMode(String value) {
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
      selectedColor: primaryMaterial, // 当前选中的颜色
      onColorSelected: (color) {
        // 处理颜色选择
        Get.changeTheme(ThemeData(primaryColor: color));
      },  
    );
  }
} 