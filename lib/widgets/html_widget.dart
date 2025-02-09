import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:html/dom.dart' as dom;
import 'cached_image.dart';
import 'image_preview_dialog.dart';

class HtmlWidget extends StatelessWidget {
  final String html;
  final Function(String?)? onLinkTap;
  final double? fontSize;
  final Widget Function(dom.Element)? customWidgetBuilder;
  
  const HtmlWidget({
    super.key,
    required this.html,
    this.onLinkTap,
    this.fontSize,
    this.customWidgetBuilder,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SelectionArea(
      child: Html(
        data: html,
        style: {
          "body": Style(
            fontSize: FontSize(fontSize ?? 14.sp),
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            color: theme.textTheme.bodyLarge?.color,
          ),
          "a": Style(
            color: theme.primaryColor,
            textDecoration: TextDecoration.none,
          ),
          "img": Style(
            width: Width(100, Unit.percent),
            height: Height.auto(),
            margin: Margins.only(top: 8.h, bottom: 8.h),
            padding: HtmlPaddings.zero,
            display: Display.block,
          ),
          "p": Style(
            margin: Margins.only(top: 8.h, bottom: 8.h),
            padding: HtmlPaddings.zero,
            fontSize: FontSize(fontSize ?? 14.sp),
            lineHeight: LineHeight.number(1.5),
          ),
          "img.emoji": Style(
            width: Width(16.sp),
            height: Height(16.sp),
            margin: Margins.only(left: 2.sp, right: 2.sp),
            verticalAlign: VerticalAlign.middle,
            display: Display.inlineBlock,
          ),
          // 代码块样式
          "pre": Style(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            padding: HtmlPaddings.all(12.w),
            margin: Margins.symmetric(vertical: 8.h),
          ),
          "code": Style(
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            padding: HtmlPaddings.symmetric(horizontal: 4.w, vertical: 2.h),
            fontFamily: 'monospace',
            fontSize: FontSize(13.sp),
            color: theme.colorScheme.primary,
          ),
          // 引用样式
          "blockquote": Style(
            margin: Margins.symmetric(vertical: 8.h),
            padding: HtmlPaddings.only(left: 12.w),
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 4.w,
              ),
            ),
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          ),
          // 标题样式
          "h1": Style(
            fontSize: FontSize(24.sp),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 16.h, bottom: 8.h),
            lineHeight: LineHeight.number(1.2),
          ),
          "h2": Style(
            fontSize: FontSize(20.sp),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 16.h, bottom: 8.h),
            lineHeight: LineHeight.number(1.2),
          ),
          "h3": Style(
            fontSize: FontSize(18.sp),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 16.h, bottom: 8.h),
            lineHeight: LineHeight.number(1.2),
          ),
          // 加粗和强调
          "strong": Style(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
          "em": Style(
            fontStyle: FontStyle.italic,
          ),
          // 列表样式
          "ul": Style(
            margin: Margins.only(left: 8.w, top: 8.h, bottom: 8.h),
            padding: HtmlPaddings.only(left: 16.w),
            listStyleType: ListStyleType.disc,
          ),
          "ol": Style(
            margin: Margins.only(left: 8.w, top: 8.h, bottom: 8.h),
            padding: HtmlPaddings.only(left: 16.w),
            listStyleType: ListStyleType.decimal,
          ),
          "li": Style(
            margin: Margins.only(bottom: 4.h),
          ),
          // 表格样式
          "table": Style(
            border: Border.all(
              color: theme.dividerColor,
              width: 1,
            ),
            margin: Margins.symmetric(vertical: 8.h),
          ),
          "th": Style(
            padding: HtmlPaddings.all(8.w),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            fontWeight: FontWeight.bold,
            border: Border.all(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
          "td": Style(
            padding: HtmlPaddings.all(8.w),
            border: Border.all(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
        },
        extensions: [
          TagExtension(
            tagsToExtend: {"img"},
            builder: (extensionContext) {
              final src = extensionContext.attributes['src'];
              if (src == null) return const SizedBox();

              // 优先使用自定义构建器
              if (customWidgetBuilder != null && extensionContext.element != null) {
                final widget = customWidgetBuilder!(extensionContext.element!);
                return widget;
              }

              // 检查是否是回复中用户头像
              if (src.contains('user_avatar/linux.do')) {
                return CachedImage(
                  imageUrl: src,
                  width: 32.w,
                  height: 32.w,
                  circle: true,
                );
              }

              // 检查是否是表情
              final isEmoji = extensionContext.classes.contains('emoji');
              final isEmojiPath = src.contains('/uploads/default/original') ||
                  src.contains('/images/emoji/twitter/') ||
                  src.contains('plugins/discourse-narrative-bot/images') ||
                  src.contains('/images/emoji/apple/');

              if (isEmoji || isEmojiPath) {
                return Image.network(
                  src,
                  width: 20.sp,
                  height: 20.sp,
                  fit: BoxFit.contain,
                );
              }

              // 获取原始图片URL用于预览
              String previewUrl = src;
              // if (src.contains('/optimized/')) {
              //   // 将优化后的图片URL转换为原图URL
              //   previewUrl = src.replaceFirst('/optimized/', '/original/').replaceAll(RegExp(r'_\d+_\d+x\d+'), '');
              // }

              return GestureDetector(
                onTap: () => showImagePreview(context, previewUrl),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: CachedImage(
                      imageUrl: previewUrl,
                      width: double.infinity,
                      placeholder: Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: Icon(
                        Icons.broken_image_outlined,
                        size: 40.w,
                        color: theme.iconTheme.color?.withValues(alpha: .5),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        onLinkTap: (url, _, __) {
          if (onLinkTap != null) {
            onLinkTap!(url);
          } else {
            Get.toNamed(Routes.WEBVIEW, arguments: url);
          }
        },
      ),
    );
  }
}
