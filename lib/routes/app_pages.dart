import 'package:get/get.dart';
import 'package:linux_do/pages/category/category_list_controller.dart';
import 'package:linux_do/pages/profile/edit_profile_controller.dart';
import 'package:linux_do/pages/profile/edit_profile_page.dart';
import 'package:linux_do/pages/profile/personal_controller.dart';
import 'package:linux_do/pages/profile/personal_page.dart';
import 'package:linux_do/pages/settings/about_controller.dart';
import 'package:linux_do/pages/settings/about_page.dart';
import 'package:linux_do/pages/settings/profile_settings_controller.dart';
import 'package:linux_do/pages/settings/profile_settings_page.dart';
import 'package:linux_do/pages/settings/security_settings_controller.dart';
import 'package:linux_do/pages/settings/security_settings_page.dart';
import 'package:linux_do/widgets/html_widget.dart';
import '../pages/chat/chat_detail_controller.dart';
import '../pages/chat/chat_detail_page.dart';
import '../pages/create/create_post_controller.dart';
import '../pages/chat/chat_controller.dart';
import '../pages/topics/details/topic_detail_controller.dart';
import '../pages/topics/details/topic_detail_page.dart';
import '../pages/settings/settings_controller.dart';
import '../pages/home/home_controller.dart';
import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../pages/login/login_controller.dart';
import '../pages/profile/profile_controller.dart';
import '../pages/settings/settings_page.dart';
import '../pages/startup/startup_controller.dart';
import '../pages/startup/startup_page.dart';
import '../pages/category/category_topics_controller.dart';
import '../pages/topics/topics_controller.dart';
import '../pages/common/webview_page.dart';
import '../pages/common/webview_controller.dart';
import '../pages/create/create_post_page.dart';
import '../pages/settings/email_settings_controller.dart';
import '../pages/settings/email_settings_page.dart';
import '../pages/settings/notification_settings_controller.dart';
import '../pages/settings/notification_settings_page.dart';
import '../pages/settings/tracking_settings_controller.dart';
import '../pages/settings/tracking_settings_page.dart';
import '../pages/settings/do_not_disturb_controller.dart';
import '../pages/settings/do_not_disturb_page.dart';
import '../pages/category/category_page.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.STARTUP;
  static final routes = <GetPage>[
    /// 启动页
    GetPage(
      name: Routes.STARTUP,
      page: () => const StartupPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StartupController());
      }),
    ),

    /// 主页
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => TopicsController());
        Get.lazyPut(() => CategoryTopicsController());
        Get.lazyPut(() => ChatController());
        Get.lazyPut(() => ProfileController());
      }),
    ),

    /// 登录页
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoginController());
      }),
    ),

    /// 设置页
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
    ),

    /// 帖子详情页
    GetPage(
      name: Routes.TOPIC_DETAIL,
      page: () => const TopicDetailPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TopicDetailController());
        Get.lazyPut(() => HtmlController());
      }),
    ),

    /// WebView页面
    GetPage(
      name: Routes.WEBVIEW,
      page: () => const WebViewPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WebViewController());
      }),
    ),

    /// 创建帖子页
    GetPage(
      name: Routes.CREATE_TOPIC,
      page: () => const CreatePostPage(),
      binding: BindingsBuilder(() {
         Get.lazyPut(() => CreatePostController());
      }),
    ),

    /// 聊天详情页
    GetPage(
      name: Routes.CHAT_DETAIL,
      page: () => const ChatDetailPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatDetailController());
      }),
    ),

    /// 编辑资料页
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EditProfileController());
      }),
    ),

    /// 安全设置页
    GetPage(
      name: Routes.SECURITY_SETTINGS,
      page: () => const SecuritySettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SecuritySettingsController());
      }),
    ),


    /// 个性资料页
    GetPage(
      name: Routes.PROFILE_SETTINGS,
      page: () => const ProfileSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileSettingsController());
      }),
    ),

    /// 电子邮件设置页
    GetPage(
      name: Routes.EMAIL_SETTINGS,
      page: () => const EmailSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EmailSettingsController());
      }),
    ),

    /// 通知设置页
    GetPage(
      name: Routes.NOTIFICATION_SETTINGS,
      page: () => const NotificationSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotificationSettingsController());
      }),
    ),

    /// 跟踪设置页
    GetPage(
      name: Routes.TRACKING_SETTINGS,
      page: () => const TrackingSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TrackingSettingsController());
      }),
    ),

    /// 免打扰设置页
    GetPage(
      name: Routes.DO_NOT_DISTURB_SETTINGS,
      page: () => const DoNotDisturbPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DoNotDisturbController());
      }),
    ),

    /// 关于页
    GetPage(
      name: Routes.ABOUT,
      page: () => const AboutPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AboutController());
      }),
    ),

    /// 分类页
    GetPage(
      name: Routes.CATEGORY,
      page: () => const CategoryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CategoryListController());
      }),
    ),

    /// 个人主页(TA的)
    GetPage(
      name: Routes.PERSONAL,
      page: () => const PersonalPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PersonalController());
      }),
    ),
  ];
}
