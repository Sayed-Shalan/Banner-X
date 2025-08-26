import 'package:bannerx/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'di/initial_bindings.dart';
import 'local/localization_service.dart';
import 'navigation/app_pages.dart';
import 'theme/app_themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

int kNumOfNav = 0;
var navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
          Constants.designSizeMinWidth, Constants.designSizeMinHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale?.languageCode) {
              return locale;
            }
          }
          return supportedLocales.first;
        },
        title: 'Banner X',
        theme: AppThemes.light,
        darkTheme: AppThemes.light,
        locale: LocalizationService.getCurrentLocale(),
        fallbackLocale: LocalizationService.fallbackLocale,
        home: null,

        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        initialBinding: InitialBindings(),
        translations: LocalizationService(),
        routingCallback: (Routing? route) => /*route == null ||
                route.isBlank! ||
                route.isBottomSheet! ||
                route.isDialog!
            ? kNumOfNav
            :*/ route?.isBack ?? true
                ? kNumOfNav--
                : kNumOfNav++,
        navigatorKey: navigatorKey,
      ),
    );
  }
}
