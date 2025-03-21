import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/const/app_const.dart';

class TrackingSettingsController extends BaseController {
  final ApiService _apiService = Get.find();
  final GlobalController _globalController = Get.find();

  // 跟踪设置状态
  final enableTracking = false.obs;
  final trackLocation = false.obs;
  final trackActivity = false.obs;
  final trackBrowsingHistory = false.obs;
  final shareAnalytics = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTrackingSettings();
  }

  Future<void> _loadTrackingSettings() async {
    try {
      isLoading.value = true;
    } catch (e) {
      showError(AppConst.settings.loadSettingsFailed);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTrackingSettings() async {
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