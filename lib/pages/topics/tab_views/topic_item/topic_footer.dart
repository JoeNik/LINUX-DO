import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/pages/settings/font_size_controller.dart';
import 'package:linux_do/utils/expand/datetime_expand.dart';
import 'package:linux_do/widgets/user_avatar_group.dart';

/// 话题底部组件
class TopicFooter extends StatelessWidget {
  final Topic topic;
  final List<String> avatarUrls;
  final ListDensity? density;

  const TopicFooter({
    Key? key,
    required this.topic,
    required this.avatarUrls,
    this.density,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = density == ListDensity.compact
        ? 8.0
        : density == ListDensity.normal
            ? 10.0
            : 11.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8).w,
      child: Row(
        children: [
          // 最后发帖人
          Text(
            topic.lastPosterUsername ?? '',
            style: TextStyle(
              fontSize: fontSize.w,
              fontFamily: AppFontFamily.dinPro,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),

          // 分隔点
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6).w,
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              shape: BoxShape.circle,
            ),
          ),

          // 相对时间
          Text(
            _getRelativeTime(),
            style: TextStyle(
              fontSize: fontSize.w,
              fontFamily: AppFontFamily.dinPro,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),

          // 间隔
          6.hGap,

          // 用户头像组
          if (avatarUrls.isNotEmpty)
            UserAvatarGroup(
              avatarUrls: avatarUrls,
            ),

          const Spacer(),

          // 回复数
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.arrowshape_turn_up_left_2_fill,
                size: fontSize.w + 3,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.5),
              ),
              SizedBox(width: 4.w),
              Text(
                '${topic.postsCount ?? 0}',
                style: TextStyle(
                  fontSize: fontSize.w + 3,
                  fontFamily: AppFontFamily.dinPro,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取相对时间
  String _getRelativeTime() {
    final time = topic.bumpedAt ?? topic.lastPostedAt ?? topic.createdAt;
    if (time == null) return '';
    return DateTime.parse(time).friendlyDateTime;
  }
}


