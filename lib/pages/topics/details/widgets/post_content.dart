import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/models/topic_detail.dart';
import 'package:linux_do/widgets/html_widget.dart';

import '../topic_detail_controller.dart';

/// 帖子内容组件
class PostContent extends StatelessWidget {
  const PostContent({
    required this.node,
    this.isReply = false,
    Key? key,
  }) : super(key: key);

  final PostNode node;
  final bool isReply;
  @override
  Widget build(BuildContext context) {
    if (node.post.cooked == null) {
      return const SizedBox();
    }
    
    return RepaintBoundary(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // if (isReply)
                //   _ReplyQuote(post: node.post),
                _PostBody(post: node.post,isReply: isReply),
              ],
            ),
          ),
        ],
      )
    );
  }
}

/// 回复引用组件
class _ReplyQuote extends StatelessWidget {
  _ReplyQuote({
    required this.post,
    Key? key,
  }) : super(key: key);

  final controller = Get.find<TopicDetailController>();
  final Post post;

  @override
  Widget build(BuildContext context) {
    
    
    return Container(
      margin: EdgeInsets.only(bottom: 8.w,top: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.arrowshape_turn_up_left_fill,
            size: 14.sp,
            color: Theme.of(context).hintColor,
          ),
          4.hGap,
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '回复 #${post.replyToPostNumber} ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  TextSpan(
                    text: () {
                      // 安全地获取引用的帖子
                      final posts = controller.topic.value?.postStream?.posts;
                      if (posts == null || posts.isEmpty) {
                        return '(加载中...)';
                      }
                      
                      final replyToPost = posts.firstWhereOrNull(
                        (p) => p.postNumber == post.replyToPostNumber,
                      );
                      
                      if (replyToPost == null) {
                        return '(加载中...)';
                      }
                      
                      return '(${replyToPost.name?.isNotEmpty == true ? replyToPost.name : replyToPost.username ?? "未知用户"})';
                    }(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (post.replyToPostNumber != null) {
                          controller.scrollToPost(post.replyToPostNumber! - 1);
                        }
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 帖子主体内容组件
class _PostBody extends StatelessWidget {
  final controller = Get.find<TopicDetailController>();
  _PostBody({
    required this.post,
    this.isReply = false,
    Key? key,
  }) : super(key: key);

  final Post post;
  final bool isReply;
  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html: post.cooked ?? '',
      fontSize: isReply ? 11.sp : 14.sp,
      onLinkTap: (url) {
        controller.launchUrl(url);
      },
    );
  }
} 