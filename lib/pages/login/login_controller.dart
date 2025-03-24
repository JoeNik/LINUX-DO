import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/login.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/routes/app_pages.dart';
import '../../const/app_const.dart';
import '../../utils/mixins/toast_mixin.dart';
import '../../utils/log.dart';
import '../../controller/global_controller.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/pages/qr_scanner/qr_scanner_page.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import '../web_page.dart';

class LoginController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();
  final GlobalController _globalController = Get.find<GlobalController>();
  final username = ''.obs;
  final password = ''.obs;
  final isPasswordVisible = false.obs;
  final isChecking = false.obs;
  final isAgreementChecked = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void webLogin() async {
    if (!isAgreementChecked.value) {
      showError('请先阅读并同意服务协议');
      return;
    }

    final result = await Get.to(() => const WebPage());
    if (result == true) {
      isLoading.value = true;
      try {
        // 保存登录状态
        Get.find<GlobalController>().setIsLogin(true);
        // 跳转到首页
        Get.offAllNamed('/home');
      } catch (e) {
        showSnackbar(
          title: AppConst.login.loginFailedTitle,
          message: AppConst.login.loginFailedMessage,
          type: SnackbarType.error,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void loginTips() {
    showError('请先使用WEB授权登录');
  }

  Future<void> login() async {
    await _apiService.getTopics('latest');

    if (username.value.isEmpty) {
      showError(AppConst.login.emptyUsername);
      return;
    }
    if (password.value.isEmpty) {
      showError( AppConst.login.emptyPassword);
      return;
    }

    try {
      isLoading.value = true;

     
    } catch (e, s) {
      l.e('登录失败: $e - $s');
      
    } finally {
      isLoading.value = false;
    }
  }

  void forgetPassword() {
    showSnackbar(
      title: AppConst.login.title,
      message: AppConst.login.notImplemented,
      type: SnackbarType.warning,
    );
  }

  void reigster() {
    showSnackbar(
      title: AppConst.login.register,
      message: AppConst.login.registerTip,
      type: SnackbarType.info,
    );
  }

  /// 扫码登录
  Future<void> scanLogin() async {
    if (!isAgreementChecked.value) {
      showError('请先阅读并同意服务协议');
      return;
    }

    try {
      isLoading.value = true;
      final result = await Get.to(() => const QRScannerPage());

      if (result == null) {
        // 用户取消了扫描
        return;
      }

      try {
        final data = jsonDecode(result);
        l.d('验证前的数据: $data');
        // 验证数据结构
        if (!data.containsKey('cf') ||
            !data.containsKey('f') ||
            !data.containsKey('t') ||
            !data.containsKey('c')) {
          showError('无效的二维码数据');
          return;
        }

        l.d('扫描后的数据格式: $data');

        // 保存 cookies
        final directory = await getApplicationDocumentsDirectory();
        final cookiePath = '${directory.path}/.cookies/';
        final cookieJar = PersistCookieJar(
            ignoreExpires: true, storage: FileStorage(cookiePath));

        final uri = Uri.parse('${HttpConfig.baseUrl}login');

        // 保存 cookies
        await cookieJar.saveFromResponse(uri, [
          Cookie('cf_clearance', data['cf'])
            ..domain = HttpConfig.domain
            ..path = '/'
            ..httpOnly = true
            ..secure = true,
          Cookie('_forum_session', data['f'])
            ..domain = HttpConfig.domain
            ..path = '/'
            ..httpOnly = true
            ..secure = true,
          Cookie('_t', data['t'])
            ..domain = HttpConfig.domain
            ..path = '/'
            ..httpOnly = true
            ..secure = true,
        ]);

        // 保存 CSRF Token
        await StorageManager.setData(AppConst.identifier.csrfToken, data['c']);

        // token会失效,临时的解决方案
        await StorageManager.setData(AppConst.identifier.token, data['t']);

        await StorageManager.setData(
            AppConst.identifier.cfClearance, data['cf']);

        // 执行到这里，说明扫码登录成功
        showSuccess('扫码登录成功');

        // 获取用户信息并返回
        await Get.find<GlobalController>().fetchUserInfo();

        Get.offAllNamed(Routes.HOME);
      } catch (e) {
        l.e('扫码登录失败: $e');
        showError('无效的二维码格式');
      }
    } catch (e) {
      l.e('扫码过程出错: $e');
      showError('扫码过程出错');
    } finally {
      isLoading.value = false;
    }
  }
}
