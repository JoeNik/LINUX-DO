import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linux_do/const/app_colors.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/const/app_spacing.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.settings.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        children: [
          _buildSection(
            context,
            AppConst.settings.accountAndProfile,
            [
              _buildNavigationItem(
                context,
                AppConst.settings.accountSettings,
                CupertinoIcons.person_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.security,
                CupertinoIcons.shield_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.editProfile,
                CupertinoIcons.pencil_circle_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.emailSettings,
                CupertinoIcons.envelope_circle_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.dataExport,
                CupertinoIcons.doc_text_fill,
                onTap: () {},
              ),
            ],
          ),
          16.vGap,
          _buildSection(
            context,
            AppConst.settings.notificationsAndPrivacy,
            [
              _buildNavigationItem(
                context,
                AppConst.settings.notifications,
                CupertinoIcons.bell_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.tracking,
                CupertinoIcons.location_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.doNotDisturb,
                CupertinoIcons.moon_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.anonymousMode,
                CupertinoIcons.eye_slash_fill,
                onTap: () {},
              ),
            ],
          ),
          16.vGap,
          _buildSection(
            context,
            AppConst.settings.appearance,
            [
              _buildThemeDropdown(context),
               _buildNavigationItem(
                context,
                AppConst.settings.themeCustom,
                CupertinoIcons.paintbrush_fill,
                onTap: () {
                  // controller.showColorPicker();
                },
              ),
            ],
          ),
          16.vGap,
          _buildSection(
            context,
            AppConst.settings.helpAndSupport,
            [
              _buildNavigationItem(
                context,
                AppConst.settings.about,
                CupertinoIcons.info_circle_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.faq,
                CupertinoIcons.question_circle_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.terms,
                CupertinoIcons.doc_text_fill,
                onTap: () {},
              ),
              _buildNavigationItem(
                context,
                AppConst.settings.privacy,
                CupertinoIcons.lock_fill,
                onTap: () {},
              ),
            ],
          ),
          32.vGap,
          _buildLogoutButton(context),
          16.vGap,
        ],
      ),
    );
  }

  Widget _buildThemeDropdown(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.moon_stars_fill,
            size: 20.w,
            color: Theme.of(context).primaryColor,
          ),
          12.hGap,
          Expanded(
            child: Obx(() => DropdownButton(
              value: controller.selectedThemeMode,
              dropdownColor: Theme.of(context).cardColor,
              items: controller.themeModeOptions.map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: controller.setThemeMode,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12.w),
              underline: const SizedBox(),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 16.w),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.w),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                blurRadius: 10.w,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                      height: .5.w,
                      thickness: 1.w,
                      indent: 16.w,
                      color: Theme.of(context).dividerColor.withValues(alpha: .4),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.w,
                color: Theme.of(context).primaryColor,
              ),
              12.hGap,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16.w,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.w),
        ),
        child: Text(
          AppConst.settings.logout,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          AppConst.settings.logoutConfirmTitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppConst.settings.logoutConfirmMessage,
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              AppConst.settings.cancel,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              AppConst.settings.confirm,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      controller.logout();
    }
  }
} 
