import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_spacing.dart';

import '../../../const/app_colors.dart';
import '../../../const/app_const.dart';
import '../../../models/birthday.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/dis_refresh.dart';
import '../../../widgets/state_view.dart';
import 'birthday_controller.dart';
import 'brithday_tab_controller.dart';

class BrithdayTabView extends StatefulWidget {
  final Filter filter;
  const BrithdayTabView({super.key, required this.filter});

  @override
  State<BrithdayTabView> createState() => _BrithdayTabViewState();
}

class _BrithdayTabViewState extends State<BrithdayTabView> with AutomaticKeepAliveClientMixin {
  late BrithdayTabController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BrithdayTabController>(tag: widget.filter.value);
    controller.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() => StateView(
          state: _getViewState(),
          onRetry: () => controller.fetchBirthdays(isRefresh: true),
          child: _buildBirthdayList(context),
        ));
  }

  Widget _buildBirthdayList(BuildContext context) {
    if (controller.birthdays.isEmpty) {
      return Center(
        child: Text(
          AppConst.birthday.noBirthdays,
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 14.w,
          ),
        ),
      );
    }

    return DisSmartRefresher(
      controller: controller.refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: controller.onRefresh,
      onLoading: controller.onLoading,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.birthdays.length,
        separatorBuilder: (context, index) => 12.vGap,
        itemBuilder: (context, index) {
          final birthday = controller.birthdays[index];
          return _buildBirthdayCard(context, birthday);
        },
      ),
    );
  }

  Widget _buildBirthdayCard(BuildContext context, Birthday birthday) {
    return Container(
      height: 80.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.w),
        child: InkWell(
          onTap: () => controller.onBirthdayTap(birthday),
          borderRadius: BorderRadius.circular(12.w),
          child: Row(
            children: [
              CachedImage(
                imageUrl: birthday.getAvatar(120),
                width: 80.w,
                height: 80.w,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.w),
                  bottomLeft: Radius.circular(12.w),
                ),
                backgroundColor: Theme.of(context).cardColor,
              ),
              16.hGap,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          birthday.name.isEmpty ? birthday.username : birthday.name,
                          style: TextStyle(
                            fontSize: 16.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (birthday.title != null) ...[
                          8.hGap,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.w,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: Text(
                              birthday.title!,
                              style: TextStyle(
                                fontSize: 10.w,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    4.vGap,
                    Text(
                      '@${birthday.username}',
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    4.vGap,
                    Text(
                      '${AppConst.birthday.birthdayOn}: ${birthday.cakedate}',
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Theme.of(context).hintColor,
                      ),
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

  ViewState _getViewState() {
    if (controller.isLoading.value) {
      return ViewState.loading;
    }
    if (controller.hasError.value) {
      return ViewState.error;
    }
    if (controller.birthdays.isEmpty) {
      return ViewState.empty;
    }
    return ViewState.content;
  }

  @override
  bool get wantKeepAlive => true;
}
