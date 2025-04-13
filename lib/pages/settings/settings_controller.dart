import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/http_client.dart';
import 'package:linux_do/net/success_response.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/const/app_const.dart';

import '../../net/http_config.dart';
import '../../utils/log.dart';
import '../../widgets/dis_color_picker.dart';
import '../web_page.dart';

class SettingsController extends BaseController {
  final ApiService _apiService = Get.find();
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
    await NetClient.getInstance().clearCookies();
    await StorageManager.remove(AppConst.identifier.csrfToken);
    await StorageManager.remove(AppConst.identifier.token);
    await StorageManager.remove(AppConst.identifier.cfClearance);
    await StorageManager.remove(AppConst.identifier.username);
    await StorageManager.remove(AppConst.identifier.name);
    Get.find<GlobalController>().setIsLogin(false);
    Get.find<GlobalController>().setIsAnonymousMode(false);
    StorageManager.setData(AppConst.identifier.isAnonymousMode, false);
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

      final colorHex = color.value & 0xFFFFFF;
      StorageManager.setData(AppConst.identifier.themeColor, colorHex);
    } catch (e, s) {
      l.e('changeTheme error: $e, $s');
    }
  }


  /// 关于页面
  void toAbout() {
    Get.toNamed(Routes.ABOUT);
  }

  /// 常见问题页面
  void toFaq() {
    Get.toNamed(Routes.WEBVIEW, arguments: '${HttpConfig.baseUrl}${AppConst.faq}');
  }

  /// 更新浏览器提示  
  void updateBrowserTips(bool value) {
    StorageManager.setData(AppConst.identifier.browserTips, value);
    browserTips.value = value;
  }

  /// 安全设置页
  void toSecuritySettings() {
    Get.toNamed(Routes.SECURITY_SETTINGS);
  }

  /// 个性资料页
  void toProfileSettings() {
    //Get.toNamed(Routes.PROFILE_SETTINGS);
    showWarning('开发中');
  }

  /// 电子邮件设置页
  void toEmailSettings() {
    Get.toNamed(Routes.EMAIL_SETTINGS);
  }

  /// 通知设置页
  void toNotificationSettings() {
    Get.toNamed(Routes.NOTIFICATION_SETTINGS);
  }

  /// 跟踪设置页
  void toTrackingSettings() {
    Get.toNamed(Routes.TRACKING_SETTINGS);
  }

  /// 免打扰设置页
  void toDoNotDisturbSettings() {
    Get.toNamed(Routes.DO_NOT_DISTURB_SETTINGS);
  }

  /// 导出数据
  void exportData() async{
    try{
      SuccessResponse data = await _apiService.requestDataExport();
      if (data.isSuccess) {
        showSuccess(AppConst.settings.dataExportSuccess);
      }
    } catch (e, s) {
      showError(AppConst.settings.dataExportFailed);
      l.e('exportData error: $e, $s');
    }
  }

  /// 用户协议
  void toTerms() async{
    final htmlContent = await rootBundle.loadString(AppConst.terms);
    Get.toNamed(Routes.WEBVIEW, arguments: htmlContent);
  }

  /// 隐私政策
  void toPrivacy() async{
    final htmlContent = await rootBundle.loadString(AppConst.privacy);
    Get.toNamed(Routes.WEBVIEW, arguments: htmlContent);
  }

  /// 字体大小设置
  void toFontSizeSettings() {
    Get.toNamed(Routes.FONT_SIZE_SETTINGS);
  }
} 