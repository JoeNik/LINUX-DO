import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_images.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/user.dart';
import 'package:linux_do/pages/profile/personal_controller.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/sticky_tab_delegate.dart';
import 'package:slide_switcher/slide_switcher.dart';

class PersonalPage extends GetView<PersonalController> {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 创建一个 ValueNotifier 来跟踪滚动进度
    final scrollProgress = ValueNotifier<double>(0.0);
    final expandedHeight = 280.w;
    return Scaffold(
      body: Obx(() {
        final userInfo = Get.find<GlobalController>().userInfo;

        final user = userInfo?.user;
        return NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: expandedHeight,
              backgroundColor: Colors.transparent,
              floating: false,
              pinned: true,
              stretch: true,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final top = constraints.biggest.height;
                  final shrinkOffset = expandedHeight - top;
                  final progress =
                      (shrinkOffset / (expandedHeight - kToolbarHeight))
                          .clamp(0.0, 1.0);

                  // 更新滚动进度
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollProgress.value = progress;
                  });

                  return Container(
                    color: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: progress),
                    child: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 背景图片
                          if (progress < 1)
                            Opacity(
                              opacity: (1 - progress).clamp(0.0, 1.0),
                              child: user?.cardBackgroundUploadUrl != null
                                  ? CachedImage(
                                      imageUrl:
                                          user?.cardBackgroundUploadUrl ?? '',
                                      fit: BoxFit.cover)
                                  : Image.asset(
                                      AppImages.profileHeaderBg,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          // 模糊效果
                          if (progress > 0)
                            BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: progress * 10,
                                sigmaY: progress * 10,
                              ),
                              child: Container(
                                color: Colors.black
                                    .withValues(alpha: progress * 0.3),
                              ),
                            ),
                          // 渐变遮罩
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                          // 用户信息
                          Positioned(
                              // 使用线性插值函数
                              bottom: lerpDouble(10.w, 16.w, progress),
                              left: lerpDouble(8.w, 56.w, progress),
                              right: 0,
                              child: _buildProfile(user, progress, context)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              title: ValueListenableBuilder<double>(
                valueListenable: scrollProgress,
                builder: (context, progress, child) {
                  final showTitle = progress >= 0.5;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: showTitle ? 1.0 : 0.0,
                    child: showTitle
                        ? Text(
                            user?.username ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
              leading: ValueListenableBuilder<double>(
                valueListenable: scrollProgress,
                builder: (context, progress, child) {
                  final showAvatar = progress >= 0.5;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: showAvatar ? 1.0 : 0.0,
                    child: showAvatar
                        ? Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.white, width: 1.w),
                                  borderRadius: BorderRadius.circular(80.w)),
                              child: CachedImage(
                                imageUrl: user?.getAvatar(120) ?? '',
                                circle: true,
                                width: 30.w,
                                height: 30.w,
                                borderRadius: BorderRadius.circular(80.w),
                                showBorder: true,
                                borderColor: AppColors.white,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
            ),

            // 统计信息
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    
                  ],
                ),
              ),
            ),

            // Tab栏
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyTabBarDelegate(
                height: 40.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(12.w),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SlideSwitcher(
                    containerHeight: 40.w,
                    containerWight: MediaQuery.of(context).size.width - 40.w,
                    initialIndex: 0,
                    containerColor: Theme.of(context).cardColor,
                    slidersGradients: [
                      LinearGradient(colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.6)
                      ])
                    ],
                    onSelect: (index) => {},
                    children: [
                      
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: const Center(child: Text('个人主页')),
        );
      }),
    );
  }

  Widget _buildProfile(
      CurrentUser? user, double progress, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 2.w),
                      borderRadius: BorderRadius.circular(45.w)),
                  child: CachedImage(
                    imageUrl: user?.getAvatar(240) ?? '',
                    circle: true,
                    width: 70.w,
                    height: 70.w,
                  ),
                ),
                Positioned(
                    bottom: 10.w,
                    left: 60.w,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                          color: user?.userAction?.hidePresence == false
                              ? AppColors.disabled
                              : AppColors.success,
                          border:
                              Border.all(color: AppColors.white, width: 1.5.w),
                          borderRadius: BorderRadius.circular(10.w)),
                    ))
              ],
            ),
      
          ],
        ),
        
      ],
    );
  }
}
