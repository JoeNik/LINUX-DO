import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import '../../const/app_const.dart';
import '../../const/app_colors.dart';
import '../../const/app_images.dart';
import '../../routes/app_pages.dart';
import '../../utils/tag.dart';
import 'topics_controller.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({Key? key}) : super(key: key);

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage>
    with SingleTickerProviderStateMixin {
  final TopicsController controller = Get.find<TopicsController>();

  @override
  Widget build(BuildContext context) {
    final appBarHeight = 44.w;
    final margin = 18.w;
    final menuWidth = 44.w; // 菜单按钮宽度
    final horizontalPadding = 16.w; // 水平内边距
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: controller.handleScrollNotification,
        child: NestedScrollView(
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  minHeight: kToolbarHeight + appBarHeight, // AppBar高度 + 搜索框高度
                  maxHeight: 180.w,
                  child: Container(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final top = constraints.biggest.height;

                        // 计算折叠进度
                        final collapsedProgress = ((180.w - top) /
                                (180.w - kToolbarHeight - appBarHeight))
                            .clamp(0.0, 1.0);

                        return Stack(
                          children: [
                            // 搜索框（固定在AppBar下方）
                            _buildTopWidget(
                                appBarHeight,
                                collapsedProgress,
                                menuWidth,
                                context,
                                margin,
                                horizontalPadding),
                            // 背景图片（只在展开状态显示）
                            if (collapsedProgress < 1)
                              Positioned(
                                top: kToolbarHeight + appBarHeight,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: margin),
                                  child: Opacity(
                                    opacity: 1 - collapsedProgress,
                                    child: Image.asset(
                                      AppImages.getBanner(context),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                pinned: true,
              ),

              // 标语
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  color: Theme.of(context).primaryColorDark,
                  child: Text(
                    AppConst.slogan.replaceAll('\n', ''),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.w,
                    ),
                  ),
                ),
              ),

              // Tab栏
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  minHeight: appBarHeight,
                  maxHeight: appBarHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: .1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: controller.tabController,
                      isScrollable: false,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Theme.of(context).hintColor,
                      labelStyle: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 14.w,
                        fontWeight: FontWeight.normal,
                      ),
                      indicatorColor: AppColors.primary,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: controller.tabs,
                    ),
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: controller.tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: controller.tabViews,
          ),
        ),
      ),
    );
  }

  Positioned _buildTopWidget(
      double appBarHeight,
      double collapsedProgress,
      double menuWidth,
      BuildContext context,
      double margin,
      double horizontalPadding) {
        final logoWidth = 100.w;
    return Positioned(
      top: kToolbarHeight,
      left: 0,
      right: 0,
      height: appBarHeight,
      child: Row(
        children: [
         
          // 搜索框
          Expanded(
            child: GestureDetector(
              onTap: () {
                showSearch(
                  context: context,
                  delegate: TopicSearchDelegate(controller),
                );
              },
              child: Container(
                height: 32.w,
                margin: EdgeInsets.only(
                  top: 4.w,
                  bottom: 4.w,
                  left: margin,
                  right: margin,
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(18.w),
                  border: Border.all(
                    color: Theme.of(context).inputDecorationTheme.fillColor ??
                        Colors.transparent,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 18.w,
                      color: Theme.of(context).hintColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppConst.posts.searchTopic,
                      style: TextStyle(
                        fontSize: 14.w,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 右侧logo
          AnimatedOpacity(
            opacity: collapsedProgress,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: logoWidth * collapsedProgress,
              child: Container(
                padding: EdgeInsets.only(right: horizontalPadding),
                child: Image.asset(
                  AppImages.getLogo(context),
                  width: logoWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 添加 SliverPersistentHeaderDelegate 实现
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class TopicSearchDelegate extends SearchDelegate<String> {
  final TopicsController controller;

  TopicSearchDelegate(this.controller)
      : super(
          searchFieldLabel: AppConst.posts.searchTopic,
          searchFieldStyle: TextStyle(
            fontSize: 14.w,
            color: Get.theme.textTheme.bodyMedium?.color,
          ),
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
        hintStyle: TextStyle(
          fontSize: 14.w,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Obx(() {
        if (controller.isSearching.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: SizedBox(
                height: 16.w,
                child: DisRefreshLoading(fontSize: 8.w),
              ),
            ),
          );
        }
        return IconButton(
          icon: Icon(
            CupertinoIcons.clear,
            size: 18.w,
            color: Theme.of(context).hintColor,
          ),
          onPressed: () {
            if (query.isEmpty) {
              close(context, '');
            } else {
              query = '';
              controller.clearSearch();
            }
          },
        );
      }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        CupertinoIcons.arrow_left_circle_fill,
        size: 24.w,
        color: Theme.of(context).hintColor,
      ),
      onPressed: () {
        controller.clearSearch();
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    return Obx(() {
      if (controller.topics.isEmpty) {
        return Center(
          child: Text(
            controller.searchError.value.isNotEmpty
                ? controller.searchError.value
                : '没有找到相关内容',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 12.w,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        itemCount: controller.topics.length,
        itemBuilder: (context, index) {
          final topic = controller.topics[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.clearSearch();
                close(context, topic.id.toString());
                Get.toNamed(Routes.TOPIC_DETAIL, arguments: topic.id);
              },
              borderRadius: BorderRadius.circular(4.w),
              splashColor: Theme.of(context).primaryColor.withValues(alpha: .1),
              highlightColor: Theme.of(context).primaryColor.withValues(alpha: .05),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 3.w, horizontal: 12.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.w,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (topic.tags != null && topic.tags!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.w),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: topic.tags!.map((tag) {
                              final color = Tag.getTagColors(tag);
                              return Container(
                                margin: EdgeInsets.only(right: 8.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.w),
                                decoration: BoxDecoration(
                                  color: color.backgroundColor,
                                  border: Border.all(
                                    color: color.backgroundColor,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4.w),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 9.w,
                                    color: color.textColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    4.vGap,
                    Text(
                      topic.title ?? '',
                      style: TextStyle(
                        fontSize: 14.w,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    if (query.isNotEmpty) {
      controller.searchTopics(query);
    } else {
      controller.clearSearch();
    }
  }

  @override
  void showSuggestions(BuildContext context) {
    super.showSuggestions(context);
    if (query.isNotEmpty) {
      controller.searchTopics(query);
    } else {
      controller.clearSearch();
    }
  }
}
