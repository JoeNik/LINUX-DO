import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/const/app_const.dart';

class DoNotDisturbController extends BaseController {
  final ApiService _apiService = Get.find();
  final GlobalController _globalController = Get.find();

  // 免打扰用户列表
  final ignoredUsers = <String>[].obs;
  
  // 选择的用户
  final selectedUser = ''.obs;
  
  // 持续时间选项
  final durations = [
    '30分钟',
    '1小时',
    '4小时',
    '8小时',
    '24小时',
    '永久',
  ];
  
  // 选择的持续时间
  final selectedDuration = ''.obs;

  // 已设为免打扰
  final allowPersonalMessages = true.obs;
  final allowChatMessages = true.obs;
  final allowNotifications = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadIgnoredUsers();
    selectedDuration.value = durations[0];
  }

  Future<void> _loadIgnoredUsers() async {
    try {
      isLoading.value = true;
      ignoredUsers.value = [];
    } catch (e) {
      showError(AppConst.settings.loadSettingsFailed);
    } finally {
      isLoading.value = false;
    }
  }

  // 添加免打扰用户
  Future<void> addIgnoredUser() async {
    if (selectedUser.value.isEmpty) {
      showError(AppConst.settings.selectUserToBlock);
      return;
    }
    
    try {
      ignoredUsers.add(selectedUser.value);
      Get.back(); // 关闭弹窗
      showSuccess(AppConst.settings.addSuccess);
    } catch (e) {
      showError(AppConst.settings.addFailed);
    }
  }

  // 移除免打扰用户
  Future<void> removeIgnoredUser(String username) async {
    try {
      ignoredUsers.remove(username);
      showSuccess(AppConst.settings.removeSuccess);
    } catch (e) {
      showError(AppConst.settings.removeFailed);
    }
  }

  // 保存设置
  Future<void> saveSettings() async {
    try {
      showSuccess(AppConst.settings.saveSuccess);
    } catch (e) {
      showError(AppConst.settings.saveFailed);
    }
  }
} 