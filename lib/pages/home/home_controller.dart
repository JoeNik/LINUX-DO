import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';

import '../../const/app_images.dart';
import '../../controller/base_controller.dart';
import '../../net/api_service.dart';
import '../../routes/app_pages.dart';
import '../topics/topics_controller.dart';
import '../../const/app_const.dart';
import '../../const/app_colors.dart';

class HomeController extends BaseController{
  // ignore: unused_field
  late final ApiService _apiService;

  final pageController = PageController();
  late final TopicsController topicsController;

  final RxMap<int, dynamic> _badgeCount = <int, dynamic>{}.obs;

  Map<int, dynamic> get badgeCount => _badgeCount.value;

  set badgeCount(Map<int, dynamic> value) => _badgeCount.value = value;

  // 当前选中的tab索引
  final RxInt currentTab = 0.obs;

  final isRefreshing = false.obs;

  HomeController() {
    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      showError('ApiService not initialized');
      rethrow;
    }
  }

  @override
  void onInit() {
    super.onInit();
    topicsController = Get.find<TopicsController>();

    // 模拟请求的数据
     // badgeCount = {0: '12'};
  }



  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // 切换tab
  void switchTab(int index) {
    if (index == 2) {
      // 显示创建帖子对话框
      _showHintDialog();
      return;
    }
    currentTab.value = index;
  }

  void _showHintDialog() {
    final context = Get.context!;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Container(
          width: 280.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图片占位
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Center(
                    child: Image.asset(
                  AppImages.logoCircle,
                  width: 80.w,
                  height: 80.w,
                )),
              ),
              16.vGap,
              // 标题
              Text(
                AppConst.createPost.dialogTitle,
                style: TextStyle(
                  fontSize: 20.w,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              8.vGap,
              // 内容
              Text(
                AppConst.createPost.dialogContent,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
              ),
              24.vGap,
              // 按钮
              Row(
                children: [
                  // 关闭按钮
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).shadowColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        size: 20.w,
                      ),
                    ),
                  ),
                  12.hGap,
                  // 确认按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(Routes.CREATE_TOPIC);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor:
                            Theme.of(context).textTheme.titleLarge?.color,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: Text(
                        AppConst.createPost.dialogConfirm,
                        style: TextStyle(
                          fontSize: 14.w,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }
}
