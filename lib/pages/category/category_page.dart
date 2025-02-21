import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_sizes.dart';
import 'package:linux_do/const/app_theme.dart';
import 'package:linux_do/models/category.dart';
import 'package:linux_do/utils/log.dart';
import 'category_list_view.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = '';
    String? englishTitle;
    l.d('Get.arguments: ${Get.arguments}');
    if (Get.arguments is Category) {
      title = Get.arguments.name;
      englishTitle = Get.arguments.englishName;
    } else if (Get.arguments is Map<String, dynamic>) {
      title = Get.arguments['tag'] ?? 'Tag';
      englishTitle = null;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.chevron_left_circle),
        ) ,
        title: Column(
          children: [
            Text(title, style: TextStyle(
              fontSize: AppSizes.fontNormal,
              fontWeight: FontWeight.bold,
            )),
            englishTitle != null
                ? Text(englishTitle,
                    style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      fontFamily: AppFontFamily.dinPro,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                )
                : const SizedBox.shrink(),
          ],
        ),
        centerTitle: false,
      ),
      body: const CategoryListView(),
    );
  }
}
