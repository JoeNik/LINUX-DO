import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/widgets/cached_image.dart';
import 'package:linux_do/widgets/dis_loading.dart';
import 'chat_detail_controller.dart';

 final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(40).w,
      borderSide: BorderSide(
        color: Theme.of(Get.context!).dividerColor,
      ),
    );

class ChatDetailPage extends GetView<ChatDetailController> {
  const ChatDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.channel.title ?? ''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis_circle),
            onPressed: () {
              // 后续实现 字体大小 样式等各种设置
            
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: DisSquareLoading());
        }

        return Chat(
          messageWidthRatio: 0.68,
          messages: controller.chatMessages,
          onSendPressed: controller.sendMessage,
          onAttachmentPressed: controller.handleFileSelection,
          user: controller.currentUser,
          theme: isDark ? _getDarkChatTheme(context) : _getLightChatTheme(context),
          showUserAvatars: true,
          showUserNames: true,
          dateLocale: 'zh_CN',
          onEndReached: controller.loadMorePastMessages,
          onEndReachedThreshold: 0.8,
          inputOptions: const InputOptions(
            sendButtonVisibilityMode: SendButtonVisibilityMode.always,
          ),
          emptyState: Center(
            child: Text(
              '暂无消息，发送一条消息开始聊天吧',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          avatarBuilder: (author) {
            return Padding(
              padding: const EdgeInsets.only(right: 4).w,
              child: CachedImage(imageUrl: author.imageUrl,width: 32,height: 32,
              circle: int.parse(author.id) == 1,
              borderRadius: BorderRadius.circular(16.w),
              showBorder: true,
              ),
            );
          },
        );
      }),
    );
  }
  
  // 获取亮色聊天主题
  DefaultChatTheme _getLightChatTheme(BuildContext context) {
    return DefaultChatTheme(
      // 基础颜色
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      primaryColor: AppColors.primary,
      secondaryColor: Theme.of(context).cardColor,
      
      // 输入框样式
      inputBackgroundColor: Theme.of(context).cardColor.withValues(alpha: .7),
      inputBorderRadius: BorderRadius.circular(24),
      inputPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10).w,
      inputTextColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,

      inputMargin: EdgeInsets.zero,
      
      // 消息文本样式
       inputTextStyle: TextStyle(
        fontSize: 12.w,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.w400,
      ),
      
      // 消息文本样式
      sentMessageBodyTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 13.w,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      receivedMessageBodyTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        fontSize: 13.w,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      
      // 消息状态样式
      sentMessageCaptionTextStyle: TextStyle(
        color: Colors.white.withValues(alpha: .7),
        fontFamily: AppFontFamily.dinPro,
        fontSize: 10.w,
      ),
      receivedMessageCaptionTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54,
        fontFamily: AppFontFamily.dinPro,
        fontSize: 10.w,
      ),
      
      // 头像样式
      userAvatarNameColors: const [
        AppColors.primary,
        AppColors.success,
        AppColors.warning,
        AppColors.error,
      ],
      userAvatarTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 13.w,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.bold,
      ),
      
      // 日期指示器样式
      dateDividerTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color,
        fontSize: 12.sp,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.w500,
      ),
      dateDividerMargin: EdgeInsets.symmetric(vertical: 16.h),
      
      inputTextDecoration: InputDecoration(
        hintText: '发送消息',
        hintStyle: TextStyle(
              fontSize: 14.w,
              color: Theme.of(context).hintColor,
              fontFamily: AppFontFamily.dinPro,
            ),
        contentPadding: 
            EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.w,
            ),
        filled: true,
        fillColor:  Theme.of(context).cardColor,
        border:   defaultBorder,
        enabledBorder:  defaultBorder,
        focusedBorder: defaultBorder.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
        disabledBorder: 
            defaultBorder.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              ),
            ),
      ),
    );
  }
  
  // 获取暗色聊天主题
  DarkChatTheme _getDarkChatTheme(BuildContext context) {
    return DarkChatTheme(
      // 基础颜色
      // 基础颜色
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      primaryColor: AppColors.primary,
      secondaryColor: Theme.of(context).cardColor,
      
      // 输入框样式
      inputBackgroundColor: Theme.of(context).cardColor.withValues(alpha: .7),
      inputBorderRadius: BorderRadius.circular(24),
      inputPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10).w,
      inputTextColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
      inputTextStyle: TextStyle(
        fontSize: 12.w,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.w400,
      ),
      inputMargin: EdgeInsets.zero,
      
      // 消息文本样式
      sentMessageBodyTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 13.w,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      receivedMessageBodyTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        fontSize: 13.w,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      
      // 消息状态样式
      sentMessageCaptionTextStyle: TextStyle(
        color: Colors.white.withValues(alpha: .7),
        fontFamily: AppFontFamily.dinPro,
        fontSize: 10.w,
      ),
      receivedMessageCaptionTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54,
        fontFamily: AppFontFamily.dinPro,
        fontSize: 10.w,
      ),
      
      // 头像样式
      userAvatarNameColors: const [
        AppColors.primary,
        AppColors.success,
        AppColors.warning,
        AppColors.error,
      ],
      userAvatarTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 13.w,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.bold,
      ),
      
      // 日期指示器样式
      dateDividerTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color,
        fontSize: 12.sp,
        fontFamily: AppFontFamily.dinPro,
        fontWeight: FontWeight.w500,
      ),
      dateDividerMargin: EdgeInsets.symmetric(vertical: 16.h),
      
      inputTextDecoration: InputDecoration(
        hintText: '发送消息',
        hintStyle: TextStyle(
              fontSize: 14.w,
              color: Theme.of(context).hintColor,
              fontFamily: AppFontFamily.dinPro,
            ),
        contentPadding: 
            EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.w,
            ),
        filled: true,
        fillColor:  Theme.of(context).cardColor,
        border:   defaultBorder,
        enabledBorder:  defaultBorder,
        focusedBorder: defaultBorder.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
        disabledBorder: 
            defaultBorder.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              ),
            ),
      ),
    );
  }
} 