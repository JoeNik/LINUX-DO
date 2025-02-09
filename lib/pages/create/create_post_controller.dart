import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../const/app_const.dart';
import '../../controller/base_controller.dart';
import '../../controller/global_controller.dart';
import '../../net/api_service.dart';
import '../../models/category_data.dart';
import '../../models/tag_data.dart';
import '../../models/image_size.dart';
import '../../models/upload_image_response.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:math';

class CreatePostController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();

  // 标题
  final titleController = TextEditingController();
  // 内容
  final contentController = TextEditingController();
  // 选中的分类
  final selectedCategory = Rx<Category?>(null);
  final selectedCategoryName = Rxn<String>();
  // 是否正在提交
  final isSubmitting = false.obs;
  // 标签列表
  final tags = <String>[].obs;
  // 标签输入控制器 
  final tagController = TextEditingController();
  // 是否在预览模式
  final isPreview = false.obs;
  // 分类列表
  final categories = <Category>[].obs;
  // 分类统计数据
  final categoryStats = <int, Map<int, int>>{}.obs;
  // 标签搜索结果
  final tagResults = <TagItem>[].obs;
  // 图片列表
  final uploadedImages = <UploadImageResponse>[].obs;
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时加载所有分类的统计数据
    loadAllCategoryStats();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    super.onClose();
  }

  // 加载所有分类的统计数据
  Future<void> loadAllCategoryStats() async {
    try {
      isLoading.value = true;
      
      // 获取所有分类
      final categoriesResponse = await _apiService.getCategories();
      categories.value = categoriesResponse.categoryList.categories;
      
      // 更新统计数据
      for (var category in categories) {
        // 根据权限等级计算可见的主题数量
        final totalTopics = category.topicCount;
        categoryStats[category.id] = {
          1: totalTopics ?? 0, // Lv1 可以看到所有主题
          2: category.permission == 2 ? totalTopics ?? 0 : 0, // Lv2 只能看到权限等级=2的主题
          3: category.permission == 3 ? totalTopics ?? 0 : 0, // Lv3 只能看到权限等级=3的主题
        };
      }
      /// 默认选中第一个分类
      selectedCategory.value = categories.first;
      selectedCategoryName.value = categories.first.name;
    } catch (e) {
      debugPrint('Error loading categories: $e');
      showToast('加载分类数据失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 获取指定分类和权限等级的帖子数量
  int getTopicCount(int categoryId, int level) {
    return categoryStats[categoryId]?[level] ?? 0;
  }

  // 更新选中的分类
  void updateSelectedCategory(Category category, [int? level]) {
    selectedCategory.value = category;
    String displayName = level == null
        ? category.name ?? ''
        : '${category.name} (Lv $level)';
    selectedCategoryName.value = displayName;
    // 清空标签搜索结果
    tagResults.clear();
    tags.clear();
  }

  // 搜索标签
  Future<List<TagItem>> searchTags(String query) async {
    if (selectedCategory.value == null) {
      return [];
    }
    
    try {
      // 如果搜索关键词为空，且已有结果，直接返回
      if (query.isEmpty && tagResults.isNotEmpty) {
        return tagResults;
      }
      
      final response = await _apiService.getTags(
        query,
        8,
        selectedCategory.value!.id,
        true,
      );
      tagResults.value = response.results;
      return response.results;
    } catch (e) {
      debugPrint('Error searching tags: $e');
      return [];
    }
  }

  // 添加标签
  void addTag(String tag) {
    /// 异步添加标签
    Future.delayed(const Duration(milliseconds: 500), () {
      if (tag.isNotEmpty && !tags.contains(tag)) {
        tags.add(tag);
        tagController.clear();
      }
    });
  }

  // 删除标签
  void removeTag(String tag) {
    tags.remove(tag);
  }

  // 格式化内容为HTML
  String _formatContentToHtml() {
    if (contentController.text.isEmpty) return '';
    
    // 按行分割内容
    final lines = contentController.text.split('\n');
    final formattedLines = <String>[];
    
    for (var line in lines) {
      if (line.isEmpty) {
        continue;
      }
      
      // 处理图片标记 ![name|widthxheight](url)
      if (line.contains('![') && line.contains('](')) {
        final imagePattern = RegExp(r'!\[(.*?)\|(\d+)x(\d+)\]\((.*?)\)');
        final match = imagePattern.firstMatch(line);
        if (match != null) {
          final name = match.group(1) ?? '';
          final width = match.group(2) ?? '';
          final height = match.group(3) ?? '';
          final url = match.group(4) ?? '';
          
          // 直接使用图片URL
          line = '<img src="$url" alt="$name" width="$width" height="$height">';
        }
      }
      
      // 将处理后的行包装在p标签中
      formattedLines.add('<p>$line</p>');
    }
    
    // 连接所有行
    return formattedLines.join('\n');
  }

  // 切换预览模式
  void togglePreview() {
    if (!validateInputs()) return;
    
    // 预览不重要, 碰到问题了,先不做
    // Get.to(() => const PreviewPostPage(), binding: BindingsBuilder(() {
    //   Get.put(PreviewPostController(
    //     title: titleController.text,
    //     content: _formatContentToHtml(),
    //     category: selectedCategory.value!,
    //     tags: tags,
    //   ));
    // }));
  }

  // 计算文件的SHA1
  String _calculateSha1(List<int> bytes) {
    return sha1.convert(bytes).toString();
  }

  // 生成短文件名
  String _generateShortFileName(String originalFileName) {
    final extension = originalFileName.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final random = (1000 + Random().nextInt(9000)).toString();
    return 'img_${timestamp}_$random.$extension';
  }

  // 选择并上传图片
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      isUploading.value = true;
      try {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final originalFileName = pickedFile.path.split('/').last;
        final shortFileName = _generateShortFileName(originalFileName);
        final sha1Checksum = _calculateSha1(bytes);
        
        // 创建 FormData
        final formData = dio.FormData.fromMap({
          'upload_type': 'composer',
          'pasted': false,
          'name': shortFileName,
          'type': 'image/${shortFileName.split('.').last}',
          'sha1_checksum': sha1Checksum,
          'file': await dio.MultipartFile.fromFile(
            pickedFile.path,
            filename: shortFileName,
          ),
        });
        
        final response = await _apiService.uploadImage(
          GlobalController.clientId,
          formData,
        );
        
        uploadedImages.add(response);
        
        // 将图片插入到内容中
        final imageMarkdown = '\n![${response.originalFilename}|${response.width}x${response.height}](${response.shortUrl})\n';
        final currentContent = contentController.text;
        final cursorPosition = contentController.selection.baseOffset;
        
        if (cursorPosition >= 0) {
          final newContent = currentContent.substring(0, cursorPosition) +
              imageMarkdown +
              currentContent.substring(cursorPosition);
          contentController.text = newContent;
          contentController.selection = TextSelection.collapsed(
            offset: cursorPosition + imageMarkdown.length,
          );
        } else {
          contentController.text += imageMarkdown;
        }
      } catch (e,s) {
        showToast(AppConst.createPost.uploadFailed);
        debugPrint('Error uploading image: $e -- $s');
      } finally {
        isUploading.value = false;
      }
    }
  }

  // 删除图片
  void removeImage(UploadImageResponse image) {
    uploadedImages.remove(image);
    // 从内容中移除图片引用
    final imagePattern = '\\!\\[${image.originalFilename}\\|${image.width}x${image.height}\\]\\(${image.shortUrl}\\)';
    final regex = RegExp(imagePattern);
    contentController.text = contentController.text.replaceAll(regex, '');
  }

  // 发布帖子
  Future<void> publishPost() async {
    if (!validateInputs()) return;
    
    try {
      isSubmitting.value = true;
      // 构建图片尺寸映射
      final imageSizes = <String, ImageSize>{};
      for (final image in uploadedImages) {
        imageSizes[image.url] = ImageSize(
          width: image.width,
          height: image.height,
        );
      }

      final response = await _apiService.createPost(
        title: titleController.text,
        content: contentController.text,
        categoryId: selectedCategory.value!.id,
        tags: tags,
        imageSizes: imageSizes,
      );

      if (response.success) {
        Get.back(result: response);
        showToast(AppConst.createPost.publishSuccess);
      } else {
        showToast(AppConst.createPost.publishFailed);
      }
    } catch (e) {
      showToast(AppConst.createPost.publishFailed);
    } finally {
      isSubmitting.value = false;
    }
  }

  // 保存草稿
  Future<void> saveDraft() async {
    if (!validateInputs()) return;
    
    try {
      isSubmitting.value = true;

      await Future.delayed(const Duration(seconds: 1)); 
      Get.back();
      showToast(AppConst.createPost.draftSuccess);
    } catch (e) {
      showToast(AppConst.createPost.draftFailed);
    } finally {
      isSubmitting.value = false;
    }
  }

  // 验证输入
  bool validateInputs() {
    if (titleController.text.isEmpty) {
      showToast(AppConst.createPost.titleRequired);
      return false;
    }
    if (contentController.text.isEmpty) {
      showToast(AppConst.createPost.contentRequired);
      return false;
    }
    if (selectedCategory.value == null) {
      showToast(AppConst.createPost.categoryRequired);
      return false;
    }
    return true;
  }
} 