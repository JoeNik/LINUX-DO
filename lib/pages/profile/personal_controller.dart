
import 'package:get/get.dart';
import 'package:linux_do/controller/base_controller.dart';

class PersonalController extends BaseController {
  final personalUserName = Get.arguments;

  @override
  void onInit() {
    super.onInit();
    getPersonalInfo();
  }

  void getPersonalInfo() {
    
  }
}
