import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/net/api_service.dart';

class NotificationSettingsController extends BaseController {
  final ApiService _apiService = Get.find();
  final GlobalController _globalController = Get.find();

  // 通知开关状态
  final whenLiked = false.obs;
  final allowFollow = false.obs;
  final whenFollowed = false.obs;
  final whenIFollow = false.obs;
  final whenReplied = false.obs;
  final whenTopicCreated = false.obs;
  final notificationSchedule = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      isLoading.value = true;
    } catch (e) {
      showError('加载设置失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveNotificationSettings() async {
    try {
      isLoading.value = true;
      // 模拟保存
      await Future.delayed(const Duration(seconds: 1));
      showSuccess('保存成功');
      Get.back();
    } catch (e) {
      showError('保存失败');
    } finally {
      isLoading.value = false;
    }
  }
} 