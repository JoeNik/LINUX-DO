import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/models/about.dart';
import 'package:linux_do/net/api_service.dart';

class AboutController extends BaseController {
  final ApiService _apiService = Get.find();
  final aboutData = Rxn<AboutResponse>();
  
  @override
  void onInit() {
    super.onInit();
    _loadAboutData();
  }

  Future<void> _loadAboutData() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getAbout();
      aboutData.value = response;
    } catch (e) {
      showError('加载失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 刷新数据
  Future<void> refreshData() async {
    await _loadAboutData();
  }
} 