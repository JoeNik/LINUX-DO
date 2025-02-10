import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:linux_do/const/app_spacing.dart';
import '../../const/app_const.dart';
import '../../const/app_colors.dart';
import '../../const/app_theme.dart';
import '../../models/tag_data.dart';
import '../../utils/tag.dart';
import '../../widgets/category_item.dart';
import '../../widgets/dis_button.dart';
import '../../widgets/dis_loading.dart';
import 'create_post_controller.dart';

class CreatePostPage extends GetView<CreatePostController> {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppConst.createPost.title,
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          SizedBox(
            height: 28.w,
            child: DisButton(
              onPressed: controller.togglePreview,
              text: AppConst.createPost.preview,
            ),
          ),
          16.hGap
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _buildContent(context),
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 24.w, left: 16.w, right: 16.w, top: 8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.saveDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                side: BorderSide(color: Theme.of(context).dividerColor),
                padding: EdgeInsets.symmetric(vertical: 12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.w),
                ),
              ),
              child: Text(AppConst.createPost.draft),
            ),
          ),
          12.hGap,
          Expanded(
            child: ElevatedButton(
              onPressed: controller.publishPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.w),
                ),
              ),
              child: Text(AppConst.createPost.publish),
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: controller.titleController,
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    decoration: InputDecoration(
                      fillColor: AppColors.transparent,
                      hintText: AppConst.createPost.titleHint,
                      hintStyle: TextStyle(
                        fontSize: 16.w,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.w),
                    ),
                  ),
                ),
                Divider(height: 1.w),

                // 内容输入
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: controller.contentController,
                    maxLines: null,
                    minLines: 5,
                    style: TextStyle(
                      fontSize: 14.w,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: AppConst.createPost.inputTips,
                      fillColor: AppColors.transparent,
                      hintStyle: TextStyle(
                        fontSize: 14.w,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.w),
                    ),
                  ),
                ),

                // 图片上传区域
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 已上传图片列表
                          Obx(() {
                            if (controller.uploadedImages.isEmpty) {
                              return Container();
                            }
                            return Container(
                              height: 80.w,
                              margin: EdgeInsets.only(bottom: 16.w),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.uploadedImages.length,
                                separatorBuilder: (context, index) => 8.hGap,
                                itemBuilder: (context, index) {
                                  final image = controller.uploadedImages[index];
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 80.w,
                                        height: 80.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.w),
                                          image: DecorationImage(
                                            image: NetworkImage(image.url),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 4.w,
                                        top: 4.w,
                                        child: InkWell(
                                          onTap: () => controller.removeImage(image),
                                          child: Container(
                                            padding: EdgeInsets.all(4.w),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              CupertinoIcons.xmark,
                                              size: 12.w,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          }),
                          // 添加图片按钮
                          Obx(() => Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            child: controller.isUploading.value
                                ? Center(
                                    child: DisRefreshLoading(fontSize: 12.w,),
                                  )
                                : Material(
                                    color: AppColors.transparent,
                                    child: InkWell(
                                      onTap: controller.pickAndUploadImage,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.photo,
                                            size: 24.w,
                                            color: Theme.of(context).textTheme.bodyMedium?.color,
                                          ),
                                          4.hGap,
                                          Text(
                                            AppConst.createPost.addImage,
                                            style: TextStyle(
                                              fontSize: 12.w,
                                              color: Theme.of(context).textTheme.bodyMedium?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          )),
                        ],
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(AppConst.createPost.categoryHint),
          ),

          // 分类选择
          Container(
            margin: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
              onTap: () {
                _showCategoryPicker(context);
              },
              title: Obx(() => Text(
                    controller.selectedCategoryName.value ??
                        AppConst.createPost.selectCategory,
                    style: TextStyle(
                      fontSize: 14.w,
                      fontFamily: AppFontFamily.dinPro,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  )),
              trailing: Icon(
                CupertinoIcons.chevron_down,
                size: 16.w,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(AppConst.createPost.addTags),
          ),

          // 标签输入
          Padding(
            padding: EdgeInsets.all(12.w),
            child: _buildAddTagButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTagButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: DropdownSearch<TagItem>(
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
        items: (filter, cs) async {
          if (controller.tagResults.isNotEmpty) {
            return controller.tagResults.value;
          }
          await controller.searchTags(filter);
          return controller.tagResults.value;
        },
        compareFn: (item1, item2) => item1.id == item2.id,
        onChanged: (TagItem? tag) {
          if (tag != null) {
            controller.addTag(tag.targetTag ?? tag.name);
          }
        },
        itemAsString: (TagItem tag) => tag.name,
        suffixProps: DropdownSuffixProps(
          dropdownButtonProps: DropdownButtonProps(
            iconOpened: Icon(
              CupertinoIcons.chevron_down,
              size: 16.w,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            iconClosed: Icon(
              CupertinoIcons.chevron_down,
              size: 16.w,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        dropdownBuilder: (context, selectedItem) {
          return Row(
            children: [
              Expanded(
                child: Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: controller.tags.isEmpty 
                          ? Text(
                              AppConst.createPost.addTags,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ) 
                          : Row(
                              children: controller.tags.map((tag) {
                                final color = Tag.getTagColors(tag);
                                return Container(
                                  margin: EdgeInsets.only(right: 8.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.w),
                                  decoration: BoxDecoration(
                                    color: color.backgroundColor,
                                    border: Border.all(
                                      color: color.backgroundColor,
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 11.w,
                                          color: color.textColor,
                                        ),
                                      ),
                                      4.hGap,
                                      InkWell(
                                        onTap: () => controller.removeTag(tag),
                                        child: Icon(
                                          CupertinoIcons.xmark,
                                          size: 10.w,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    )),
              ),
            ],
          );
        },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              AppConst.createPost.searchTag,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          loadingBuilder: (context, searchEntry) =>
              Center(child: DisRefreshLoading()),
          menuProps: MenuProps(
            backgroundColor: Theme.of(context).cardColor,
          ),
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.w, horizontal: 12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
          ),
          itemBuilder: (BuildContext context, TagItem item, bool isDisabled,
              bool isSelected) {
            final color = Tag.getTagColors(item.name);
            return Container(
              color: isSelected ? Theme.of(context).highlightColor : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
                      decoration: BoxDecoration(
                        color: color.backgroundColor,
                        border: Border.all(
                          color: color.backgroundColor,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.w,
                          color: color.textColor,
                        ),
                      ),
                    ),
                    Text(
                      'x (${item.count})',
                      style: TextStyle(
                        fontSize: 10.w,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 显示分类选择对话框
  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.symmetric(vertical: 16.w),
          margin: EdgeInsets.only(top: 10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '选择分类',
                      style: TextStyle(
                        fontSize: 16.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              8.vGap,
              const Divider(),
              // 分类列表
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = controller.categories;
                  if (categories.isEmpty) {
                    return const Center(child: Text('暂无分类数据'));
                  }

                  return ListView.separated(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w,top: 10.w),               
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => Container(),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryItem(
                        category: category,
                        stats: controller.categoryStats[category.id] ?? {},
                        isSelected: controller.selectedCategory.value?.id ==
                            category.id,
                        onTap: (category, level) {
                          controller.updateSelectedCategory(category, level);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
