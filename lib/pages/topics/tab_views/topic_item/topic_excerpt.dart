import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_theme.dart';

/// 话题摘要组件
class TopicExcerpt extends StatelessWidget {
  final String excerpt;

  const TopicExcerpt({
    Key? key,
    required this.excerpt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8).w,
      child: Text(
        excerpt,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13.w,
          fontFamily: AppFontFamily.dinPro,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          height: 1.6,
        ),
      ),
    );
  }
} 