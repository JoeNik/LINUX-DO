import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../const/app_colors.dart';
import '../const/app_const.dart';
import '../const/app_images.dart';
import '../const/app_sizes.dart';
import '../const/app_spacing.dart';
import '../routes/app_pages.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: screenWidth * 0.58,
      child: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 100.w + statusBarHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AppImages.getHeaderBackground(context),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: Spacing.md,
                    bottom: Spacing.xxl,
                    right: Spacing.md,
                    child: Text.rich(
                      TextSpan(
                          text: ' \n${AppConst.siteName}',
                          style: TextStyle(
                              fontSize: AppSizes.fontLarge,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ),
            // 分割线
            Divider(color: Theme.of(context).dividerColor),
            // 主要内容区域 - 使用 SafeArea 只作用于滚动内容
            Expanded(
              child: SafeArea(
                top: false, // 不处理顶部，因为我们已经手动处理了
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 外部链接
                      _buildSection(
                        context: context,
                        title: AppConst.drawerMenu.externalLinks,
                        items: [
                          _MenuItem(
                              icon: CupertinoIcons.eye,
                              title: AppConst.drawerMenu.status,
                              url: AppConst.drawerMenu.statusUrl),
                          _MenuItem(
                              icon: CupertinoIcons.link,
                              title: AppConst.drawerMenu.connect,
                              url: AppConst.drawerMenu.connectUrl),
                          _MenuItem(
                              icon: CupertinoIcons.gift,
                              title: AppConst.drawerMenu.lottery,
                              url: AppConst.drawerMenu.lotteryUrl),
                          _MenuItem(
                              icon: CupertinoIcons.paperplane,
                              title: AppConst.drawerMenu.telegramChannel,
                              url: AppConst.drawerMenu.channelUrl),
                          _MenuItem(
                              icon: CupertinoIcons.paperplane,
                              title: AppConst.drawerMenu.telegram,
                              url: AppConst.drawerMenu.jaTGUrl),
                        ],
                      ),
                      // 类别
                      _buildSection(
                        context: context,
                        title: AppConst.drawerMenu.categories,
                        items: [
                          _MenuItem(
                              icon: CupertinoIcons
                                  .chevron_left_slash_chevron_right,
                              title: AppConst.drawerMenu.devOptimization,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.folder,
                              title: AppConst.drawerMenu.docBuilding,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.square_grid_2x2,
                              title: AppConst.drawerMenu.notMine,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.rocket,
                              title: AppConst.drawerMenu.sailAway),
                          _MenuItem(
                              icon: CupertinoIcons.gift,
                              title: AppConst.drawerMenu.benefits,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.chat_bubble_text,
                              title: AppConst.drawerMenu.operationFeedback,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.square_grid_3x2,
                              title: AppConst.drawerMenu.resources,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.cart,
                              title: AppConst.drawerMenu.fleaMarket,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.book,
                              title: AppConst.drawerMenu.readingPoetry,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.news,
                              title: AppConst.drawerMenu.frontierNews,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.leaf_arrow_circlepath,
                              title: AppConst.drawerMenu.pickAndChoose,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.shield,
                              title: AppConst.drawerMenu.deepSea,
                              hasNew: false),
                        ],
                        showViewAll: true,
                      ),
                      // 标签
                      _buildSection(
                        context: context,
                        title: AppConst.drawerMenu.tags,
                        items: [
                          _MenuItem(
                              icon: CupertinoIcons.hand_thumbsup,
                              title: AppConst.drawerMenu.essentialPosts,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.waveform_path,
                              title: AppConst.drawerMenu.ai,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.speaker_2,
                              title: AppConst.drawerMenu.announcements,
                              hasNew: false),
                          _MenuItem(
                              icon: CupertinoIcons.question_circle,
                              title: AppConst.drawerMenu.qa,
                              hasNew: false),
                        ],
                        showViewAll: true,
                      ),
                      // // 消息
                      // _buildSection(
                      //   context: context,
                      //   title: AppConst.drawerMenu.messages,
                      //   items: [
                      //     _MenuItem(
                      //         icon: CupertinoIcons.tray,
                      //         title: AppConst.drawerMenu.inbox),
                      //   ],
                      // ),
                      // // 频道
                      // _buildSection(
                      //   context: context,
                      //   title: AppConst.drawerMenu.channels,
                      //   items: [
                      //     _MenuItem(
                      //         icon: CupertinoIcons.chat_bubble_2,
                      //         title: AppConst.drawerMenu.regularChannel,
                      //         hasNew: false),
                      //   ],
                      //   showViewAll: true,
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<_MenuItem> items,
    bool showViewAll = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Padding(
          padding: EdgeInsets.all(Spacing.sm),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSizes.fontNormal,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (showViewAll) ...[
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    CupertinoIcons.pencil_circle_fill,
                    size: AppSizes.iconSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ],
          ),
        ),
        // 菜单项
        ...items.map((item) => _buildMenuItem(context, item)),

        // 分割线
        Divider(color: Theme.of(context).dividerColor),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: () {
        if (item.url != null) {
          Get.back(); // 关闭抽屉
          Get.toNamed(Routes.WEBVIEW, arguments: item.url);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: AppSizes.iconSmall,
              color: Theme.of(context).iconTheme.color,
            ),
            Spacing.md.hGap,
            Text(
              item.title,
              style: TextStyle(
                fontSize: AppSizes.fontNormal,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (item.hasNew) ...[
              8.hGap,
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final bool hasNew;
  final String? url;
  const _MenuItem({
    required this.icon,
    required this.title,
    this.hasNew = false,
    this.url,
  });
}
