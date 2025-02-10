import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/controller/global_controller.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/html_widget.dart';

import '../const/app_colors.dart';
import '../const/app_theme.dart';
import '../controller/base_controller.dart';
import '../models/category_data.dart';
import '../models/user.dart';
import '../net/api_service.dart';
import '../net/http_config.dart';
import '../net/success_response.dart';
import '../utils/badge.dart';
import '../utils/log.dart';
import 'state_view.dart';
import '../const/app_const.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarUrl;
  final double size;
  final double borderRadius;
  final Color backgroundColor;
  final bool circle;
  final Color? borderColor;
  final String username;
  final bool canOpenCard;
  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    this.size = 42,
    this.borderRadius = 4,
    this.backgroundColor = Colors.transparent,
    this.circle = true,
    this.borderColor,
    this.username = '',
    this.canOpenCard = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!canOpenCard) return;
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: UserInfoCard(
              username: username,
            ),
          ),
          barrierColor: Colors.black.withValues(alpha: 0.5),
        );
      },
      child: CachedImage(
          imageUrl: avatarUrl,
          width: size,
          height: size,
          circle: circle,
          backgroundColor: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          borderColor: borderColor ?? AppColors.transparent,
          showBorder: true),
    );
  }
}

class UserInfoCard extends GetView<UserInfoCardController> {
  final String username;
  const UserInfoCard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // 初始化controller
    Get.put(UserInfoCardController(username: username));

    return Container(
      width: 380.w,
      constraints: BoxConstraints(maxHeight: 450.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Obx(() => StateView(
            state: _getViewState(),
            child: Stack(
              children: [
                // 卡片背景半透明图片
                _buildBackground(context),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部背景和头像
                    _buildHeader(context),

                    // 用户信息
                    _buildUserInfo(context),

                    // 统计信息
                    _buildStats(context),

                    // 其他信息
                    _buildOtherInfo(context),

                    // 徽章
                    _buildBadges(context),

                    // 底部按钮
                    _buildActions(context),
                  ],
                ),

                // 加载中
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: controller._coverLoading.value
                      ? const Center(
                          child: DisSquareLoading(),
                        )
                      : const SizedBox(),
                )
              ],
            ),
          )),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final user = controller._userInfo.value?.user;
    if (user?.backgroundUrl == null) return const SizedBox();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Opacity(
        opacity: 0.16,
        child: CachedImage(
            imageUrl: user?.backgroundUrl ?? '',
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.w),
              topRight: Radius.circular(12.w),
            ),
            fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 顶部背景
        Container(
          height: 80.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.w),
              topRight: Radius.circular(12.w),
            ),
          ),
        ),

        // 头像
        Positioned(
          left: 20.w,
          bottom: -20.w,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    BorderRadius.circular(user?.id != 1 ? 30.w : 4.w)),
            child: AvatarWidget(
              avatarUrl: user?.getAvatar(80) ?? '',
              size: 60.w,
              username: username,
              circle: user?.id != 1,
              canOpenCard: false,
            ),
          ),
        ),

        // 关闭按钮
        Positioned(
          right: 8.w,
          top: 8.w,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 20.w,
            ),
          ),
        ),

        // 时间
        Positioned(
          left: 130,
          right: 30.w,
          bottom: -40.w,
          child: Row(
            children: [
              16.hGap,
              _buildTopTimeItem(
                  context, AppConst.user.joinTime, '${user?.cakedate}'),
              16.hGap,
              _buildTopTimeItem(context, AppConst.user.postTime,
                  _getRelativeTime(user?.lastPostedAt ?? '')),
            ],
          ),
        ),

        // 用户名
        Positioned(
          right: 0,
          left: 100.w,
          bottom: 8.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? username,
                style: TextStyle(
                  fontSize: 14.w,
                  fontFamily: AppFontFamily.dinPro,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              user?.admin == true
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Text(
                        AppConst.user.admin,
                        style: TextStyle(
                          fontSize: 9.w,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : 16.hGap,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(top: 10.w),
      padding: EdgeInsets.symmetric(vertical: 20.w),
      child: Center(
        child: Text(
          '@${user?.username ?? username}',
          style: TextStyle(
            fontSize: 8.w,
            fontFamily: AppFontFamily.dinPro,
            color: Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, AppConst.user.points,
              formattedScore(user?.gamificationScore ?? 0)),
          _buildStatItem(
              context, AppConst.user.follow, '${user?.totalFollowing ?? 0}'),
          _buildStatItem(
              context, AppConst.user.followers, '${user?.totalFollowers ?? 0}'),
          _buildStatItem(context, AppConst.user.solutions,
              '${user?.acceptedAnswers ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildTopTimeItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 10.w,
              fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          4.vGap,
          Text(
            label,
            style: TextStyle(
              fontSize: 8.w,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15.w,
            fontWeight: FontWeight.bold,
            fontFamily: AppFontFamily.dinPro,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        4.vGap,
        Text(
          label,
          style: TextStyle(
            fontSize: 12.w,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        children: [
          SizedBox(
              height: 30.w,
              width: double.infinity,
              child: DisButton(
                text: AppConst.user.like,
                onPressed: () {
                  controller.fetchCategorys();
                  _showAcceptDialog();
                },
                icon: CupertinoIcons.hand_thumbsup,
                size: ButtonSize.small,
              )),
          6.vGap,
          SizedBox(
              height: 30.w,
              width: double.infinity,
              child: DisButton(
                text: user?.isFollowed == true
                    ? AppConst.user.unfollowUser
                    : AppConst.user.followUser,
                onPressed: () {
                  controller.followUser();
                },
                icon: CupertinoIcons.person_crop_circle_badge_plus,
                size: ButtonSize.small,
              )),
          6.vGap,
          SizedBox(
            height: 30.w,
            child: Row(
              children: [
                Expanded(
                    child: DisButton(
                  text: AppConst.user.message,
                  onPressed: () {},
                  icon: CupertinoIcons.envelope_circle,
                  size: ButtonSize.small,
                )),
                12.hGap,
                Expanded(
                    child: DisButton(
                  text: AppConst.user.chat,
                  onPressed: () {},
                  type: ButtonType.secondary,
                  icon: CupertinoIcons.chat_bubble_2,
                  size: ButtonSize.small,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRelativeTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return '-';
    }
    try {
      final date = DateTime.parse(dateStr);
      return date.friendlyDateTime;
    } catch (e) {
      return '-';
    }
  }

  String formattedScore(int score) {
    return score.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
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

  _buildBadges(BuildContext context) {
    final badges = controller._userInfo.value?.badges;
    if (badges == null || badges.isEmpty) return const SizedBox();
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.w),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6.w,
            crossAxisSpacing: 6.w,
            childAspectRatio: 3,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final badgeColor = BadgeIconHelper.getColor(badge.name);
            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 80.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 3.w),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: Text(
                          badge.name,
                          style: TextStyle(
                            fontSize: 9.w,
                            fontWeight: FontWeight.bold,
                            color: badgeColor.withValues(alpha: 1),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _buildOtherInfo(BuildContext context) {
    final user = controller._userInfo.value?.user;
    return user?.bioExcerpt == null || user?.bioExcerpt?.isEmpty == true
        ? Container(
            width: double.infinity,
            padding: EdgeInsets.all(6.w),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: .6.w),
            ),
            child: Text(
              AppConst.user.noDescription,
              style: TextStyle(
                fontSize: 12.w,
                color: Theme.of(context).hintColor,
              ),
            ))
        : Container(
            width: double.infinity,
            padding: EdgeInsets.all(6.w),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: .6.w),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HtmlWidget(
                    html: user?.bioExcerpt ?? '',
                    fontSize: 11.w,
                    customWidgetBuilder: (element) {
                      if (element.localName == 'img') {
                        String? src = element.attributes['src'];
                        if (src != null && src.startsWith('/')) {
                          return Image.network(
                            '${HttpConfig.baseUrl}$src',
                            width: 20.w,
                            height: 20.w,
                          );
                        }
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          );
  }

  void _showAcceptDialog() {
    controller._endorseUserCategorys.value = [];
    final user = controller._userInfo.value?.user;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Container(
          width: 320.w,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor,
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '您觉得 ${user?.name ?? username} 的优点是什么？',
                style: TextStyle(
                  fontSize: 16.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
              16.vGap,
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Obx(() => Wrap(
                        spacing: 8.w,
                        runSpacing: 8.w,
                        children: controller._categorys.value
                                ?.map((e) =>
                                    _buildAdvantageItem(e.name ?? '', e.id))
                                .toList() ??
                            [],
                      )),
                ),
              ),
              16.vGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Obx(() {
                    final likesRemaining = Get.find<GlobalController>()
                            .userInfo
                            ?.user
                            ?.voteCount ??
                        2;
                    return Text(
                      '今日还剩$likesRemaining次',
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Theme.of(Get.context!).hintColor,
                      ),
                    );
                  }),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      AppConst.cancel,
                      style: TextStyle(
                        color: Theme.of(Get.context!).hintColor,
                      ),
                    ),
                  ),
                  8.hGap,
                  Obx(() => DisButton(
                        text: AppConst.user.like,
                        type: ButtonType.transform,
                        loading: controller._loading.value,
                        onPressed:
                            controller._endorseUserCategorys.value?.isEmpty ==
                                    true
                                ? null
                                : () {
                                    controller.fetchEndorseUserCategorys();
                                  },
                        size: ButtonSize.small,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  Widget _buildAdvantageItem(String name, int id) {
    return Obx(() {
      final isSelected =
          controller._endorseUserCategorys.value?.contains(id) ?? false;
      return GestureDetector(
        onTap: () {
          final currentList = controller._endorseUserCategorys.value ?? [];
          if (isSelected) {
            controller._endorseUserCategorys.value =
                currentList.where((element) => element != id).toList();
          } else {
            controller._endorseUserCategorys.value = [...currentList, id];
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(Get.context!).primaryColor
                : Theme.of(Get.context!).cardColor,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: isSelected
                  ? Theme.of(Get.context!).primaryColor
                  : Theme.of(Get.context!).dividerColor,
              width: 1.w,
            ),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14.w,
              color: isSelected
                  ? Colors.white
                  : Theme.of(Get.context!).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      );
    });
  }
}

class UserInfoCardController extends BaseController {
  final ApiService apiService = Get.find();
  final String username;
  final int? postCount;
  // 用户信息
  final _userInfo = Rxn<UserResponse>();
  final _categorys = Rxn<List<Category>>();
  final _endorseUserCategorys = Rxn<List<int>>();
  final _loading = RxBool(false);
  final _isFirst = RxBool(true);
  final _coverLoading = RxBool(false);

  UserInfoCardController({required this.username, this.postCount});

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      isLoading.value = _isFirst.value;
      _coverLoading.value = !_isFirst.value;
      final user = await apiService.getUserCard(username,
          includePostCountFor: postCount);
      _userInfo.value = user;
      isLoading.value = _isFirst.value = false;
      _coverLoading.value = false;
    } catch (e) {
      isLoading.value = _isFirst.value = false;
      _coverLoading.value = false;
      hasError.value = true;
    }
  }

  Future<void> fetchCategorys() async {
    try {
      final categorys = await apiService.getUserCategories(username);
      _categorys.value = categorys.categories;
    } catch (e, s) {
      l.e('fetchCategorys error: $e ---$s');
    }
  }

  Future<void> fetchEndorseUserCategorys() async {
    try {
      _loading.value = true;
      await apiService.endorseUserCategory(
          '', _endorseUserCategorys.value ?? []);
      Get.back();

      /// 成功后,刷新用户信息
      Get.find<GlobalController>().fetchUserInfo();
    } catch (e) {
      l.e('fetchLikesRemaining error: $e');
      showError(AppConst.user.failed);
    } finally {
      _loading.value = false;
    }
  }

  Future<void> followUser() async {
    try {
      SuccessResponse<dynamic> response;
      if (_userInfo.value?.user?.isFollowed == true) {
        response = await apiService.unfollowUser(username);
      } else {
        response = await apiService.followUser(username);
      }
      if (response.isSuccess) {
        fetchUserInfo();
      } else {
        showError(AppConst.user.failed);
      }
    } catch (e, s) {
      l.e('followUser error: $e --- $s');
      showError(AppConst.user.failed);
    }
  }
}
