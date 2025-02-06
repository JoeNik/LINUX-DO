import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/state_view.dart';
import '../../../const/app_const.dart';
import '../../../const/app_spacing.dart';
import '../../../const/app_theme.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/dis_loading.dart';
import 'topic_detail_controller.dart';
import '../../../models/topic_detail.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'widgets/page_heder.dart';
import 'widgets/post_content.dart';
import 'widgets/post_header.dart';
import 'widgets/post_footer.dart';
import 'widgets/posts_selector.dart';

class TopicDetailPage extends GetView<TopicDetailController> {
  const TopicDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Obx(() {
            return StateView(
              state: controller.getViewState(),
              errorMessage: controller.errorMessage.value,
              onRetry: controller.refreshTopicDetail,
              shimmerView: const ShimmerDetails(),
              child: _contentWidget(context),
            );
          }),
          // 新增楼层选择器
          Obx(() {
            final postsCount = controller.topic.value?.postsCount ?? 0;
            // 如果帖子数量小于50或者正在回复
            if (postsCount < 50) {
              return const SizedBox();
            }
            
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: controller.isReplying.value ? -50.w : 16.w,
              bottom: MediaQuery.of(context).padding.bottom + 16.w,
              child: PostsSelector(
                postsCount: postsCount,
                currentIndex: controller.currentPostIndex.value.clamp(0, postsCount - 1),
                onIndexChanged: (index) {
                  if (!controller.isLoading.value) {
                    controller.scrollToPost(index);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          CupertinoIcons.chevron_left_circle,
          size: 24.w,
        ),
        onPressed: () => Get.back(),
      ),
      title: _buildHeader(context),
      actions: [
        IconButton(
          icon: Obx(() => Icon(
                controller.isFooderVisible.value
                    ? CupertinoIcons.chevron_up_circle
                    : CupertinoIcons.chevron_down_circle,
              )),
          onPressed: () {
            controller.isFooderVisible.toggle();
          },
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return PageHeader(controller: controller);
  }

  Widget _contentWidget(BuildContext context) {
    final topic = controller.topic.value;
    if (topic == null) return Container();

    return Stack(
      children: [
        Positioned.fill(
          child: Obx(() => ScrollablePositionedList.builder(
                key: PageStorageKey('topic_detail_${topic.id}'),
                itemScrollController: controller.itemScrollController,
                itemPositionsListener: controller.itemPositionsListener,
                initialScrollIndex: controller.initialScrollIndex.value,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.replyTree.length + 2,
                minCacheExtent: 300,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                itemBuilder: (context, index) {
                  // 头部加载指示器
                  if (index == 0) {
                    return Obx(() => controller.hasPrevious.value && !controller.isLoading.value
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            alignment: Alignment.center,
                            child: DisRefreshLoading())
                        : const SizedBox());
                  }

                  // 底部加载指示器
                  if (index == controller.replyTree.length + 1) {
                    return Obx(() => controller.hasMore.value && !controller.isLoading.value
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            alignment: Alignment.center,
                            child: DisRefreshLoading())
                        : const SizedBox());
                  }

                  // 帖子内容
                  if (controller.isLoading.value || index - 1 >= controller.replyTree.length) {
                    return const SizedBox();
                  }
                  
                  final node = controller.replyTree[index - 1];
                  return _buildPostItem(context, node);
                },
              )),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: controller.isFooderVisible.value ? 0.w : -200.w,
          left: 0,
          right: 0,
          child: Container(
            child: _buildExpand(context, topic),
          ),
        ),
        // 回复输入框
        Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: controller.isReplying.value ? 0 : -300.h,
              left: 0,
              right: 0,
              child: _buildReplyInput(context, topic),
            )),
      ],
    );
  }

  Widget _buildPostItem(BuildContext context, PostNode node) {
    return Card(
      elevation: node.post.replyToPostNumber == null ? 0.7 : 0,
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    6.vGap,
                    PostHeader(post: node.post),
                    2.vGap,
                    PostContent(node: node),
                    2.vGap,
                    PostFooter(post: node.post),
                  ],
                ),
              ),

              // 只有不是回复的帖子才显示楼层
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha:  0.1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12.w),
                      bottomLeft: Radius.circular(12.w),
                    ),
                  ),
                  child: Text(
                    '#${node.post.postNumber}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 10.w,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpand(BuildContext context, TopicDetail topic) {
    final theme = Theme.of(context);
    final createUser = topic.details?.createdBy;

    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.w),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.w),
          bottomRight: Radius.circular(12.w),
        ),
      ),
      child: Row(
        children: [
          CachedImage(
            imageUrl: createUser?.getAvatarUrl(),
            width: 25.w,
            height: 25.w,
            circle: !(createUser?.isWebMaster() ?? false),
            borderRadius: BorderRadius.circular(4.w),
            placeholder: const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            errorWidget: Icon(
              Icons.account_circle,
              size: 25.w,
              color: theme.iconTheme.color?.withValues(alpha: 0.5),
            ),
          ),
          4.hGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  createUser?.name?.isEmpty ?? true
                      ? createUser?.username ?? ''
                      : createUser?.name ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 10.sp,
                      color: createUser?.isWebMaster() ?? false
                          ? AppColors.primary
                          : theme.textTheme.bodyMedium?.color,
                      fontWeight: createUser?.isWebMaster() ?? false
                          ? FontWeight.bold
                          : FontWeight.normal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Row(
                  children: [
                    if (topic.postsCount != null) ...[
                      Icon(
                        Icons.article_outlined,
                        size: 12.sp,
                        color: Theme.of(context).hintColor,
                      ),
                      2.hGap,
                      Text(
                        '${topic.postsCount}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      8.hGap,
                    ],
                    if (topic.participantsCount != null) ...[
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 12.sp,
                        color: Theme.of(context).hintColor,
                      ),
                      2.hGap,
                        Text(
                        '${topic.participantsCount}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            child: IconButton(
              onPressed: () {
                controller.startReply(topic.currentPostNumber, topic.title);
              },
              icon: Icon(CupertinoIcons.reply, size: 22.w),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReplyInput(BuildContext context, TopicDetail topic) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomPadding + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.w),
          topRight: Radius.circular(12.w),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.9),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.w),
            width: 36.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          // 回复引用
          Obx(() {
            if (controller.replyToPostNumber.value == null) {
              return const SizedBox();
            }
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.reply, size: 16.sp, color: theme.hintColor),
                      8.hGap,
                      Text(
                        '回复 #${controller.replyToPostNumber}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: controller.cancelReply,
                        icon: Icon(
                          CupertinoIcons.clear,
                          size: 18.sp,
                          color: theme.hintColor,
                        ),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.all(4.w),
                        ),
                      ),
                    ],
                  ),
                  if (controller.replyPostTitle.value != null) ...[
                    4.vGap,
                    Text(
                      controller.replyPostTitle.value!
                          .replaceAll(RegExp(r'<[^>]*>'), ''),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.hintColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          }),
          // 输入区域
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: 120.h,
                    maxHeight: 200.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      controller.replyContent.value = value;
                      controller.updateTypingTime();
                    },
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                        hintText: AppConst.posts.replyPlaceholder,
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: theme.hintColor.withValues(alpha: 0.3),
                        ),
                        contentPadding: EdgeInsets.all(16.w),
                        border: InputBorder.none,
                        isDense: true,
                        fillColor: AppColors.transparent),
                  ),
                ),
                16.vGap,
                // 发送按钮
                Obx(() => AnimatedScale(
                      scale: controller.replyContent.value.isEmpty ? 0.8 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedOpacity(
                        opacity: controller.replyContent.value.isEmpty ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44.h,
                          child: DisButton(
                              text: AppConst.posts.send,
                              onPressed: controller.sendReply,
                              type: ButtonType.transform,
                              useWidthAnimation: true,
                              loading: controller.isSending.value),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


