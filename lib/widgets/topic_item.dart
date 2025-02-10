import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keframe/keframe.dart';
import '../const/app_colors.dart';
import '../const/app_theme.dart';
import '../models/topic_model.dart';
import '../utils/expand/datetime_expand.dart';
import '../utils/tag.dart';
import 'avatar_widget.dart';

class TopicItem extends StatelessWidget {
  final Topic topic;
  final String? avatarUrl;
  final String? nickName;
  final String? username;
  final VoidCallback? onTap;
  final Function(Topic)? onDoNotDisturb;

  const TopicItem({
    Key? key,
    required this.topic,
    this.avatarUrl,
    this.nickName,
    this.username,
    this.onTap,
    this.onDoNotDisturb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.25, // 控制滑出按钮的宽度比例
          motion: const ScrollMotion(),
          children: [
            CustomSlidableAction(
              onPressed: (_) => onDoNotDisturb?.call(topic),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(4.w), bottomRight: Radius.circular(4.w)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.do_disturb_rounded, size: 20.w,color: AppColors.white),
                  SizedBox(height: 4.w),
                  Text(
                    '免打扰',
                    style: TextStyle(fontSize: 12.w),
                  ),
                ],
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4.w),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 头像
                      Container(
                        margin: EdgeInsets.only(right: 12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 42.w,
                              height: 42.w,
                                child: AvatarWidget(
                                  avatarUrl: avatarUrl ?? '',
                                  size: 42.w,
                                  circle: topic.getOriginalPosterId() != 1,
                                  borderRadius: 4.w,
                                  backgroundColor: Theme.of(context).cardColor,
                                  borderColor: AppColors.primary,
                                  username: username ?? '',
                                ),
                            ),
                            SizedBox(height: 8.w),
                            SizedBox(
                              width: 42.w,
                              child: Text(
                                (nickName ?? '').length > 8 
                                    ? '${(nickName ?? '').substring(0, 8)}...' 
                                    : (nickName ?? ''),
                                style: TextStyle(
                                  fontSize: 9.w,
                                  fontWeight: topic.getOriginalPosterId() != 1 ? FontWeight.w400 : FontWeight.w500,
                                  color: topic.getOriginalPosterId() != 1 ? Theme.of(context).textTheme.bodySmall?.color : AppColors.secondary2,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题行
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (topic.pinned ?? false)
                                  Container(
                                    margin: EdgeInsets.only(right: 8.w),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4.w, vertical: 2.w),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary,
                                      borderRadius: BorderRadius.circular(4.w),
                                    ),
                                    child: Text(
                                      '置顶',
                                      style: TextStyle(
                                        fontSize: 10.w,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    topic.title ?? '',
                                    style: TextStyle(
                                      fontSize: 15.w,
                                      fontFamily: AppFontFamily.dinPro,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.color,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // 摘要
                            if (topic.excerpt != null && topic.excerpt!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8.w),
                                child: Text(
                                  topic.excerpt ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.w,
                                    fontFamily: AppFontFamily.dinPro,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    height: 1.6,
                                  ),
                                ),
                              ),
    
                            // 标签
                            if (topic.tags != null && topic.tags!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8.w),
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
    
                            // 底部信息
                            Padding(
                              padding: EdgeInsets.only(top: 8.w),
                              child: Row(
                                children: [
                                  Text(
                                    topic.lastPosterUsername ?? '',
                                    style: TextStyle(
                                      fontSize: 12.w,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                                    width: 3.w,
                                    height: 3.w,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).dividerColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Text(
                                    _getRelativeTime(),
                                    style: TextStyle(
                                      fontSize: 13.w,
                                      fontFamily: AppFontFamily.dinPro,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                          CupertinoIcons
                                              .arrowshape_turn_up_left_2_fill,
                                          size: 13.w,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withValues(alpha: 0.5)),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${topic.postsCount ?? 0}',
                                        style: TextStyle(
                                          fontSize: 13.w,
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRelativeTime() {
    final time = topic.bumpedAt ?? topic.lastPostedAt ?? topic.createdAt;
    if (time == null) return '';
    return DateTime.parse(time).friendlyDateTime;
  }
} 