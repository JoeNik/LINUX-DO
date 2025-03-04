import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_theme.dart';

/// 话题标题组件
class TopicHeader extends StatelessWidget {
  final String title;
  final bool isPinned;

  const TopicHeader({
    Key? key,
    required this.title,
    this.isPinned = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 置顶标签
        if (isPinned)
          Container(
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
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
        
        // 标题
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.w,
              fontFamily: AppFontFamily.dinPro,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
} 