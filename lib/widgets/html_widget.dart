import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:html/dom.dart' as dom;
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/video_player_widget.dart';
import 'dart:ui';
import 'cached_image.dart';
import 'image_preview_dialog.dart';
import 'code_preview_dialog.dart';
import 'package:flutter/rendering.dart';

// 自定义PageStorageBucket，用于防止滚动位置恢复错误
// type 'ItemPosition' is not a subtype of type 'double?' in type cast ???????????????
// https://github.com/railson-ferreira/scrollable_list_tab_scroller/issues/16
class CustomPageStorageBucket extends PageStorageBucket {
  @override
  dynamic readState(BuildContext context, {Object? identifier}) {
    // 避免读取ItemPosition类型的状态和double类型不兼容
    return null;
  }
}

class HtmlWidget extends GetView<HtmlController> with ToastMixin {
  final String html;
  final Function(String?)? onLinkTap;
  final double? fontSize;
  final Widget Function(dom.Element)? customWidgetBuilder;
  final GlobalKey anchorKey = GlobalKey();
  final horizontalController = ScrollController();
  final verticalController = ScrollController();
  final CustomPageStorageBucket _storageBucket = CustomPageStorageBucket();

  HtmlWidget({
    super.key,
    required this.html,
    this.onLinkTap,
    this.fontSize,
    this.customWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PageStorage(
      bucket: _storageBucket,
      child: SelectionArea(
      child: Html(
          anchorKey: anchorKey,
        data: html,
        style: {
          "body": Style(
            fontSize: FontSize(fontSize ?? 14.sp),
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            color: theme.textTheme.bodyLarge?.color,
              fontFamily: AppFontFamily.dinPro,
          ),
          "a": Style(
            color: theme.primaryColor,
            textDecoration: TextDecoration.none,
              fontFamily: AppFontFamily.dinPro,
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
              fontFamily: AppFontFamily.dinPro,
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
            backgroundColor:
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
            padding: HtmlPaddings.all(12.w),
            margin: Margins.symmetric(vertical: 8.h),
              fontFamily: AppFontFamily.dinPro,
          ),
          "code": Style(
            backgroundColor:
                Theme.of(context).primaryColor.withValues(alpha: 0),
            padding: HtmlPaddings.symmetric(horizontal: 4.w, vertical: 2.h),
              fontFamily: AppFontFamily.dinPro,
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
            backgroundColor:
                Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ),
          // 标题样式
          "h1": Style(
            fontSize: FontSize(24.sp),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 16.h, bottom: 8.h),
            lineHeight: LineHeight.number(1.2),
              fontFamily: AppFontFamily.dinPro,
          ),
          "h2": Style(
            fontSize: FontSize(20.sp),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 16.h, bottom: 8.h),
            lineHeight: LineHeight.number(1.2),
              fontFamily: AppFontFamily.dinPro,
          ),
          "h3": Style(
            fontSize: FontSize(18.sp),
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 16.h, bottom: 8.h),
            lineHeight: LineHeight.number(1.2),
              fontFamily: AppFontFamily.dinPro,
          ),
          // 加粗和强调
          "strong": Style(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
              fontFamily: AppFontFamily.dinPro,
          ),
          "em": Style(
            fontStyle: FontStyle.italic,
              fontFamily: AppFontFamily.dinPro,
          ),
          // 列表样式
          "ul": Style(
            margin: Margins.only(left: 8.w, top: 8.h, bottom: 8.h),
            padding: HtmlPaddings.only(left: 16.w),
            listStyleType: ListStyleType.disc,
              fontFamily: AppFontFamily.dinPro,
          ),
          "ol": Style(
            margin: Margins.only(left: 8.w, top: 8.h, bottom: 8.h),
            padding: HtmlPaddings.only(left: 16.w),
            listStyleType: ListStyleType.decimal,
              fontFamily: AppFontFamily.dinPro,
          ),
          "li": Style(
            margin: Margins.only(bottom: 4.h),
              fontFamily: AppFontFamily.dinPro,
          ),
          // 表格样式
          "table": Style(
            width: Width(100, Unit.percent),
              fontFamily: AppFontFamily.dinPro,
          ),
          "th": Style(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            fontWeight: FontWeight.bold,
              fontFamily: AppFontFamily.dinPro,
          ),
          "td": Style(
            padding: HtmlPaddings.all(8.w),
              fontFamily: AppFontFamily.dinPro,
          ),
        },
        extensions: [
            // 添加图片扩展
            _imageExtension(context, theme),

            // 添加div的扩展
            _divExtension(context, theme),

            // 添加处理 iframe 的扩展
            _iframeExtension(context),

            // 添加代码块扩展
            _codeExtension(context),

            // 添加处理用户提及的扩展
            _mentionExtension(context, theme),

            const TableHtmlExtension()
          ],
          onLinkTap: (url, _, __) {
            if (url == null) return;

            if (url.startsWith('/u/')) {
              final username = url.split('/').last;
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: UserInfoCard(
                    toPersonalPage: false,
                    username: username,
                  ),
                ),
                barrierColor: Colors.black.withValues(alpha: 0.5),
              );
            } else {
              if (onLinkTap != null) {
                onLinkTap!(url);
              } else {
                Get.toNamed(Routes.WEBVIEW, arguments: url);
              }
            }
          },
        ),
      ),
    );
  }

  TagExtension _divExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      tagsToExtend: {"div"},
      builder: (extensionContext) {
        if (extensionContext.classes.contains('spoiler')) {
          final innerHtml = extensionContext.element?.innerHtml ?? '';

          // 每一个div都对应一个状态 无法维护在controller
          bool revealed = false;
          return StatefulBuilder(
            builder: (context, setState) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 2000),
                child: revealed
                    ? HtmlWidget(
                        html: innerHtml,
                        onLinkTap: onLinkTap,
                        fontSize: fontSize,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8).w,
                        child: Stack(
                          children: [
                            ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                              child: HtmlWidget(
                                html: innerHtml,
                                onLinkTap: onLinkTap,
                                fontSize: fontSize,
                              ),
                            ),
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    revealed = !revealed;
                                  });
                                },
                              ),
                            ),
                          ],
                  ),
                ),
              );
            },
          );
        }

              // 如果是 lightbox-wrapper，只返回其中的图片内容
              if (extensionContext.classes.contains('lightbox-wrapper')) {
          final imgElement =
              extensionContext.element?.getElementsByTagName('img').firstOrNull;
                if (imgElement != null) {
                  final src = imgElement.attributes['src'];
                  if (src != null) {
                    // 获取原始图片URL用于预览
                    String previewUrl = src;
                    // 尝试从 lightbox 链接获取原始图片 URL
                    final lightboxElement = extensionContext.element
                        ?.getElementsByClassName('lightbox')
                        .firstOrNull;
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
                        color: theme.primaryColor.withValues(alpha: 0.1),
                              child: Center(
                          child: DisRefreshLoading(),
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

        if (extensionContext.element?.className == 'md-table') {
          final tableElement = extensionContext.element
              ?.getElementsByTagName('table')
              .firstOrNull;
          if (tableElement != null) {
            final tableHtml = tableElement.outerHtml;
            // 修复表格 HTML，移除嵌套的 p 标签和处理列表元素
            final fixedTableHtml = _fixTableHtml(tableHtml);

            // 使用特殊的表格渲染实现，完全避免与ItemPosition相关的错误
            return StatefulBuilder(
              builder: (context, setState) {
                // 使用StatefulBuilder但不保存状态，避免恢复滚动位置
                // 每次重建时创建新的ScrollController，避免恢复之前的滚动位置
                final horizontalScrollCtrl = ScrollController();
                final verticalScrollCtrl = ScrollController();
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .7,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primaryColor),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          // 拦截滚动通知，避免触发滚动位置恢复
                          onNotification: (notification) => true,
                          child: SingleChildScrollView(
                            controller: horizontalScrollCtrl,
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 2,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                physics: const ClampingScrollPhysics(),
                                controller: verticalScrollCtrl,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height * 2,
                                  ),
                                  child: Html(
                                    data: fixedTableHtml,
                                    style: {
                                      "table": Style(
                                        backgroundColor: theme.cardColor,
                                      ),
                                      "th": Style(
                                        padding: HtmlPaddings.all(8.w),
                                        backgroundColor: theme.colorScheme
                                            .surfaceContainerHighest,
                                        fontWeight: FontWeight.bold,
                                        textAlign: TextAlign.center,
                                      ),
                                      "td": Style(
                                        padding: HtmlPaddings.all(8.w),
                                        border: Border.all(
                                          color: theme.dividerColor,
                                          width: .5,
                                        ),
                                      ),
                                    },
                                    extensions: const [
                                      TableHtmlExtension(),
                                    ],
                                    onLinkTap: (url, _, __) {
                                      if (onLinkTap != null) {
                                        onLinkTap!(url);
                                      } else {
                                        Get.toNamed(Routes.WEBVIEW,
                                            arguments: url);
                                      }
                        },
                      ),
                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 添加横屏查看按钮
                      const Divider(height: 1),
                      SizedBox(
                        height: 40.h,
                        child: TextButton.icon(
                          onPressed: () =>
                              _showFullScreenDialog(context, fixedTableHtml),
                          icon: Icon(
                            Icons.fullscreen,
                            size: 18.w,
                            color: theme.primaryColor,
                          ),
                          label: Text(
                            '预览',
                            style: TextStyle(
                                fontSize: 14.w, color: theme.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }

        if (extensionContext.classes.contains('policy')) {
          final acceptText = extensionContext.attributes['data-accept'] ?? '接受';
          final revokeText = extensionContext.attributes['data-revoke'] ?? '拒绝';
          final innerHtml = extensionContext.element?.innerHtml ?? '';

              return Container(
            margin: const EdgeInsets.symmetric(vertical: 8).w,
            padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8).w,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HtmlWidget(
                  html: innerHtml,
                ),

                // 按钮区域
                6.vGap,
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => DisButton(
                      text: controller.isPolicyAccepted.value
                          ? revokeText
                          : acceptText,
                      onPressed: () {
                        controller.updatePolicyAccepted();
                      },
                      loading: controller.isLoading.value,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        // 检查是否包含视频相关的类名
        final classNames = extensionContext.classes;
        final isVideoBox = classNames.contains('onebox') &&
            classNames.contains('video-onebox');
        final isVideoOnebox = classNames.contains('onebox') &&
            extensionContext.element?.outerHtml.contains('<video') == true;

        if (isVideoBox || isVideoOnebox) {
          // 获取视频元素
          final videoElement = extensionContext.element
              ?.getElementsByTagName('video')
              .firstOrNull;

          if (videoElement != null) {
            // 获取视频源
            final sourceElement =
                videoElement.getElementsByTagName('source').firstOrNull;

            final videoUrl = sourceElement?.attributes['src'];

            if (videoUrl != null && videoUrl.isNotEmpty) {
              return VideoPlayerWidget(videoUrl: videoUrl);
            } else {
              // 尝试从a标签获取视频URL
              final aElement =
                  videoElement.getElementsByTagName('a').firstOrNull;

              final linkUrl = aElement?.attributes['href'];

              if (linkUrl != null && linkUrl.isNotEmpty) {
                return VideoPlayerWidget(videoUrl: linkUrl);
              } else {
                l.e('No video URL found in either source or a tag');
              }
            }
          } else {
            // 如果没有找到video元素，尝试直接从div中的a标签获取URL
            final aElement =
                extensionContext.element?.getElementsByTagName('a').firstOrNull;
            if (aElement != null) {
              final linkUrl = aElement.attributes['href'];
              if (linkUrl != null && linkUrl.isNotEmpty) {
                return VideoPlayerWidget(videoUrl: linkUrl);
              }
            }
          }

          return const SizedBox.shrink();
        }

        // 其他 div 正常显示
        return const SizedBox.shrink();
      },
    );
  }

  TagExtension _codeExtension(BuildContext context) {
    return TagExtension(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
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
                    onPressed: () =>
                        showCodePreview(context, code, language: language),
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
    );
  }

  TagExtension _iframeExtension(BuildContext context) {
    return TagExtension(
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
    );
  }

  TagExtension _imageExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
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
        if (src.contains('user_avatar/linux.do') ||
            src.contains('/letter_avatar_proxy')) {
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

        final width = extensionContext.attributes['width'];
        final height = extensionContext.attributes['height'];

        if (isEmoji || isEmojiPath) {
          return Image.network(
            src,
            width: width != null ? double.parse(width) : 20.sp,
            height: height != null ? double.parse(height) : 20.sp,
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
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  child: Center(
                    child: DisRefreshLoading(),
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
    );
  }

  // 修复表格 HTML，移除嵌套的 p 标签和处理列表元素
  String _fixTableHtml(String html) {
    try {
      // 使用 dom 库解析 HTML
      final document = dom.Document.html(html);
      
      // 处理表格中的 p 标签
      document.querySelectorAll('th p, td p').forEach((element) {
        final span = dom.Element.tag('span');
        span.innerHtml = element.innerHtml;
        element.replaceWith(span);
      });
      
      // 处理表格中的列表元素
      document
          .querySelectorAll(
              'th > ul > li, th > ol > li, td > ul > li, td > ol > li')
          .forEach((element) {
        final span = dom.Element.tag('span');
        span.innerHtml = element.innerHtml;
        element.replaceWith(span);
      });
      
      document
          .querySelectorAll('th > ul, th > ol, td > ul, td > ol')
          .forEach((element) {
        final span = dom.Element.tag('span');
        span.innerHtml = element.innerHtml;
        element.replaceWith(span);
      });
      
      return document.outerHtml;
    } catch (e) {
      l.e('修复表格 HTML 出错: $e');
      return html; // 如果处理失败，返回原始 HTML
    }
  }

  // 用户提及链接的扩展 - 只针对@提及链接
  TagExtension _mentionExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      // 只处理包含mention类的a标签，不影响其他a标签
      tagsToExtend: {"mention"},
      builder: (extensionContext) {
        final href = extensionContext.attributes['href'];
        final mentionText = extensionContext.element?.text ?? '';

        // 优先使用自定义构建器
        if (customWidgetBuilder != null && extensionContext.element != null) {
          final widget = customWidgetBuilder!(extensionContext.element!);
          return widget;
        }

        return GestureDetector(
          onTap: () {
            // 处理mention点击事件
            if (href != null) {
              final username = href.split('/').last;
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: UserInfoCard(
                    toPersonalPage: false,
                    username: username,
                  ),
                ),
                barrierColor: Colors.black.withValues(alpha: 0.5),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1).w,
            margin: const EdgeInsets.only(top: 6).w,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Text(
              mentionText,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
                fontFamily: AppFontFamily.dinPro,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenDialog(BuildContext context, String html) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.w),
        ),
        elevation: 16,
        insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.table_fill,
                          size: 14.w,
                          color: theme.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                  Text(
                    '表格预览',
                    style: TextStyle(
                            fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.w),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 14.w,
                            color: theme.iconTheme.color,
                          ),
                        ),
                      ),
                  ),
                ],
              ),
              ),
              SizedBox(height: 16.h),

              // 表格内容区
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    // 使用StatefulBuilder但不保存状态，避免恢复滚动位置问题
                    final horizontalScrollCtrl = ScrollController();
                    final verticalScrollCtrl = ScrollController();

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: NotificationListener<ScrollNotification>(
                        // 拦截滚动通知，避免触发滚动位置恢复
                        onNotification: (notification) => true,
                child: SingleChildScrollView(
                          controller: horizontalScrollCtrl,
                          scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width - 64.w,
                              maxWidth: MediaQuery.of(context).size.width * 1.7,
                            ),
                  child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                    physics: const ClampingScrollPhysics(),
                              controller: verticalScrollCtrl,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 3,
                                ),
                      child: Html(
                        data: html,
                        style: {
                          "table": Style(
                                      backgroundColor: theme.cardColor,
                                      border: Border.all(
                                        color: theme.dividerColor,
                                        width: 1,
                                      ),
                          ),
                          "th": Style(
                            padding: HtmlPaddings.all(12.w),
                                      backgroundColor: theme
                                          .colorScheme.surfaceContainerHighest,
                            fontWeight: FontWeight.bold,
                                      border: Border.all(
                                        color: theme.dividerColor,
                                        width: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                          ),
                          "td": Style(
                            padding: HtmlPaddings.all(12.w),
                                      border: Border.all(
                                        color: theme.dividerColor,
                                        width: 0.5,
                          ),
                          ),
                        },
                        extensions: const [TableHtmlExtension()],
                                  onLinkTap: (url, _, __) {
                                    if (onLinkTap != null) {
                                      onLinkTap!(url);
                                    } else {
                                      Get.toNamed(Routes.WEBVIEW,
                                          arguments: url);
                                    }
                                  },
                      ),
                    ),
                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 底部按钮区
              SizedBox(height: 16.h),
              SizedBox(
                height: 32.w,
                width: double.infinity,
                child: DisButton(
                  text: '完成',
                  type: ButtonType.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HtmlController extends BaseController {
  final isPolicyAccepted = false.obs;
  final postId = 0.obs;
  final _apiService = Get.find<ApiService>();

  void acceptPolicy() {
    isPolicyAccepted.value = true;
  }

  void revokePolicy() {
    isPolicyAccepted.value = false;
  }

  void updatePolicyAccepted() async {
    _updatePolicyAccepted(
      isPolicyAccepted.value ? 'unaccept' : 'accept',
    );
  }

  void _updatePolicyAccepted(String action) async {
    try {
      isLoading.value = true;
      final response = await _apiService.updatePolicyAccepted(
          action, postId.value.toString());

      if (response.isSuccess) {
        isPolicyAccepted.value = !isPolicyAccepted.value;
      }
    } catch (e) {
      l.e('更新政策接受状态出错: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
