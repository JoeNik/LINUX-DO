import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import '../chat/chat_page.dart';
import '../topics/topics_page.dart';
import '../category/category_topics_page.dart';
import '../profile/profile_page.dart';
import 'home_controller.dart';

// 自定义TabStyle
class CustomTabStyle extends StyleHook {
  @override
  double get activeIconSize => 24.w;

  @override
  double get activeIconMargin => 10.w;

  @override
  double get iconSize => 24.w;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 11.w, color: color);
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 计算底部导航栏总高度 = 基础高度 + 底部安全区域
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 50.h + bottomPadding;

    return Scaffold(
      body: Obx(
        () => LazyLoadIndexedStack(
          index: controller.currentTab.value,
          children: const [
            TopicsPage(),
            CategoryTopicsPage(),
            SizedBox(), // 占位
            ChatPage(),
            ProfilePage(),

          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: controller.topicsController.isBottomBarVisible.value
              ? navBarHeight
              : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: navBarHeight,
              child: ConvexAppBar.badge(
                controller.badgeCount,
                style: TabStyle.fixed,
                backgroundColor:
                    Theme.of(context).canvasColor,
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor,
                activeColor: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor,
                height: 50.w,
                curveSize: 60.w,
                top: -20.w,
                elevation: 0.5,
                cornerRadius: 20.w,
                badgeMargin: EdgeInsets.only(left: 20.w, bottom: 18.w),
                items: [
                  _buildTabItem(CupertinoIcons.square_list_fill, '帖子', context),
                  _buildTabItem(CupertinoIcons.square_split_2x2_fill, '分类', context),
                  TabItem(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.add,
                        size: 26.w,
                        color: Colors.white,
                      ),
                    ),
                    title: '',
                    fontFamily: '',
                    isIconBlend: false,
                  ),
                  _buildTabItem(CupertinoIcons.app_badge_fill, '私信', context),
                  _buildTabItem(CupertinoIcons.person_crop_square_fill, '我的', context),
                ],
                initialActiveIndex: controller.currentTab.value,
                onTap: controller.switchTab,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 提取通用的TabItem创建方法
  TabItem _buildTabItem(IconData icon, String title, BuildContext context) {
    return TabItem(
      icon: icon,
      title: title,
      fontFamily: '',
      isIconBlend: false,
      activeIcon: Icon(icon, color: Theme.of(context).primaryColor),
    );
  }
}
