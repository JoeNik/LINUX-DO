import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../const/app_const.dart';
import '../../const/app_spacing.dart';
import '../../utils/tag.dart';
import '../../widgets/html_widget.dart';
import 'preview_post_controller.dart';

class PreviewPostPage extends GetView<PreviewPostController> {
  const PreviewPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppConst.createPost.previewTitle,
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(12.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.w),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.title,
                    style: TextStyle(
                      fontSize: 18.w,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  if (controller.tags.isNotEmpty) ...[
                    12.vGap,
                    Row(
                      children: [
                        // 分类
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.w,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.folder,
                                size: 12.w,
                                color: Theme.of(context).primaryColor,
                              ),
                              4.hGap,
                              Text(
                                controller.category.name ?? '',
                                style: TextStyle(
                                  fontSize: 12.w,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        8.hGap,
                        // 标签
                        if (controller.tags.isNotEmpty)
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: controller.tags.map((tag) {
                                  final color = Tag.getTagColors(tag);
                                  return Container(
                                    margin: EdgeInsets.only(right: 8.w),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.backgroundColor,
                                      borderRadius: BorderRadius.circular(4.w),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 12.w,
                                        color: color.textColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // 内容
            Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.w),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: controller.content.isEmpty
                    ? Center(
                        child: Text(
                          AppConst.createPost.previewEmpty,
                          style: TextStyle(
                            fontSize: 14.w,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    : HtmlWidget(
                        html: controller.content,
                        onLinkTap: (url) => controller.launchUrl(url),
                      )),
            24.vGap,
          ],
        ),
      ),
    );
  }
}
