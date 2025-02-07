import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/models/topic_detail.dart';
import '../topic_detail_controller.dart';

/// 帖子底部组件
class PostFooter extends StatelessWidget {
  const PostFooter({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: [
        _LikeButton(post: post),
        16.hGap,
        _ReplyButton(post: post),
        16.hGap,
        _CopyButton(post: post),
        16.hGap,
        _BookmarkButton(post: post),
      ],
    );
  }
}

/// 点赞按钮组件
class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TopicDetailController>();
    
    return InkWell(
      onTap: () => controller.toggleLike(post),
      child: Row(
        children: [
          Obx(() => Icon(
            controller.likedPosts[post.postNumber] == true
                ? CupertinoIcons.heart_fill
                : CupertinoIcons.heart,
            size: 16.w,
            color: controller.likedPosts[post.postNumber] == true
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor,
          )),
          4.hGap,
          Obx(() => Text(
            '${controller.postScores[post.postNumber] ?? 0}',
            style: TextStyle(
              fontSize: 12.w,
              color: Theme.of(context).hintColor,
            ),
          )),
        ],
      ),
    );
  }
}

/// 回复按钮组件
class _ReplyButton extends StatelessWidget {
  final controller = Get.find<TopicDetailController>();
   _ReplyButton({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    
    return InkWell(
      onTap: () => controller.startReply(post.postNumber, post.name),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.reply,
            size: 16.w,
            color: Theme.of(context).hintColor,
          ),
          4.hGap,
          Text(
            '回复',
            style: TextStyle(
              fontSize: 12.w,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
} 

/// 复制按钮组件
class _CopyButton extends StatelessWidget {
   final controller = Get.find<TopicDetailController>();
   final Post post;

   _CopyButton({required this.post});
   
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.copyPost(post),
      child: Row(
        children: [
          Icon(CupertinoIcons.square_on_square, size: 16.w, color: Theme.of(context).hintColor),
        ],
      ),
    );
  }
}


/// 书签按钮组件
class _BookmarkButton extends StatelessWidget {
  final controller = Get.find<TopicDetailController>();
  final Post post;

  _BookmarkButton({required this.post});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.toggleBookmark(post),
      child: Row(
        children: [
          Icon(CupertinoIcons.bookmark, size: 16.w, color: Theme.of(context).hintColor),
        ],
      ),
    );
  }
}