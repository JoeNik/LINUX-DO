import 'package:flutter/material.dart';
import 'package:linux_do/models/topic_model.dart';
import 'package:linux_do/pages/topics/details/widgets/topic_item/topic_excerpt.dart';
import 'package:linux_do/pages/topics/details/widgets/topic_item/topic_footer.dart';
import 'package:linux_do/pages/topics/details/widgets/topic_item/topic_header.dart';
import 'package:linux_do/pages/topics/details/widgets/topic_item/topic_poster_avatar.dart';
import 'package:linux_do/pages/topics/details/widgets/topic_item/topic_tags.dart';

/// 话题内容组件 - 包含主要内容部分
class TopicContent extends StatelessWidget {
  final Topic topic;
  final String? avatarUrl;
  final String? nickName;
  final String? username;
  final List<String>? avatarUrls;

  const TopicContent({
    Key? key,
    required this.topic,
    this.avatarUrl,
    this.nickName,
    this.username,
    this.avatarUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 发帖人头像
            TopicPosterAvatar(
              avatarUrl: avatarUrl ?? '',
              nickName: nickName ?? '',
              username: username ?? '',
              isOriginalPoster: topic.getOriginalPosterId() != 1,
            ),
            
            // 主要内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题部分
                  TopicHeader(
                    title: topic.title ?? '',
                    isPinned: topic.pinned ?? false,
                  ),
                  
                  // 摘要
                  if (topic.excerpt != null && topic.excerpt!.isNotEmpty)
                    TopicExcerpt(excerpt: topic.excerpt!),
                  
                  // 标签
                  if (topic.tags != null && topic.tags!.isNotEmpty)
                    TopicTags(tags: topic.tags!),
                  
                  // 底部信息
                  TopicFooter(
                    topic: topic,
                    avatarUrls: avatarUrls ?? [],
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
} 