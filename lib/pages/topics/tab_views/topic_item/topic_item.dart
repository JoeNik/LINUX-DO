import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/pages/topics/tab_views/topic_item/topic_content.dart';
import 'package:linux_do/utils/mixins/concatenated.dart';
import 'package:linux_do/widgets/avatar_widget.dart';

/// 话题项组件 - 包含滑动操作
class TopicItem extends StatelessWidget with Concatenated {
  final Topic topic;
  final String? avatarUrl;
  final String? nickName;
  final String? username;
  final VoidCallback? onTap;
  final Function(Topic)? onDoNotDisturb;
  final Function(Topic)? onDelete;
  final List<String>? avatarUrls;
  final AvatarActions avatarActions;
  final bool? toPersonalPage;
  const TopicItem({
    Key? key,
    required this.topic,
    this.avatarUrl,
    this.nickName,
    this.username,
    this.onTap,
    this.onDoNotDisturb,
    this.onDelete,
    this.avatarUrls,
    this.avatarActions = AvatarActions.noAction,
    this.toPersonalPage,
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
        endActionPane: _buildSingleActionPane(),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(4.w),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: TopicContent(
                    topic: topic,
                    avatarUrl: avatarUrl,
                    nickName: nickName,
                    username: username,
                    avatarUrls: avatarUrls,
                    avatarActions: avatarActions,
                    toPersonalPage: toPersonalPage,
                  ),
                ),
              ),
            ),

            if (topic.bookmarked ?? false)

              Positioned(
                top: 4.w,
                right: 4.w,
                child: Icon(
                    CupertinoIcons.bookmark,
                    size: 14.w,
                    color: Theme.of(context).primaryColor,
                  ),
              ),
          ],
        ),
      ),
    );
  }

  ActionPane _buildSingleActionPane() {
    return ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDoNotDisturb?.call(topic),
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: const Radius.circular( 4).w,
                bottomRight: const Radius.circular( 4).w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon( CupertinoIcons.bell_slash,
                    size: 20.w, color: AppColors.white),
                SizedBox(height: 4.w),
                Text(
                  '免打扰',
                  style: TextStyle(fontSize: 12.w,color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      );
  }

  ActionPane _buildActionPane() {
    return ActionPane(
        extentRatio: username == userName ? 0.5 : 0.25,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDoNotDisturb?.call(topic),
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(username == userName ? 0 : 4).w,
                bottomRight: Radius.circular(username == userName ? 0 : 4).w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon( CupertinoIcons.bell_slash,
                    size: 20.w, color: AppColors.white),
                SizedBox(height: 4.w),
                Text(
                  '免打扰',
                  style: TextStyle(fontSize: 12.w,color: AppColors.white),
                ),
              ],
            ),
          ),
          username == userName ?
          CustomSlidableAction(
            onPressed: (_) => onDelete?.call(topic),
            backgroundColor: AppColors.l2,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(4.w),
                bottomRight: Radius.circular(4.w)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.trash,
                    size: 20.w, color: AppColors.white),
                SizedBox(height: 4.w),
                Text(
                  '删除',
                  style: TextStyle(fontSize: 12.w,color: AppColors.white),
                ),
              ],
            ),
          ): const SizedBox(),
        ],
      );
  }
}
