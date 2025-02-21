import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:html/dom.dart' as dom;
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'cached_image.dart';
import 'image_preview_dialog.dart';
import 'code_preview_dialog.dart';

class HtmlWidget extends StatelessWidget with ToastMixin {
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
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            padding: HtmlPaddings.all(12.w),
            margin: Margins.symmetric(vertical: 8.h),
          ),
          "code": Style(
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0),
            padding: HtmlPaddings.symmetric(horizontal: 4.w, vertical: 2.h),
            fontFamily: 'monospace',
            fontSize: FontSize(13.sp),
            color: Theme.of(context).primaryColor,
          ),
          // 引用样式
          "blockquote": Style(
            margin: Margins.symmetric(vertical: 8.h),
            padding: HtmlPaddings.only(left: 12.w),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                width: 4.w,
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
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
              if (src.contains('user_avatar/linux.do')
              || src.contains('/letter_avatar_proxy')
              ) {
                return CachedImage(
                  imageUrl: src,
                  width: 32.w,
                  height: 32.w,
                  circle: true,
                  showBorder: true,
                  borderColor: Theme.of(context).primaryColor,
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
              // if (previewUrl.contains('/optimized/')) {
              //   previewUrl = previewUrl.replaceFirst('/optimized/', '/original/');
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
                      imageUrl: src,
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
          // 添加处理 lightbox-wrapper 的扩展
          TagExtension(
            tagsToExtend: {"div"},
            builder: (extensionContext) {
              // 如果是 lightbox-wrapper，只返回其中的图片内容
              if (extensionContext.classes.contains('lightbox-wrapper')) {
                final imgElement = extensionContext.element?.getElementsByTagName('img').firstOrNull;
                if (imgElement != null) {
                  final src = imgElement.attributes['src'];
                  if (src != null) {
                    // 获取原始图片URL用于预览
                    String previewUrl = src;
                    // 尝试从 lightbox 链接获取原始图片 URL
                    final lightboxElement = extensionContext.element?.getElementsByClassName('lightbox').firstOrNull;
                    final originalUrl = lightboxElement?.attributes['href'];
                    if (originalUrl != null) {
                      previewUrl = originalUrl;
                    }

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
                            imageUrl: src,
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
                  }
                }
              }
              // 如果是 meta div，不显示
              if (extensionContext.classes.contains('meta')) {
                return const SizedBox();
              }
              // 其他 div 正常显示
              return const SizedBox.shrink();
            },
          ),
          // 添加处理 iframe 的扩展
          TagExtension(
            tagsToExtend: {"iframe"},
            builder: (extensionContext) {
              final src = extensionContext.attributes['src'];
              if (src == null) return const SizedBox();

              // 处理 bilibili 视频
              if (src.contains('player.bilibili.com')) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: InAppWebView(
                        initialUrlRequest: URLRequest(url: WebUri(src)),
                        initialSettings: InAppWebViewSettings(
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
                          iframeAllowFullscreen: true,
                          javaScriptEnabled: true,
                        ),
                        onLoadStart: (controller, url) {
                          controller.evaluateJavascript(source: '''
                            document.body.style.margin = '0';
                            document.body.style.padding = '0';
                            document.body.style.backgroundColor = 'transparent';
                          ''');
                        },
                      ),
                    ),
                  ),
                );
              }

              // 处理其他视频源
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.w),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(src)),
                      initialSettings: InAppWebViewSettings(
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                        iframeAllowFullscreen: true,
                        javaScriptEnabled: true,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // 添加代码块扩展
          TagExtension(
            tagsToExtend: {"pre"},
            builder: (extensionContext) {
              // 获取代码内容
              final codeElement = extensionContext.element?.children.firstWhere(
                (element) => element.localName == 'code',
                orElse: () => dom.Element.tag('code'),
              );
              final code = codeElement?.text ?? '';
              
              // 获取代码语言
              final language = codeElement?.className.split('-').last;

              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (language != null && language != 'null') ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: Text(
                              language,
                              style: TextStyle(
                                fontSize: 12.w,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          8.vGap,
                        ],
                        Text.rich(
                          TextSpan(
                            text: code,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: 'monospace',
                              height: 1.5,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  // 全屏按钮
                  Positioned(
                    top: 8.w,
                    right: 8.w,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: code));
                            showSuccess('代码已复制到剪贴板');
                          },
                          icon: Icon(
                            CupertinoIcons.doc_on_doc,
                            size: 18.w,
                            color: Theme.of(context).primaryColor,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 32.w,
                            minHeight: 32.w,
                          ),
                          splashRadius: 20.w,
                        ),
                        IconButton(
                          onPressed: () => showCodePreview(context, code, language: language),
                          icon: Icon(
                            CupertinoIcons.fullscreen,
                            size: 18.w,
                            color: Theme.of(context).primaryColor,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 32.w,
                            minHeight: 32.w,
                          ),
                          splashRadius: 20.w,
                        ),
                      ],
                    ),
                  ),
                ],
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
