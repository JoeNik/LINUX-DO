import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';

import '../../../../const/app_colors.dart';
import '../../../../models/topic_detail.dart';
import '../../../../widgets/avatar_widget.dart';

/// 帖子头部组件
class PostHeader extends StatelessWidget {
  const PostHeader({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UserAvatar(post: post),
        8.hGap,
        _UserInfo(post: post),
        const Spacer(),
        _PostTime(post: post),
      ],
    );
  }
}

/// 用户头像组件
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return AvatarWidget(
      avatarUrl: post.getAvatarUrl(),
      size: 32.w,
      circle: !post.isWebMaster(),
      borderRadius: 4.w,
      borderColor: AppColors.primary,
      username: post.username ?? '',
    );
  }
}

/// 用户信息组件
class _UserInfo extends StatelessWidget {
  const _UserInfo({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.name?.isNotEmpty == true ? post.name! : post.username ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.w,
              fontFamily: AppFontFamily.dinPro,
              fontWeight:
                  !post.isWebMaster() ? FontWeight.w500 : FontWeight.bold,
              color: !post.isWebMaster()
                  ? Theme.of(context).textTheme.titleLarge?.color
                  : Theme.of(context).primaryColor,
            ),
          ),
          Text(
            post.username ?? '',
            style: TextStyle(
              fontSize: 12.w,
              fontFamily: AppFontFamily.dinPro,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 发帖时间组件
class _PostTime extends StatelessWidget {
  const _PostTime({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Text(
      _getRelativeTime(),
      style: TextStyle(
        fontSize: 12.w,
        fontFamily: AppFontFamily.dinPro,
        color: Theme.of(context).hintColor,
      ),
    );
  }

  String _getRelativeTime() {
    final time = post.createdAt;
    if (time == null) return '';
    return DateTime.parse(time).friendlyDateTime;
  }
}
