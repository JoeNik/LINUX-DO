import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/pages/settings/font_size_controller.dart';
import 'package:linux_do/utils/tag.dart';

/// 话题标签组件
class TopicTags extends StatelessWidget {
  final List<String> tags;
  final ListDensity? density;

  const TopicTags({
    Key? key,
    required this.tags,
    this.density,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据密度设置不同的字体大小和间距
    final fontSize = density == ListDensity.compact
        ? 8.0
        : density == ListDensity.normal
            ? 9.0
            : 10.0;
            
    final margin = density == ListDensity.compact
        ? 4.0
        : density == ListDensity.normal
            ? 6.0
            : 8.0;
    
    final padding = density == ListDensity.compact
        ? const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0)
        : density == ListDensity.normal
            ? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0)
            : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0);

    return Padding(
      padding: const EdgeInsets.only(top: 4).w,
      child: Wrap(
        spacing: margin.w,
        runSpacing: (margin/2).w,
        children: tags.map((tag) {
          final color = Tag.getTagColors(tag);
          return Container(
            padding: padding.w,
            decoration: BoxDecoration(
              color: color.backgroundColor,
              borderRadius: BorderRadius.circular(4).w,
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: fontSize.w,
                color: color.textColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 