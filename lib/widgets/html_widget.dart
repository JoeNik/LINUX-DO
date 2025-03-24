import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/api_service.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/pages/topics/details/topic_detail_controller.dart';
import 'package:linux_do/routes/app_pages.dart';
import 'package:html/dom.dart' as dom;
import 'package:linux_do/utils/mixins/toast_mixin.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_button.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'package:linux_do/widgets/expandable.dart';
import 'package:linux_do/widgets/video_player_widget.dart';
import 'dart:ui';
import 'cached_image.dart';
import 'image_preview_dialog.dart';
import 'code_preview_dialog.dart';

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
  final TopicDetailController? topicDetailController;

  HtmlWidget({
    super.key,
    required this.html,
    this.onLinkTap,
    this.fontSize,
    this.customWidgetBuilder,
    this.topicDetailController,
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

            const TableHtmlExtension(),

            // 添加链接预览扩展
            // _linkPreviewExtension(context, theme),

            // 添加aside扩展
            _asideExtension(context, theme),

            // 添加hr扩展
            _hrExtension(context, theme),
          ],
          onLinkTap: (url, _, __) {
            if (url == null) return;

            if (url.startsWith('/u/')) {
              final username = url.split('/').last;
              _showUserCard(username);
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

  void _showUserCard(String username) {
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

  TagExtension _hrExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      tagsToExtend: {"hr"},
      builder: (extensionContext) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10).w,
          child: Divider(
            height: 1,
            color: theme.dividerColor,
          ),
        );
      },
    );
  }


  TagExtension _asideExtension(BuildContext context, ThemeData theme) {
    return TagExtension(
      tagsToExtend: {"aside"},
      builder: (extensionContext) {
        // 处理 GitHub 仓库的 onebox
        if (extensionContext.classes.contains('githubrepo') && extensionContext.classes.contains('onebox')) {
          final header = extensionContext.element?.getElementsByClassName('source').firstOrNull;
          final link = header?.getElementsByTagName('a').firstOrNull;
          final href = link?.attributes['href'];
          final sourceText = link?.text ?? '';
          
          final article = extensionContext.element?.getElementsByClassName('onebox-body').firstOrNull;
          final githubRow = article?.getElementsByClassName('github-row').firstOrNull;
          
          // 获取缩略图 
          final thumbnailImg = githubRow?.getElementsByTagName('img').firstOrNull;
          final thumbnailSrc = thumbnailImg?.attributes['src'];
          
          // 获取标题
          final titleElement = githubRow?.getElementsByTagName('h3').firstOrNull;
          final titleLink = titleElement?.getElementsByTagName('a').firstOrNull;
          final titleText = titleLink?.text ?? '';
          
          // 获取描述
          final descSpan = githubRow?.getElementsByClassName('github-repo-description').firstOrNull;
          final descriptionText = descSpan?.text ?? '';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8).w,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12).w,
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onLinkTap?.call(href),
                borderRadius: BorderRadius.circular(12).w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 仓库图片（如果可用）
                    if (thumbnailSrc != null && thumbnailSrc.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12).w,
                          topRight: const Radius.circular(12).w,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 180.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: CachedImage(
                            imageUrl: thumbnailSrc,
                            fit: BoxFit.cover,
                            placeholder: Container(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              child: Center(
                                child: DisRefreshLoading(),
                              ),
                            ),
                            errorWidget: Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 40.w,
                                  color: theme.iconTheme.color?.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    Padding(
                      padding: const EdgeInsets.all(12).w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // github 来源
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.link,
                                size: 14.w,
                                color: theme.primaryColor,
                              ),
                              4.hGap,
                              Text(
                                sourceText,
                                style: TextStyle(
                                  fontSize: 12.w,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFontFamily.dinPro,
                                ),
                              ),
                            ],
                          ),
                          8.vGap,
                          
                          // 仓库标题
                          Text(
                            titleText,
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFontFamily.dinPro,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          8.vGap,
                          
                          // 仓库描述
                          if (descriptionText.isNotEmpty)
                            Text(
                              descriptionText,
                              style: TextStyle(
                                fontSize: 13.w,
                                fontFamily: AppFontFamily.dinPro,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        // 处理通用的 onebox
        if (extensionContext.classes.contains('allowlistedgeneric') && extensionContext.classes.contains('onebox')) {
          final header = extensionContext.element?.getElementsByClassName('source').firstOrNull;
          final article = extensionContext.element?.getElementsByClassName('onebox-body').firstOrNull;
          final title = article?.getElementsByTagName('h3').firstOrNull;
          final description = article?.getElementsByTagName('p').firstOrNull;
          final link = header?.getElementsByTagName('a').firstOrNull;
          final href = link?.attributes['href'];
          final sourceText = link?.text ?? '';
          final titleText = title?.text ?? '';
          final descriptionText = description?.text ?? '';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8).w,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12).w,
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onLinkTap?.call(href),
                borderRadius: BorderRadius.circular(12).w,
                child: Padding(
                  padding: const EdgeInsets.all(12).w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 来源链接
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.link,
                            size: fontSize ?? 11.w,
                            color: theme.primaryColor,
                          ),
                          4.hGap,
                          Text(
                            sourceText,
                            style: TextStyle(
                              fontSize: 12.w,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFontFamily.dinPro,
                            ),
                          ),
                        ],
                      ),
                      8.vGap,
                      // 标题
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 13.w,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFontFamily.dinPro,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.vGap,
                      // 描述
                      if (descriptionText.isNotEmpty)
                        Text(
                          descriptionText,
                          style: TextStyle(
                            fontSize: 12.w,
                            fontFamily: AppFontFamily.dinPro,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        
        // Handle quoted content
        final titleDiv = extensionContext.element
            ?.getElementsByClassName('title')
            .firstOrNull;
        final username = extensionContext.element?.attributes['data-username'];
        final postId = extensionContext.element?.attributes['data-post'];
        final topicId = extensionContext.element?.attributes['data-topic'];
        final avatarImg = titleDiv?.getElementsByTagName('img').firstOrNull;
        final avatarSrc = avatarImg?.attributes['src'];
        final content = extensionContext.element
                                            ?.getElementsByTagName('blockquote')
                                            .firstOrNull
                                            ?.innerHtml ??
                                        '';

        return ExpandableNotifier(
          child: ScrollOnExpand(
            child: Column(
              children: [
                ExpandablePanel(
                    theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      tapBodyToExpand: true,
                      tapBodyToCollapse: true,
                      hasIcon: false,
                    ),
                    onExpanded: (expanded) {
                      if (expanded) {
                        controller.loadLinkRow(int.parse(topicId ?? '0'),
                            int.parse(postId ?? '0'));
                      }
                    },
                    header: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 0, vertical: 0)
                              .w,
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color:
                                      theme.primaryColor.withValues(alpha: 0.5),
                                  width: 4.w,
                                ),
                              ),
                              color: theme.primaryColor.withValues(alpha: 0.05),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 引用头部
                                if (username != null)
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    child: Row(
                                      children: [
                                        if (avatarSrc != null)
                                          AvatarWidget(
                                            avatarUrl: avatarSrc,
                                            size: 24.w,
                                            circle: true,
                                          ),
                                        8.hGap,
                                        GestureDetector(
                                          onTap: () => _showUserCard(username),
                                          child: Text(
                                            username,
                                            style: TextStyle(
                                              fontSize: 10.w,
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (postId != null) ...[
                                          4.hGap,
                                          Text(
                                            '#$postId',
                                            style: TextStyle(
                                              fontSize: 10.w,
                                              color: theme
                                                  .textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                        const Spacer(),

                                        ExpandableIcon(
                                          theme: ExpandableThemeData(
                                            expandIcon: CupertinoIcons
                                                .arrow_down_circle_fill,
                                            collapseIcon: CupertinoIcons
                                                .arrow_up_circle_fill,
                                            iconColor: theme.primaryColor,
                                            iconSize: 14.w,
                                            iconRotationAngle: pi / 2,
                                            iconPadding:
                                                const EdgeInsets.only(right: 5),
                                            hasIcon: false,
                                          ),
                                        ),
                                        // 跳转按钮
                                        if (topicId != null && postId != null)
                                          GestureDetector(
                                            onTap: () {
                                              if (topicDetailController != null) {
                                                topicDetailController!.scrollToPost(int.parse(postId));
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6.w,
                                                  vertical: 3.w),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4.w),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .arrow_up_arrow_down_circle_fill,
                                                    size: 14.w,
                                                    color: theme.primaryColor,
                                                  ),
                                                  4.hGap,
                                                  Text(
                                                    '跳转原贴',
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color: theme.primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10)
                                          .w,
                                  child: HtmlWidget(
                                    html: content,
                                    onLinkTap: onLinkTap,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    collapsed: Container(),
                    expanded: Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10).w,
                            child: Obx(() {
                              final quotedContent = controller.getQuotedContent(
                                int.parse(topicId ?? '0'),
                                int.parse(postId ?? '0'),
                              );
                              
                              // 如果有引用内容，检查并高亮匹配部分
                              String highlightedContent = quotedContent ?? '';
                              if (quotedContent != null && content.isNotEmpty) {
                                // 移除HTML标签以进行纯文本比较
                                final plainContent = content.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                                final plainQuoted = quotedContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                                
                                if (plainQuoted.contains(plainContent)) {
                                  // 在原始HTML中查找并高亮匹配部分
                                  final contentWithoutTags = content.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                                  final color = '#${theme.primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                                  highlightedContent = quotedContent.replaceAll(
                                    contentWithoutTags,
                                    '<span style="color: $color">$contentWithoutTags</span>'
                                  );
                                }
                              }

                              return HtmlWidget(
                                html: highlightedContent,
                                onLinkTap: onLinkTap,
                                fontSize: fontSize,
                              );
                            }),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        );
      },
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
            final imgSrc = imgElement.attributes['src'];
            if (imgSrc != null) {
              // 处理相对路径，添加域名前缀
              final src = imgSrc.startsWith('/') ? '${HttpConfig.baseUrl.replaceAll(RegExp(r'/$'), '')}$imgSrc' : imgSrc;
              
              // 获取原始图片URL用于预览
              String previewUrl = src;
              // 尝试从 lightbox 链接获取原始图片 URL
              final lightboxElement = extensionContext.element
                  ?.getElementsByClassName('lightbox')
                  .firstOrNull;
              final originalUrlAttr = lightboxElement?.attributes['href'];
              if (originalUrlAttr != null) {
                final originalUrl = originalUrlAttr.startsWith('/') 
                    ? '${HttpConfig.baseUrl.replaceAll(RegExp(r'/$'), '')}$originalUrlAttr' 
                    : originalUrlAttr;
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

        // 处理相对路径，添加域名前缀
        final String imageUrl = src.startsWith('/') ? '${HttpConfig.baseUrl.replaceAll(RegExp(r'/$'), '')}$src' : src;

        // 检查是否是回复中用户头像
        if (imageUrl.contains('user_avatar/linux.do') ||
            imageUrl.contains('/letter_avatar_proxy')) {
          return CachedImage(
            imageUrl: imageUrl,
            width: 32.w,
            height: 32.w,
            circle: true,
            showBorder: true,
            borderColor: Theme.of(context).primaryColor,
          );
        }

        // 检查是否是表情
        final isEmoji = extensionContext.classes.contains('emoji');
        final isEmojiPath = imageUrl.contains('/uploads/default/original') ||
            imageUrl.contains('/images/emoji/twitter/') ||
            imageUrl.contains('plugins/discourse-narrative-bot/images') ||
            imageUrl.contains('/images/emoji/apple/');

        final width = extensionContext.attributes['width'];
        final height = extensionContext.attributes['height'];

        if (isEmoji || isEmojiPath) {
          return Image.network(
            imageUrl,
            width: width != null ? double.parse(width) : 20.sp,
            height: height != null ? double.parse(height) : 20.sp,
            fit: BoxFit.contain,
          );
        }

        // 获取原始图片URL用于预览
        String previewUrl = imageUrl;
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
                imageUrl: imageUrl,
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

  // 添加链接预览扩展
  // TagExtension _linkPreviewExtension(BuildContext context, ThemeData theme) {
  //   return TagExtension(
  //     tagsToExtend: {"a"},
  //     builder: (extensionContext) {
  //       final href = extensionContext.attributes['href'];
  //       if (href == null) return const SizedBox();

  //       // 如果是内部链接或特殊链接，不显示预览
  //       if (href.startsWith('/') ||
  //           href.startsWith('#') ||
  //           href.contains(HttpConfig.domain) ||
  //           href.contains('@')) {
  //         return GestureDetector(
  //           onTap: () => onLinkTap?.call(href),
  //           child: Text(
  //             extensionContext.element?.text ?? href,
  //             style: TextStyle(
  //               color: theme.primaryColor,
  //               fontSize: fontSize ?? 14.sp,
  //               decoration: TextDecoration.none,
  //             ),
  //           ),
  //         );
  //       }

  //       // 外部链接显示预览
  //       return Obx(() => Container(
  //             padding: const EdgeInsets.all(12).w,
  //             margin: const EdgeInsets.symmetric(vertical: 8).w,
  //             decoration: BoxDecoration(
  //               color: theme.cardColor,
  //               borderRadius: BorderRadius.circular(6).w,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: theme.shadowColor.withValues(alpha: 0.1),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: LinkPreview(
  //               onPreviewDataFetched: (data) {
  //                 controller.datas[href] = data;
  //               },
  //               previewData: controller.datas[href],
  //               text: href,
  //               width: MediaQuery.of(context).size.width,
  //               padding: EdgeInsets.zero,
  //               enableAnimation: true,
  //               onLinkPressed: (url) => onLinkTap?.call(url),
  //               linkStyle: TextStyle(
  //                 color: theme.primaryColor,
  //                 fontSize: fontSize ?? 14.sp,
  //                 decoration: TextDecoration.none,
  //               ),
  //             ),
  //           ));
  //     },
  //   );
  // }

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
  RxMap<String, PreviewData> datas = RxMap<String, PreviewData>();

  // 存储引用内容的Map，key为"topicId:postId"格式
  final RxMap<String, String> quotedContents = RxMap<String, String>();

  void loadLinkRow(int topicId, int postId) async {
    final key = '$topicId:$postId';

    // 如果已经加载过，就不再重复加载
    if (quotedContents.containsKey(key)) {
      return;
    }

    try {
      final response = await _apiService.getPostLinkRow(
          topicId.toString(), postId.toString());
      if (response.cooked != null) {
        quotedContents[key] = response.cooked!;
        quotedContents.refresh();
      }
    } catch (e) {
      l.e('加载引用内容出错: $e');
    }
  }

  // 获取引用内容
  String? getQuotedContent(int topicId, int postId) {
    return quotedContents['$topicId:$postId'];
  }

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

