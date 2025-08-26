import 'package:get/get.dart';
import '../../base/base_bindings.dart';
import 'main_controller.dart';
import 'main_repository.dart';

class MainBindings extends BaseBindings {
  @override
  void dependencies() {
    Get.put(MainRepository(), tag: tag);
    Get.put(MainController(), tag: tag);
  }
}
