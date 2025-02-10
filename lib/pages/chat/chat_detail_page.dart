import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/image_preview_dialog.dart';
import '../../widgets/cached_image.dart';
import '../../const/app_spacing.dart';
import 'chat_detail_controller.dart';
import '../../models/chat_detail_message.dart';
import '../../widgets/dis_loading.dart';
import '../../const/app_colors.dart';
import '../../const/app_const.dart';
import '../../utils/mixins/concatenated.dart';
import '../../net/http_config.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatDetailPage extends GetView<ChatDetailController> with Concatenated{
  const ChatDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: CachedImage(
                imageUrl: controller.channel.getAvatarUrl(),
                width: 32.w,
                height: 32.w,
                circle: !controller.channel.isWebMaster(),
                borderRadius: BorderRadius.circular(4.w),
                backgroundColor: Theme.of(context).cardColor,
              ),
            ),
            8.hGap,
            Text(
              controller.channel.title,
              style: TextStyle(
                fontSize: 16.w,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              CupertinoIcons.ellipsis_vertical,
              size: 20.w,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          6.hGap,
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          // Positioned.fill(
          //   child: Image.asset(
          //     AppImages.getChatBg(context),
          //     fit: BoxFit.cover,
          //     opacity: const AlwaysStoppedAnimation(0.5),
          //   ),
          // ),
          // 内容
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
              // 消息列表
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: DisSquareLoading());
                  }

                  if (controller.messages.isEmpty) {
                    return Center(
                      child: Text(
                        AppConst.chat.noMessages,
                        style: TextStyle(
                          fontSize: 14.w,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    );
                  }

                  return ScrollablePositionedList.builder(
                    itemScrollController: controller.itemScrollController,
                    itemPositionsListener: controller.itemPositionsListener,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return _buildMessageItem(context, message);
                    },
                  );
                }),
              ),
              // 输入框
              _buildInputBar(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatDetailMessage message) {
    final isSelf = message.user?.username == userName;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.w),
      child: Row(
        mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSelf) ...[
            SizedBox(
              width: 42.w,
              height: 42.w,
              child: CachedImage(
                imageUrl: '${HttpConfig.baseUrl}${message.user?.avatarTemplate?.replaceAll('{size}', '100')}',
                width: 42.w,
                height: 42.w,
                circle: message.user?.id != 1,
                backgroundColor: Theme.of(context).cardColor,
                showBorder: true,
              ),
            ),
            8.hGap,
          ],
          Column(
            crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 0.7.sw),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                decoration: BoxDecoration(
                  color: isSelf
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.4)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSelf ? 12.w : 0),
                    topRight: Radius.circular(isSelf ? 0 : 12.w),
                    bottomLeft: Radius.circular(12.w),
                    bottomRight: Radius.circular(12.w),
                  ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: .1.w
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (message.message != null && message.message!.isNotEmpty)
                      Text(
                        message.message!,
                        style: TextStyle(
                          fontSize: 14.w,
                          color: isSelf ? Theme.of(context).textTheme.titleLarge?.color : Theme.of(context).primaryColor,
                        ),
                      ),
                    if (message.uploads != null && message.uploads!.isNotEmpty) ...[
                      if (message.message != null && message.message!.isNotEmpty) 8.vGap,
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.w,
                        children: message.uploads!.map((upload) {
                          return GestureDetector(
                            onTap: () {
                              showImagePreview(
                                context, 
                                upload['url'],
                                heroTag: upload['short_url'],
                              );
                            },
                            child: Hero(
                              tag: upload['short_url'],
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.w),
                                child: CachedImage(
                                  imageUrl: upload['url'],
                                  width: 200.w,
                                  height: 150.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              4.vGap,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.friendlyTime,
                    style: TextStyle(
                      fontSize: 9.w,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isSelf) ...[
            8.hGap,
            SizedBox(
              width: 42.w,
              height: 42.w,
              child: CachedImage(
                imageUrl: '${HttpConfig.baseUrl}${message.user?.avatarTemplate?.replaceAll('{size}', '100')}',
                width: 42.w,
                height: 42.w,
                circle: true,
                backgroundColor: Theme.of(context).cardColor,
                showBorder: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.w,
        12.w,
        8.w + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              CupertinoIcons.folder_circle_fill,
              size: 24.w,
              color: Theme.of(context).hintColor,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 32.w,
              minHeight: 32.w,
            ),
          ),
          4.hGap,
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: 100.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: TextField(
                controller: controller.inputController,
                focusNode: controller.focusNode,
                maxLines: null,
                style: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
                  hintText: AppConst.chat.inputHint,
                  hintStyle: TextStyle(
                    fontSize: 14.w,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ),
          4.hGap,
          IconButton(
            onPressed: controller.sendMessage,
            icon: Icon(
              CupertinoIcons.paperplane_fill,
              size: 20.w,
              color: Theme.of(context).primaryColor,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 32.w,
              minHeight: 32.w,
            ),
          ),
        ],
      ),
    );
  }
} 