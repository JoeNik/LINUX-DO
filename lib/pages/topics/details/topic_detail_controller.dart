import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../controller/global_controller.dart';
import '../../../models/topic_detail.dart';
import '../../../models/upload_image_response.dart';
import '../../../net/api_service.dart';
import '../../../utils/log.dart';
import '../../../utils/mixins/toast_mixin.dart';
import '../../../utils/storage_manager.dart';
import '../../../routes/app_pages.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:linux_do/const/app_spacing.dart';

class TopicDetailController extends BaseController
    with WidgetsBindingObserver, Concatenated {
  final topicId = 0.obs;
  final topic = Rx<TopicDetail?>(null);
  final hasMore = true.obs;
  final hasPrevious = true.obs;
  final isLoadingMore = false.obs;
  final isLoadingPrevious = false.obs;
  // 用于控制初始滚动位置
  final initialScrollIndex = 0.obs;

  final ApiService apiService = Get.find();
  // 添加ScrollablePositionedList需要的控制器
  final itemScrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

  // 存储上次访问的帖子编号
  String get _topicPostKey => 'topic_post_${topicId.value}';

  // 存储已加载的post ids，用于避免重复加载
  final Set<int> loadedPostIds = {};

  // 是否正在发送
  final isSending = false.obs;

  // 阅读时间追踪相关变量
  final _lastTrackTime = DateTime.now().obs;
  final _visiblePostNumbers = <int>{}.obs;
  Timer? _debounceTimer;
  static const _debounceDelay = Duration(milliseconds: 1000); // 1秒防抖延迟

  // 用于存储帖子树结构
  final replyTree = <PostNode>[].obs;

  // 存储点赞状态的Map
  final likedPosts = <int, bool>{}.obs;
  final postScores = <int, int>{}.obs;
  // 存储书签状态的Map
  final bookmarkedPosts = <int, bool>{}.obs;

  // 回复相关
  final replyContent = ''.obs;
  final isReplying = false.obs;
  final replyToPostNumber = Rx<int?>(null);
  final replyPostTitle = Rx<String?>(null);
  final replyPostUser = Rx<String?>(null);
  final clientId = DateTime.now().millisecondsSinceEpoch.toString();
  Timer? _presenceTimer;
  Timer? _draftTimer;

  // 控制 _buildFooder 的可见性
  final isFooderVisible = false.obs;

  // 记录开始回复的时间
  final _replyStartTime = DateTime.now().millisecondsSinceEpoch.obs;
  // 记录最后一次输入的时间
  final _lastTypingTime = DateTime.now().millisecondsSinceEpoch.obs;

  /// 是否正在节流
  bool _isThrottling = false;

  // 当前帖子索引
  final currentPostIndex = 0.obs;
  final isManualScrolling = false.obs;

    // 图片列表
  final uploadedImages = <UploadImageResponse>[].obs;
  // 正在上传图片
  final isUploading = false.obs;
  // 回复内容控制器
  final contentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    topicId.value = Get.arguments as int;
    final postNumber = Get.parameters['postNumber'];
    
    itemPositionsListener.itemPositions.addListener(_onScroll);

    if (postNumber != null) {
      fetchTopicDetail(postNumber: int.parse(postNumber));
    } else {
      fetchTopicDetail();
    }
    // 添加应用生命周期监听
    WidgetsBinding.instance.addObserver(this);

    // 监听topic变化，重建回复树
    ever(topic, (_) => _buildReplyTree());

    // 初始化点赞数据
    ever(topic, (_) => _initPostScores());

    // 启动在线状态更新定时器
    // _startPresenceTimer();

    // 启动草稿保存定时器
    // 暂时不保存草稿
    // _startDraftTimer();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    itemPositionsListener.itemPositions.removeListener(_onScroll);
    
    // 优化在页面关闭时保存最后的阅读位置
    final positions = itemPositionsListener.itemPositions.value.toList();
    if (positions.isNotEmpty) {
      positions.sort((a, b) => a.index.compareTo(b.index));
      // 找到第一个可见的帖子（可见度超过50%的）
      for (var position in positions) {
        if (position.index >= 1 && position.index - 1 < replyTree.length) {
          if (position.itemLeadingEdge < 0.5 && position.itemTrailingEdge > 0.5) {
            final node = replyTree[position.index - 1];
            if (node.post.postNumber != null) {
              StorageManager.setData(_topicPostKey, node.post.postNumber);
              break;
            }
          }
        }
      }
      
      // 如果没有找到足够可见的帖子，使用第一个可见的帖子
      if (positions.first.index >= 1 && positions.first.index - 1 < replyTree.length) {
        final node = replyTree[positions.first.index - 1];
        if (node.post.postNumber != null) {
          StorageManager.setData(_topicPostKey, node.post.postNumber);
        }
      }
    }
    
    // 移除应用生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    _presenceTimer?.cancel();
    _draftTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 应用回到前台时更新
      //_updateTopicTiming();
    } else if (state == AppLifecycleState.paused) {
      // 应用进入后台前更新
      //_updateTopicTiming();
    }

  }

  void _debouncedUpdateTiming() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
    // _updateTopicTiming();
    });
  }

  void _onScroll() {
    if (_isThrottling) return;
    _isThrottling = true;

    Future.delayed(const Duration(milliseconds: 550), () {
      _isThrottling = false;
    });

    final positions = itemPositionsListener.itemPositions.value.toList();
    if (positions.isEmpty) return;

    positions.sort((a, b) => a.index.compareTo(b.index));
    final visiblePosts = <int>{};

    if (!isManualScrolling.value) {
      for (var position in positions) {
        if (position.index >= 1 && position.index - 1 < replyTree.length) {
          if (position.itemLeadingEdge < 0.5 && position.itemTrailingEdge > 0.5) {
            final node = replyTree[position.index - 1];
            if (node.post.postNumber != null) {
              // 使用实际的楼层号减1作为索引
              currentPostIndex.value = node.post.postNumber! - 1;
              visiblePosts.add(node.post.postNumber!);
              break;
            }
          }
        }
      }
    }

    _visiblePostNumbers.value = visiblePosts;
    _debouncedUpdateTiming();

    // 检查是否需要加载更多
    if (positions.isNotEmpty) {
      // 检查是否需要向上加载
      final firstVisibleItem = positions.first;
      if (firstVisibleItem.itemLeadingEdge <= 0.1 &&
          firstVisibleItem.index <= 3 &&
          !isLoadingPrevious.value &&
          hasPrevious.value) {
        l.d('触发向上加载: ${firstVisibleItem.index}');
        loadPrevious();
      }

      // 检查是否需要向下加载
      final lastVisibleItem = positions.last;
      final actualLastIndex = lastVisibleItem.index - 1;
      if (lastVisibleItem.itemTrailingEdge >= 0.9 &&
          actualLastIndex >= replyTree.length - 5 &&
          !isLoadingMore.value &&
          hasMore.value) {
        l.d('触发向下加载: ${lastVisibleItem.index}');
        loadMore();
      }
    }
  }

  // 更新阅读时间
  // 暂时不更新阅读时间
  Future<void> _updateTopicTiming() async {
    final visiblePosts = _visiblePostNumbers.value;
    if (visiblePosts.isEmpty) return;

    final now = DateTime.now();
    final timeSpent = now.difference(_lastTrackTime.value).inSeconds;
    if (timeSpent <= 0) return;

    try {
      // 构建计时映射，为每个可见的帖子记录阅读时间
      final timings = {
        for (var postNumber in visiblePosts) postNumber.toString(): timeSpent
      };

      await apiService.updateTopicTiming(
        topicId.value.toString(),
        timeSpent,
        timings,
      );

      l.d('阅读时间更新: $timings');

      _lastTrackTime.value = now;
    } catch (e) {
      l.e('更新阅读时间失败: $e');
    }
  }

  /// 向上加载 获取更早的帖子
  /// 还有问题!!!
  Future<void> loadPrevious() async {
    if (!hasPrevious.value || isLoadingPrevious.value) return;

    try {
      isLoadingPrevious.value = true;

      final currentStream = topic.value?.postStream?.stream ?? [];
      final currentPosts = topic.value?.postStream?.posts ?? [];

      if (currentStream.isEmpty || currentPosts.isEmpty) {
        return;
      }

      // 找到"可见区域最顶上"这条帖子的唯一标识
      // （因为 index=0 是顶部加载指示器，所以真正的第一条帖子一般是 index=1）
      final positions = itemPositionsListener.itemPositions.value.toList();
      positions.sort((a, b) => a.index.compareTo(b.index));
      final firstVisibleIndex = positions.first.index;
      // 这个索引对应当前Posts里的下标 = firstVisibleIndex - 1
      final targetIndexInArray = firstVisibleIndex - 1;

      // 边界保护：确保不越界
      Post? targetPost;
      if (targetIndexInArray >= 0 && targetIndexInArray < currentPosts.length) {
        targetPost = currentPosts[targetIndexInArray];
      }

      // 计算第一个已加载的帖子在stream中的位置
      final firstLoadedPostIndex =
          currentStream.indexOf(currentPosts.first.id ?? 0);

      if (firstLoadedPostIndex <= 0) {
        l.d('没有更早的帖子了');
        hasPrevious.value = false;
        return;
      }

      // 获取之前20个未加载的post ids
      final previousPostIds = <int>[];
      var index = firstLoadedPostIndex - 1;
      while (index >= 0 && previousPostIds.length < 20) {
        final postId = currentStream[index];
        if (!loadedPostIds.contains(postId)) {
          previousPostIds.insert(0, postId);
          l.d('待加载的ID: $postId');
        } else {
          l.d('ID已加载过: $postId');
        }
        index--;
      }

      if (previousPostIds.isEmpty) {
        hasPrevious.value = false;
        return;
      }

      // 请求获取新的帖子数据
      final response = await apiService.getTopicPosts(
        topicId.value.toString(),
        postIds: previousPostIds.map((id) => id.toString()).toList(),
      );

      // 合并帖子数据
      final newPosts = response.postStream?.posts ?? [];

      if (newPosts.isEmpty) {
        hasPrevious.value = false;
        return;
      }

      // 记录新加载的post ids
      loadedPostIds.addAll(newPosts.map((p) => p.id ?? 0));

      // 先注释掉 暂时不确定接口是否按照时间排序的
      // newPosts.sort((a, b) => a.postNumber!.compareTo(b.postNumber!));

      // 在列表前面插入新加载的帖子
      topic.update((val) {
        val?.postStream?.posts?.insertAll(0, newPosts);
      });

      // 重新定位到插入前的"第一可见帖"
      if (targetPost != null) {
        Future.microtask(() {
          final updatedPosts = topic.value?.postStream?.posts ?? [];
          // 找到原来那条帖子下标
          final newIndex =
              updatedPosts.indexWhere((p) => p.id == targetPost?.id);

          if (newIndex >= 0) {
            final scrollIndex = newIndex + 1;
            itemScrollController.jumpTo(index: scrollIndex);
          }
        });
      }

      // 再根据 stream 判断是否还有更早的帖子
      hasPrevious.value = index >= 0;
    } catch (e) {
      l.e('加载之前的帖子失败: $e');
    } finally {
      isLoadingPrevious.value = false;
    }
  }

  Future<void> fetchTopicDetail({int? postNumber}) async {
    try {
      isLoading.value = true;
      clearError();

      // 清空所有数据和状态
      topic.value = null;
      loadedPostIds.clear();
      hasMore.value = false;
      hasPrevious.value = false;
      replyTree.clear();
      likedPosts.clear();
      postScores.clear();
      bookmarkedPosts.clear();
      initialScrollIndex.value = 0;

      // 使用传入的楼层号，如果没有则使用上次浏览的位置
      final targetPostNumber = postNumber ?? StorageManager.getInt(_topicPostKey);
      final page = targetPostNumber != null ? "/$targetPostNumber" : "/1";

      final response = await apiService.getTopicDetail(
        topicId.value.toString(),
        page: page,
      );

      topic.value = response;
      
      // 设置初始滚动位置
      if (targetPostNumber != null) {
        final posts = response.postStream?.posts ?? [];
        final index = posts.indexWhere((p) => p.postNumber == targetPostNumber);
        if (index >= 0) {
          initialScrollIndex.value = index + 1; 
          currentPostIndex.value = index;  // 使用实际的索引而不是楼层号减1
          l.d('设置初始位置 - targetPostNumber: $targetPostNumber, index: $index');
        }
      }

      // 记录已加载的post ids
      final posts = response.postStream?.posts ?? [];
      final stream = response.postStream?.stream ?? [];
      loadedPostIds.addAll(posts.map((p) => p.id ?? 0));

      // 根据stream和当前加载的posts判断是否还有更多
      hasMore.value =
          stream.isNotEmpty && (posts.isEmpty || stream.last != posts.last.id);

      // 判断是否有更早的帖子
      if (posts.isNotEmpty && stream.isNotEmpty) {
        final firstLoadedPostIndex = stream.indexOf(posts.first.id ?? 0);
        hasPrevious.value = firstLoadedPostIndex > 0;
      }

      // 初始化点赞和书签数据
      _initPostScores();
      
    } catch (e) {
      l.e('获取帖子详情失败: $e');
      setError('获取帖子详情失败');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;

      final currentStream = topic.value?.postStream?.stream ?? [];
      final currentPosts = topic.value?.postStream?.posts ?? [];
      if (currentStream.isEmpty || currentPosts.isEmpty) return;

      // 获取最后一个帖子的ID
      final lastPost = currentPosts.last;
      final lastLoadedPostIndex = currentStream.indexOf(lastPost.id ?? 0);
      if (lastLoadedPostIndex == -1) return;

      l.d('当前最后一个帖子ID: ${lastPost.id}, postNumber: ${lastPost.postNumber}');

      // 获取后续20个未加载的post ids
      final nextPostIds = <int>[];
      var index = lastLoadedPostIndex + 1;
      while (index < currentStream.length && nextPostIds.length < 20) {
        final postId = currentStream[index];
        if (!loadedPostIds.contains(postId)) {
          nextPostIds.add(postId);
          l.d('待加载的ID: $postId');
        }
        index++;
      }

      if (nextPostIds.isEmpty) {
        hasMore.value = false;
        return;
      }

      final response = await apiService.getTopicPosts(
        topicId.value.toString(),
        postIds: nextPostIds.map((id) => id.toString()).toList(),
      );

      // 合并帖子数据
      final newPosts = response.postStream?.posts ?? [];
      if (newPosts.isEmpty) {
        hasMore.value = false;
        return;
      }

      // 记录新加载的post ids
      loadedPostIds.addAll(newPosts.map((p) => p.id ?? 0));

      // 添加新加载的帖子
      topic.update((val) {
        if (val?.postStream?.posts != null) {
          // 按照stream中的顺序添加新帖子
          for (var postId in nextPostIds) {
            final newPost = newPosts.firstWhere((p) => p.id == postId);
            val!.postStream!.posts!.add(newPost);
          }
        }
      });

      // 重新构建回复树
      _buildReplyTree();

      // 更新是否还有更多
      hasMore.value = index < currentStream.length;

      // 强制更新UI
      replyTree.refresh();

      l.d('加载完成，当前帖子数: ${topic.value?.postStream?.posts?.length}, 最后一个帖子编号: ${topic.value?.postStream?.posts?.last.postNumber}');
    } catch (e) {
      l.e('加载更多失败: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshTopicDetail() async {
    // loadedPostIds.clear();
    await fetchTopicDetail();
  }

  /// 打开链接
  void launchUrl(String? url) {
    if (url == null || url.isEmpty) return;

    final savedBrowserTips = StorageManager.getBool(AppConst.identifier.browserTips) ?? false;

    if (!savedBrowserTips) {
      Get.toNamed(Routes.WEBVIEW, arguments: url);
      return;
    }
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.w),
            topRight: Radius.circular(16.w),
          ),
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
                color: Theme.of(Get.context!).dividerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            // 标题
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
              child: Text(
                AppConst.posts.openBrowser,
                style: TextStyle(
                  fontSize: 16.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // URL 预览
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                url,
                style: TextStyle(
                  fontSize: 12.w,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontFamily.dinPro,
                  color: Theme.of(Get.context!).hintColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            16.vGap,
            // 选项按钮
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildOptionButton(
                    icon: CupertinoIcons.compass,
                    title: AppConst.posts.openInApp,
                    onTap: () {
                      Get.back();
                      Get.toNamed(Routes.WEBVIEW, arguments: url);
                    },
                  ),
                  12.vGap,
                  _buildOptionButton(
                    icon: CupertinoIcons.arrowshape_turn_up_right_circle,
                    title: AppConst.posts.openInBrowser,
                    onTap: () async {
                      Get.back();
                      try {
                        await launchUrlString(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        l.e('打开浏览器失败: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
            // 底部安全区域
            SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
          ],
        ),
      ),
      enterBottomSheetDuration: const Duration(milliseconds: 200),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.w),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(Get.context!).dividerColor.withOpacity(0.1),
            ),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.w),
              12.hGap,
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.w,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16.w,
                color: Theme.of(Get.context!).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建帖子树结构
  void _buildReplyTree() {
    if (topic.value?.postStream?.posts == null) return;

    final posts = topic.value!.postStream!.posts!;
    final Map<int?, List<Post>> replyMap = {};

    // 按照回复对象分组
    for (var post in posts) {
      final replyTo = post.replyToPostNumber;
      if (!replyMap.containsKey(replyTo)) {
        replyMap[replyTo] = [];
      }
      replyMap[replyTo]!.add(post);
    }

    // 直接使用原始帖子列表构建树，保持原始顺序
    replyTree.value = posts.map((post) {
      final replies = replyMap[post.postNumber] ?? [];
      return PostNode(post, replies.map((reply) => PostNode(reply)).toList());
    }).toList();

    l.d('构建树完成，节点数量: ${replyTree.length}');
  }

  // 点赞/取消点赞
  Future<void> toggleLike(Post post) async {
    try {
      final postNumber = post.postNumber!;
      final isLiked = likedPosts[postNumber] ?? false;

      // 先更新UI状态
      likedPosts[postNumber] = !isLiked;
      final currentScore = postScores[postNumber] ?? 0;
      postScores[postNumber] = currentScore + (isLiked ? -1 : 1);

      // 调用API
      final response = await apiService.togglePostLike(post.id.toString());

      // 根据API响应更新最终状态
      final actionsSummary = response.actionsSummary;
      if (actionsSummary != null && actionsSummary.isNotEmpty) {
        // 在 actionsSummary 中找到 id=2 的点赞动作
        final likeAction = actionsSummary.firstWhere(
          (action) => action['id'] == 2,
          orElse: () => {'can_act': true, 'count': 0},
        );

        // 这里非常奇怪 服务器的数据好像没更新~
        // final canAct = likeAction['can_act'] ?? true;
        // likedPosts[postNumber] = !canAct; // 如果 can_act 为 false，说明已经点赞
        // postScores[postNumber] = likeAction['count'] ?? 0;
      }

      l.d('点赞状态更新: postNumber=$postNumber, count=${postScores[postNumber]}');
    } catch (e, s) {
      l.e('点赞失败: $e -  \n$s');

      // 发生错误时恢复原状态
      final postNumber = post.postNumber!;
      final isLiked = likedPosts[postNumber] ?? false;
      likedPosts[postNumber] = !isLiked;
      final currentScore = postScores[postNumber] ?? 0;
      postScores[postNumber] = currentScore + (isLiked ? 1 : -1);
    }
  }

  // 获取帖子的点赞数
  int getPostScore(Post post) {
    if (post.postNumber == null) return 0;
    return postScores[post.postNumber!] ?? 0;
  }

  // 获取帖子是否已点赞
  bool isPostLiked(Post post) {
    if (post.postNumber == null) return false;
    return likedPosts[post.postNumber!] ?? false;
  }

  // 初始化点赞数据
  void _initPostScores() {
    if (topic.value?.postStream?.posts != null) {
      for (var post in topic.value!.postStream!.posts!) {
        if (post.postNumber != null) {
          postScores[post.postNumber!] = post.reactionUsersCount ?? 0;
          // 使用 currentUserReaction 判断是否已点赞
          likedPosts[post.postNumber!] = post.currentUserReaction != null;
          // 初始化书签状态
          bookmarkedPosts[post.postNumber!] = post.bookmarked ?? false;
        }
      }
    }
  }

  // 开始回复
  void startReply([int? postNumber, String? title, String? username]) {
    replyToPostNumber.value = postNumber;
    if (title != null && title.isNotEmpty) {
      // 清理HTML标签并限制长度
      final cleanTitle = title
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'\n+'), ' ')
          .trim();
      replyPostTitle.value = cleanTitle;
    } else {
      replyPostTitle.value = null;
    }
    // 处理用户名
    if (username != null && username.isNotEmpty) {
      replyPostUser.value = username;
    } else {
      replyPostUser.value = null;
    }
    isReplying.value = true;
    _replyStartTime.value = DateTime.now().millisecondsSinceEpoch;
    _lastTypingTime.value = _replyStartTime.value;
  }


  // 取消回复
  void cancelReply() {
    replyContent.value = '';
    replyToPostNumber.value = null;
    replyPostTitle.value = null;
    isReplying.value = false;
  }

  // 更新打字时间
  void updateTypingTime() {
    _lastTypingTime.value = DateTime.now().millisecondsSinceEpoch;
  }

  // 发送回复
  Future<void> sendReply() async {
    final content = replyContent.value.trim();
    if (content.isEmpty) return;

    try {
      isSending.value = true;

      // 先不计算打字时间了
      final now = DateTime.now().millisecondsSinceEpoch;
      final typingDuration = now - _lastTypingTime.value;
      final composerDuration = now - _replyStartTime.value;

      // 发送回复
      final response = await apiService.replyPost(
        topicId.value.toString(),
        content,
        true,
        'regular',
        '',
        replyToPostNumber: replyToPostNumber.value,
      );

      showSuccess(AppConst.posts.replySuccess);


      // 清空回复内容
      replyContent.value = '';
      replyToPostNumber.value = null;
      replyPostTitle.value = null;
      isReplying.value = false;

      // 刷新帖子列表
      await refreshTopicDetail();

      // 滚动到新回复
      if (response.post.postNumber != null) {
        final posts = topic.value?.postStream?.posts ?? [];
        final index =
            posts.indexWhere((p) => p.postNumber == response.post.postNumber);
        if (index != -1) {
          itemScrollController.scrollTo(
            index: index + 1,
            duration: const Duration(milliseconds: 300),
          );
        }
      }
    } catch (e, s) {
      l.e('发送回复失败: $e -  \n$s');
      showSnackbar(
          title: AppConst.commonTip,
          message: AppConst.posts.replyFailed,
          type: SnackbarType.error);
    } finally {
      isSending.value = false;
    }
  }

  // 启动在线状态更新定时器
  void _startPresenceTimer() {
    _presenceTimer?.cancel();
    _presenceTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isReplying.value) {
        apiService.updateChannelPresence(
          clientId,
          '/discourse-presence/reply/${topicId.value}',
        );
      }
    });
  }

  // 启动草稿保存定时器
  // 暂时不保存草稿
  // ignore: unused_element
  void _startDraftTimer() {
    _draftTimer?.cancel();
    _draftTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isReplying.value && replyContent.value.isNotEmpty) {
        final data = jsonEncode({
          'reply': replyContent.value,
          'action': 'reply',
          'categoryId': topic.value?.categoryId ?? 0,
          'tags': [],
          'archetypeId': 'regular',
          'metaData': null,
          'composerTime': DateTime.now().millisecondsSinceEpoch,
          'typingTime': 2400,
        });

        apiService.saveDraft(
          'topic_${topicId.value}',
          0,
          data,
          clientId,
          false,
        );
      }
    });
  }

  // 滚动到指定帖子
  Future<void> scrollToPost(int postNumber) async {
    try {
      isManualScrolling.value = true;
      if (!_isPostLoaded(postNumber)) {
        await fetchTopicDetail(postNumber: postNumber);
      }
      final index = replyTree.indexWhere((node) => node.post.postNumber == postNumber);
      if (index != -1) {
        // 保存当前阅读位置
        StorageManager.setData(_topicPostKey, postNumber);
        itemScrollController.scrollTo(
          index: index + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } finally {
      // 延迟重置手动滚动标志，确保滚动动画完成后再重置
      Future.delayed(const Duration(milliseconds: 350), () {
        isManualScrolling.value = false;
      });
    }
  }

  void copyPost(Post post) {
    Clipboard.setData(ClipboardData(
        text: '${HttpConfig.baseUrl}${post.postUrl ?? ''}?u=$userName'));
    showSuccess(AppConst.posts.copySuccess);
  }

  // 举报帖子
  void reportPost(Post post, String reason, [String? customDesc]) async {
    try {
      // await apiService.flagPost(
      //   post.id.toString(),
      //   _getFlagTypeId(reason),
      //   false,
      //   customDesc ?? '',
      //   false,
      // );
      Get.back(); // 关闭弹窗
      showError(AppConst.posts.reportSuccess);
    } catch (e, s) {
      l.e('举报失败: $e -  \n$s');
      showError(AppConst.posts.reportFailed);
    }

  }

  // 获取举报类型ID
  int _getFlagTypeId(String flagType) {
    switch (flagType) {
      case 'off_topic':
        return 3;
      case 'inappropriate':
        return 4;
      case 'spam':
        return 8;
      case 'notify_moderators':
        return 7;
      default:
        return 7; // 默认为通知版主
    }
  }

  // 选择并上传图片
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      isUploading.value = true;
      try {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final originalFileName = pickedFile.path.split('/').last;
        final shortFileName = _generateShortFileName(originalFileName);
        final sha1Checksum = _calculateSha1(bytes);
        
        // 创建 FormData
        final formData = dio.FormData.fromMap({
          'upload_type': 'composer',
          'pasted': false,
          'name': shortFileName,
          'type': 'image/${shortFileName.split('.').last}',
          'sha1_checksum': sha1Checksum,
          'file': await dio.MultipartFile.fromFile(
            pickedFile.path,
            filename: shortFileName,
          ),
        });
        
        final response = await apiService.uploadImage(
          GlobalController.clientId,
          formData,
        );
        
        uploadedImages.add(response);
        
        // 将图片插入到内容中
        final imageMarkdown = '\n![${response.originalFilename}|${response.width}x${response.height}](${response.shortUrl})\n';
        final currentContent = contentController.text;
        final cursorPosition = contentController.selection.baseOffset;
        
        if (cursorPosition >= 0) {
          final newContent = currentContent.substring(0, cursorPosition) +
              imageMarkdown +
              currentContent.substring(cursorPosition);
          contentController.text = newContent;
          contentController.selection = TextSelection.collapsed(
            offset: cursorPosition + imageMarkdown.length,
          );
        } else {
          contentController.text += imageMarkdown;
        }
      } catch (e,s) {
        showToast(AppConst.createPost.uploadFailed);
        debugPrint('Error uploading image: $e -- $s');
      } finally {
        isUploading.value = false;
      }
    }
  }

  // 删除图片
  void removeImage(UploadImageResponse image) {
    uploadedImages.remove(image);
    // 从内容中移除图片引用
    final imagePattern = '\\!\\[${image.originalFilename}\\|${image.width}x${image.height}\\]\\(${image.shortUrl}\\)';
    final regex = RegExp(imagePattern);
    contentController.text = contentController.text.replaceAll(regex, '');
  }


  // 计算文件的SHA1
  String _calculateSha1(List<int> bytes) {
    return sha1.convert(bytes).toString();
  }

  // 生成短文件名
  String _generateShortFileName(String originalFileName) {
    final extension = originalFileName.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final random = (1000 + Random().nextInt(9000)).toString();
    return 'img_${timestamp}_$random.$extension';
  }

  

  // 添加/删除书签
  Future<void> toggleBookmark(Post post) async {
    if (post.id == null || post.postNumber == null) return;

    // 保存原始状态
    final originalBookmarked = bookmarkedPosts[post.postNumber!] ?? false;

    try {
      // 立即更新本地状态
      bookmarkedPosts[post.postNumber!] = !originalBookmarked;
      post.bookmarked = !originalBookmarked;

      if (originalBookmarked) {
        await apiService.deleteBookmark(post.bookmarkId.toString());
      } else {
        await apiService.addBookmark(
          bookmarkableId: post.id,
        );
      }

      l.d('书签状态更新成功: ${post.id} - ${post.bookmarked}');
    } catch (e, s) {
      // 发生错误,恢复原始状态
      bookmarkedPosts[post.postNumber!] = originalBookmarked;
      post.bookmarked = originalBookmarked;
      l.e('添加/删除书签失败: $e -  \n$s');
    }
  }

  bool _isPostLoaded(int postNumber) {
    return topic.value?.postStream?.posts?.any((p) => p.postNumber == postNumber) == true;
  }

  // 更新楼层选择器的索引
  void updatePostSelectorIndex(int index, {bool shouldScroll = true}) {
    if (index < 0 || index >= (topic.value?.postsCount ?? 0)) return;
    
    // 设置当前索引
    currentPostIndex.value = index;
    
    if (shouldScroll) {
      // 将索引转换为楼层号 (index + 1)
      scrollToPost(index + 1);
    }
  }

  /// 删除帖子
  void deletePost(Post post) async{
    try {
      await apiService.deletePost(post.id.toString(),
      context: '/t/${topic.value?.id}/${post.postNumber}');
      showSuccess(AppConst.posts.deleteSuccess);
      /// 更新改帖子内容

      // final newPost = await apiService.getDeletedPosts(post.id.toString());
      // topic.value?.postStream?.posts?.removeWhere((p) => p.postNumber == post.postNumber);
      // topic.value?.postStream?.posts?.add(newPost);

      /// 本地更新cooked
      post.cooked = AppConst.posts.deletePost;
      update(['post_${post.postNumber}']);

    } catch (e, s) {
      l.e('删除帖子失败: $e -  \n$s');
      showError(AppConst.posts.deleteFailed);
    }

  }
}

// 帖子节点类

class PostNode {
  final Post post;
  final List<PostNode> children;

  PostNode(this.post, [this.children = const []]);
}
