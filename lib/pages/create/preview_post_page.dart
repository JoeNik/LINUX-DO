import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../const/app_const.dart';
import '../../const/app_spacing.dart';
import '../../utils/tag.dart';
import '../../widgets/html/html_widget.dart';
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
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(12.w),
                  padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 14.w, bottom: 12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(6.w),
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
                          fontSize: 14.w,
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
                                    size: 11.w,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  4.hGap,
                                  Text(
                                    controller.category.name ?? '',
                                    style: TextStyle(
                                      fontSize: 11.w,
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
                                            fontSize: 11.w,
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

                Positioned(
                  left: 12.w,
                  top: 12.w,
                  right: 12.w,
                  child: Container(
                    width: double.infinity,
                    height: 8.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.w),
                        topRight: Radius.circular(6.w),
                      ),
                    ),
                )),
              ],
            ),

            // 内容
            Stack(
              children: [
                Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.w),
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
                        : Html(
                            data: controller.content,
                            style: {
                              "img": Style(
                                width: Width(Get.width - 56.w),
                                margin: Margins.only(top: 8.h, bottom: 8.h),
                                display: Display.block,
                                backgroundColor: Colors.transparent,
                              ),
                              "p": Style(
                                margin: Margins.only(top: 8.h, bottom: 8.h),
                                padding: HtmlPaddings.zero,
                              ),
                            },
                            extensions: [
                              TagExtension(
                                tagsToExtend: {"img"},
                                builder: (context) {
                                  final src = context.attributes['src'];
                                  final width = context.attributes['width'];
                                  final height = context.attributes['height'];
                                  if (src == null) return const SizedBox();
                                  
                                  double? aspectRatio;
                                  if (width != null && height != null) {
                                    aspectRatio = double.parse(width) / double.parse(height);
                                  }
                                  
                                  return SizedBox(
                                    width: Get.width - 56.w,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6.w),
                                      child: AspectRatio(
                                        aspectRatio: aspectRatio ?? 1,
                                        child: Image.network(
                                          src,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          )),

                          Positioned(
                  left: 12.w,
                  bottom: 0,
                  right: 12.w,
                  child: Container(
                    width: double.infinity,
                    height: 8.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(6.w),
                        bottomRight: Radius.circular(6.w),
                      ),
                    ),
                )),
              ],
            ),
            24.vGap,
          ],
        ),
      ),
    );
  }
}
