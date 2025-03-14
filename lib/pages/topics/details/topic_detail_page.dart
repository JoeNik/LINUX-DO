import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/pages/topics/details/widgets/post_reply.dart';
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_popup.dart';
import 'package:linux_do/widgets/owner_banner.dart';
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

class TopicDetailPage extends GetView<TopicDetailController> with ToastMixin {
  const TopicDetailPage({super.key});

  // @override
  // TopicDetailController get controller {
  //   var topicId = Get.arguments as int;
  //   return Get.find<TopicDetailController>(tag: 'topic_$topicId');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Obx(() {
            final topic = controller.topic.value;
            return StateView(
              state: _getViewState(),
              errorMessage: controller.errorMessage.value,
              onRetry: controller.fetchTopicDetail,
              shimmerView: const ShimmerDetails(),
              child: topic == null
                  ? const SizedBox()
                  : _buildContent(context, topic),
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
                  currentIndex: controller.currentPostIndex.value,
                  controller: controller,
                  onIndexChanged: (index) {
                    if (!controller.isLoading.value) {
                      controller.scrollToPost(index);
                    }
                  }),
            );
          }),
        ],
      ),
    );
  }

  ViewState _getViewState() {
    if (controller.isLoading.value) {
      return ViewState.loading;
    }
    if (controller.hasError.value) {
      return ViewState.error;
    }
    return ViewState.content;
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
        _buildMoreButton(context),
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

  CustomPopup _buildMoreButton(BuildContext context) {
    return CustomPopup(
      backgroundColor: Theme.of(context).cardColor,
      arrowColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.all(14).w,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.handleOpenInBrowser(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.globe,
                    size: 16.w,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                2.hGap,
                Text(
                  '浏览器打开',
                  style: TextStyle(
                    fontSize: 14.w,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          8.vGap,
          GestureDetector(
              onTap: () => _showCategoryDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.star_circle,
                      size: 16.w,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  2.hGap,
                  Text(
                    '本地收藏',
                    style: TextStyle(
                      fontSize: 14.w,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ))
        ],
      ),
      child: const Icon(CupertinoIcons.ellipsis_circle),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16).w,
            topRight: const Radius.circular(16).w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部把手和标题
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12).w,
              child: Column(
                children: [
                  Container(
                    width: 40.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                  ),
                  16.vGap,
                  Text(
                    '选择分类',
                    style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // 分类列表
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16).w,
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 16.w,
                  children: AppConst.bookmarkCategories.map((category) {
                    final hue = (category.hashCode % 12) * 30.0;
                    final color = HSLColor.fromAHSL(1.0, hue, 0.6, 0.8).toColor();
                    final iconData = _getCategoryIcon(category);
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          Get.back(result: category);
                          bool isSuccess = await controller.bookmarkTopic(category);
                          if (isSuccess) {
                            showSuccess('收藏成功');
                          } 
                        },
                        borderRadius: BorderRadius.circular(12).w,
                        child: Container(
                          width: (Get.width - 56.w) / 3,
                          padding: const EdgeInsets.symmetric(vertical: 16).w,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12.w),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconData,
                                size: 28.w,
                                color: color,
                              ),
                              8.vGap,
                              Text(
                                category,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.w,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // 底部取消按钮
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16).w,
              child: DisButton(
                    text: '取消',
                    type: ButtonType.outline,
                    onPressed: () => Get.back(),
                  ),
            ),
            12.vGap
          ],
        ),
      ),
      enterBottomSheetDuration: 300.milliseconds,
      exitBottomSheetDuration: 200.milliseconds,
    );
  }
  
  // 根据分类名获取对应的图标
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '开发调优':
        return CupertinoIcons.wand_rays;
      case '文档共建':
        return CupertinoIcons.doc_text;
      case '非我莫属':
        return CupertinoIcons.person_2;
      case '扬帆起航':
        return CupertinoIcons.paperplane_fill;
      case '福利羊毛':
        return CupertinoIcons.gift;
      case '运营反馈':
        return CupertinoIcons.chat_bubble_2;
      case '资源荟萃':
        return CupertinoIcons.rectangle_stack;
      case '跳蚤市场':
        return CupertinoIcons.cart;
      case '读书成诗':
        return CupertinoIcons.book;
      case '前沿快讯':
        return CupertinoIcons.news;
      case '搞七捻三':
        return CupertinoIcons.lightbulb;
      case '深海幽域':
        return CupertinoIcons.moon_stars;
      default:
        return CupertinoIcons.tag;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return PageHeader(controller: controller);
  }

  Widget _buildContent(BuildContext context, TopicDetail topic) {
    return Stack(
      children: [
        Positioned.fill(
          bottom: controller.isReplying.value ? 380.w : 0,
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
                    return Obx(() => controller.hasPrevious.value &&
                            !controller.isLoading.value
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 10).w,
                            alignment: Alignment.center,
                            child: DisRefreshLoading())
                        : const SizedBox());
                  }

                  // 底部加载指示器
                  if (index == controller.replyTree.length + 1) {
                    return Obx(() => controller.hasMore.value &&
                            !controller.isLoading.value
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 10).w,
                            alignment: Alignment.center,
                            child: DisRefreshLoading())
                        : const SizedBox());
                  }

                  // 帖子内容
                  if (controller.isLoading.value ||
                      index - 1 >= controller.replyTree.length) {
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
        Obx(() {
          final isReplying = controller.isReplying.value;
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            bottom: isReplying ? 0 : -380.w,
            left: 0,
            right: 0,
            child: _buildReplyInput(context, topic),
          );
        }),
      ],
    );
  }

  Widget _buildPostItem(BuildContext context, PostNode node) {
    final isReply = node.post.replyToPostNumber != null;
    final barWidth = 8.w;

    return GetBuilder<TopicDetailController>(
      id: 'post_${node.post.postNumber}',
      builder: (controller) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4).w,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(12)).w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)).w,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: isReply ? 12.w + barWidth : 12.w,
                      right: isReply ? 12.w + barWidth : 12.w,
                      top: isReply ? 24.w : 12.w,
                      bottom: 12.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        6.vGap,
                        PostHeader(
                            post: node.post,
                            title: controller.topic.value?.title),
                        2.vGap,
                        PostContent(
                            node: node,
                            isReply: isReply,
                            controller: controller),
                        Divider(
                          height: 1.h,
                          color: Theme.of(context).dividerColor,
                        ),
                        12.vGap,
                        PostFooter(post: node.post, controller: controller),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4)
                          .w,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(12).w,
                          bottomLeft: const Radius.circular(12).w,
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
                  isReply
                      ? Positioned(
                          top: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              if (node.post.replyToPostNumber != null) {
                                controller.scrollToPost(
                                    node.post.replyToPostNumber! - 1);
                              }
                            },
                            child: PostReply(
                                post: node.post, controller: controller),
                          ),
                        )
                      : const SizedBox(),
                  node.post.isForumMaster(controller.topic.value?.userId ?? 0)
                      ? Positioned(
                          bottom: 14.w,
                          right: 14.w,
                          child: OwnerBanner(
                            onTap: () {
                              controller.startReply(
                                  node.post.postNumber,
                                  node.post.cooked,
                                  node.post.name?.isEmpty ?? true
                                      ? node.post.username
                                      : node.post.name);
                            },
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ],
        ),
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
          bottomLeft: const Radius.circular(12).w,
          bottomRight: const Radius.circular(12).w,
        ),
      ),
      child: Row(
        children: [
          CachedImage(
            imageUrl: createUser?.getAvatarUrl(),
            width: 25.w,
            height: 25.w,
            circle: !(createUser?.isWebMaster() ?? false),
            borderRadius: BorderRadius.circular(4).w,
            placeholder: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
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
                          ? Theme.of(context).primaryColor
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
                controller.startReply(
                    null, topic.title, topic.details?.createdBy?.username);
              },
              icon: Icon(CupertinoIcons.reply_thick_solid, size: 18.w),
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
          topLeft: const Radius.circular(12).w,
          topRight: const Radius.circular(12).w,
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
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: controller.cancelReply,
                icon: Icon(
                  CupertinoIcons.clear,
                  size: 18.w,
                  color: theme.hintColor,
                ),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.all(4.w),
                ),
              ),
            ],
          ),
          // 回复引用
          Obx(() {
            if (controller.replyToPostNumber.value == null) {
              return const SizedBox();
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12).w,
              padding: const EdgeInsets.all(12).w,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(12)).w,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.reply,
                          size: 16.sp, color: theme.hintColor),
                      8.hGap,
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '回复',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.hintColor,
                                fontFamily: AppFontFamily.dinPro,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: ' #${controller.replyToPostNumber}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFontFamily.dinPro,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  4.vGap,
                  Text(
                    controller.replyPostTitle.value ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.textTheme.bodyMedium?.color,
                      fontFamily: AppFontFamily.dinPro,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  if (controller.replyPostUser.value != null) ...[
                    4.vGap,
                    Text(
                      controller.replyPostUser.value ?? '',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: theme.hintColor,
                        fontFamily: AppFontFamily.dinPro,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ],
                ],
              ),
            );
          }),
          // 输入区域
          Padding(
            padding: const EdgeInsets.all(12).w,
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: 120.w,
                    maxHeight: 200.w,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(12)).w,
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextField(
                    controller: controller.contentController,
                    onChanged: (value) {
                      controller.replyContent.value = value;
                      controller.updateTypingTime();
                    },
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      fontSize: 15.w,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                        hintText: AppConst.posts.replyPlaceholder,
                        hintStyle: TextStyle(
                          fontSize: 13.w,
                          color: theme.hintColor.withValues(alpha: 0.3),
                        ),
                        contentPadding: const EdgeInsets.all(10).w,
                        border: InputBorder.none,
                        isDense: true,
                        fillColor: AppColors.transparent),
                  ),
                ),
                16.vGap,

                // 图片上传区域
                Row(
                  children: [
                    // 添加图片按钮
                    Obx(() => Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)).w,
                          ),
                          child: controller.isUploading.value
                              ? Center(
                                  child: DisRefreshLoading(
                                    fontSize: 8.w,
                                  ),
                                )
                              : Material(
                                  color: AppColors.transparent,
                                  child: InkWell(
                                    onTap: controller.pickAndUploadImage,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.photo,
                                          size: 16.w,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                        ),
                                        5.vGap,
                                        Text(
                                          AppConst.createPost.addImage,
                                          style: TextStyle(
                                            fontSize: 10.w,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        )),
                    16.hGap,
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 已上传图片列表
                              Obx(() {
                                if (controller.uploadedImages.isEmpty) {
                                  return Container();
                                }
                                return SizedBox(
                                  height: 60.w,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller.uploadedImages.length,
                                    separatorBuilder: (context, index) =>
                                        8.hGap,
                                    itemBuilder: (context, index) {
                                      final image =
                                          controller.uploadedImages[index];
                                      return Stack(
                                        children: [
                                          Container(
                                            width: 60.w,
                                            height: 60.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.w),
                                              image: DecorationImage(
                                                image: NetworkImage(image.url),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 4.w,
                                            top: 4.w,
                                            child: InkWell(
                                              onTap: () =>
                                                  controller.removeImage(image),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4).w,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.5),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  CupertinoIcons.xmark,
                                                  size: 8.w,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          height: 44.w,
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
