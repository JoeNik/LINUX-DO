import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/models/follow.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/success_response.dart';
import 'package:linux_do/pages/profile/tabs/message_controller.dart';
import 'package:linux_do/routes/app_pages.dart';
import '../../const/app_const.dart';
import '../../controller/base_controller.dart';
import '../../controller/global_controller.dart';
import '../../utils/log.dart';
import '../../utils/mixins/concatenated.dart';
import '../../utils/storage_manager.dart';
import 'tabs/activity_controller.dart';
import 'tabs/badge_controller.dart';
import 'tabs/notification_controller.dart';
import 'tabs/summary_controller.dart';
import 'tabs/activity_page.dart';
import 'tabs/badge_page.dart';
import 'tabs/message_page.dart';
import 'tabs/notification_page.dart';
import 'tabs/summary_page.dart';

class ProfileController extends BaseController with Concatenated {
  final ApiService _apiService = Get.find();

  final _onlineMode = true.obs;
  final _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;
  set selectedIndex(int index) => _selectedIndex.value = index;

  bool get onlineMode => _onlineMode.value;
  set onlineMode(bool b) => _onlineMode.value = b;

  final TextEditingController statusController = TextEditingController();
  final TextEditingController emojiController = TextEditingController();
  final RxBool showEmoji = false.obs;
  final RxList<Follow> following = <Follow>[].obs;
  final RxList<Follow> followers = <Follow>[].obs;

  @override
  void onInit() {
    super.onInit();
    _getFollowing();
    _getFollowers();
    // 初始化子控制器
    Get.lazyPut(() => SummaryController());
    Get.lazyPut(() => ActivityController());
    Get.lazyPut(() => NotificationController());
    Get.lazyPut(() => MessageController());
    Get.lazyPut(() => BadgeController());
  }


  
  

  Widget createCurrent() {
    switch (selectedIndex) {
      case 0:
        return const SummaryPage();
      case 1:
        return const ActivityPage();
      case 2:
        return const NotificationPage();
      case 3:
        return const MessagePage();
      case 4:
        return const BadgePage();
      default:
        return const SizedBox.shrink();
    }
  }

  // 编辑个人信息
  void editProfile() {}

  // 临时退出登录
  void logout() {
    Get.offAllNamed('/login');

    // 清除登录状态
    final globalController = Get.find<GlobalController>();
    StorageManager.remove(AppConst.identifier.csrfToken);
    globalController.setIsLogin(false);
  }

  // 去设置页面
  void toSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  // 更新在线状态
  void updatePresence(bool hidePresence) async {
    try {
      final response = await _apiService.updatePresence(
        userName,
        hidePresence,
      );
      Get.find<GlobalController>().userInfo = response;
      showSuccess(AppConst.updateSuccess);
    } catch (e) {
      l.e('更新失败 $e');
      showError('更新失败');
    }
  }

  @override
  void onClose() {
    statusController.dispose();
    super.onClose();
  }

  // 更新状态
  void updateStatus() async {
    try {
      SuccessResponse<dynamic>? response;

      if (statusController.text.trim().isNotEmpty) {
        response = await _apiService.updateUserStatus(
          statusController.text.trim(),
        );
      } else {
        response = await _apiService.deleteUserStatus();
      }
      if (response.isSuccess) {
        showSuccess(AppConst.configSuccess);
        Get.find<GlobalController>().fetchUserInfo();
      } else {
        showError(AppConst.configFailed);
      }
    } catch (e, s) {
      l.e('更新失败 $e --- $s');
      showError('更新失败');
    }
  }

  void _getFollowers() async {
    try {
      final response = await _apiService.getFollowers(userName);
      l.i('获取关注者 ${jsonEncode(response)}');
      followers.value = response;
    } catch (e, s) {
      l.e('获取关注者失败 $e --- $s');
    }
  }

  void _getFollowing() async {
    try {
      final response = await _apiService.getFollowing(userName);
      l.i('获取关注者 ${jsonEncode(response)}');
      following.value = response;
    } catch (e, s) {
      l.e('获取关注者失败 $e --- $s');
    }
  }
}
