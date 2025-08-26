import 'package:get/get.dart';
import '../screens/main/main_bindings.dart';
import '../screens/main/main_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.main;

  static final routes = <GetPage>[
    /// Default *******************
    GetPage(
      name: Routes.main,
      page: () => MainScreen(),
      binding: MainBindings(),
    ),
  ];
}
