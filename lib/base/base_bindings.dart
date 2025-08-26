import 'package:get/get.dart';
import '../app.dart';

abstract class BaseBindings extends Bindings {
  String get tag => Get.currentRoute + kNumOfNav.toString();
}
