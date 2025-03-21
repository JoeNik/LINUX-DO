import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/widgets/avatar_widget.dart';
import 'package:linux_do/widgets/dis_refresh.dart';
import '../../const/app_const.dart';
import '../../const/app_images.dart';
import '../../models/chat_message.dart';
import 'chat_list_controller.dart';

class ChatPage extends GetView<ChatListController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(CupertinoIcons.ellipsis_circle_fill,
        //         size: 24.w,
        //         color: Theme.of(context).textTheme.bodyLarge?.color),
        //   ),
        //   6.hGap
        // ],
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Center(
            child: Text(AppConst.chat.title,
                style: TextStyle(
                    fontSize: 16.w,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
        ),
      ),
      body: Column(
        children: [
          //_buildSearchBar(context),
          Expanded(
            child: Obx(() {
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

              return DisSmartRefresher(
                controller: controller.refreshController,
                enablePullDown: true,
                enablePullUp: false,
                onRefresh: controller.loadChannels,
                child: ListView.builder(
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageItem(context, message);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 36.w,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.w),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: .1),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              CupertinoIcons.search,
              size: 16.w,
              color: Theme.of(context).hintColor,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              style: TextStyle(
                fontSize: 14.w,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              decoration: InputDecoration(
                suffixIcon: SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: Center(
                      child: Image.asset(
                    AppImages.searchIcon,
                    width: 24.w,
                  )),
                ),
                border: InputBorder.none,
                fillColor: Colors.transparent,
                hintText: AppConst.chat.searchHint,
                hintStyle: TextStyle(
                  fontSize: 14.w,
                  color: Theme.of(context).hintColor,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6.w),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatMessage message) {
    return InkWell(
      onTap: () => controller.onMessageTap(message),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2.w, horizontal: 6.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        // decoration: BoxDecoration(
        //   color: Theme.of(context).cardColor,
        //   borderRadius: BorderRadius.only(
        //     topRight: Radius.circular(20.w),
        //     bottomLeft: Radius.circular(20.w),
        //     bottomRight: Radius.circular(20.w),
        //   ),
        //   border: Border.all(
        //     color: Theme.of(context).primaryColor.withValues(alpha: .25),
        //   ),
        // ),
        child: Column(
          children: [
            Row(
              children: [
                // 头像
                Stack(
                  children: [
                    SizedBox(
                      width: 38.w,
                      height: 38.w,
                      child: AvatarWidget(
                        avatarUrl: message.getAvatarUrl(),
                        circle: !message.isWebMaster(),
                        username: message.chatable.users?.first.username ?? '',
                        borderRadius: 4.w,
                        backgroundColor: Theme.of(context).cardColor,
                        borderColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (message.chatableType == 'DirectMessage' &&
                        message.chatable.users?.first.status != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2.w,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                12.hGap,
                // 消息内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message.title ?? '',
                              style: TextStyle(
                                fontSize: 14.w,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFontFamily.dinPro,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (message.lastMessage != null)
                            Text(
                              message.lastMessage!.friendlyTime,
                              style: TextStyle(
                                fontSize: 10.w,
                                fontFamily: AppFontFamily.dinPro,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                        ],
                      ),
                      4.hGap,
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message.lastMessage?.message ??
                                  message.description ??
                                  '',
                              style: TextStyle(
                                fontSize: 11.w,
                                fontFamily: AppFontFamily.dinPro,
                                color:
                                    Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
            
                          // 这个未读消息数量没有找到对应的字段,暂时找个占位吧
                          if (message.meta.messageBusLastIds.newMessages > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7.w, vertical: 2.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: .8),
                                borderRadius: BorderRadius.circular(100.w),
                                
                              ),
                              child: Text(
                                '${message.meta.messageBusLastIds.newMessages}',
                                style: TextStyle(
                                  fontSize: 9.w,
                                  fontFamily: AppFontFamily.dinPro,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
