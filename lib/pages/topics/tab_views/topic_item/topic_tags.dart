import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/utils/tag.dart';

/// 话题标签组件
class TopicTags extends StatelessWidget {
  final List<String> tags;

  const TopicTags({
    Key? key,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tags.map((tag) {
            final color = Tag.getTagColors(tag);
            return Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
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
    );
  }
} 