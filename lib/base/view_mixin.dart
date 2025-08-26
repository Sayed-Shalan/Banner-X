import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../local/localization_service.dart';
import '../models/api/page_properties.dart';
import '../theme/app_colors.dart';

mixin ViewMixin {
  ///Data

  ///Getter &Setters
  PageProperties get pageProperties;

  Widget buildPage(BuildContext context) {
    return WillPopScope(onWillPop: onPopup, child: AnnotatedRegion<SystemUiOverlayStyle>(
        value:  SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: pageProperties.statusBarIconsWhite? Brightness.light: Brightness.dark, // Android
          statusBarBrightness: pageProperties.statusBarIconsWhite? Brightness.dark:Brightness.light,      // iOS
        ),
        child: buildScaffold(context)));
  }

  ///Build widgets methods
  Scaffold buildScaffold(BuildContext context) {
    // if (FlavorConfig.isDev()) {
    //   NetworkLoggerOverlay.attachTo(context);
    // }
    return Scaffold(
        extendBodyBehindAppBar: pageProperties.extendBody,
        drawerDragStartBehavior: DragStartBehavior.start,
        appBar: buildAppBar(),
        backgroundColor:
            pageProperties.scaffoldColor ?? Get.theme.scaffoldBackgroundColor,
        body: GestureDetector(
            onTap: () {
              if (Get.context != null) {
                FocusScope.of(Get.context!).requestFocus(FocusNode());
              }
            },
            child: buildBody(context)!),
        drawer: buildDrawer(),
        bottomNavigationBar: buildBottomBar(context),
        bottomSheet: buildSheet(),
        floatingActionButton: buildFloatButton(),
        resizeToAvoidBottomInset: pageProperties.resizeToAvoidBottomInset);
  }

  ///get app-bar ***************************************************************
  AppBar? buildAppBar() {
    if (!pageProperties.showAppBar) return null;

    return AppBar(
      bottom: buildBottomAppBar(),
      backgroundColor: Get.theme.appBarTheme.backgroundColor,
      centerTitle: pageProperties.centerTitle,
      elevation: pageProperties.appBarElevation,
      actions: buildAppbarActions(),
      titleSpacing: 0,
      leading: buildBackButton(),
      title: buildAppBarTitle(),

    );
  }

  ///Abstract - instance  methods to do extra work after init
  //set tool actions
  List<Widget> buildAppbarActions() {
    return [];
  }

  Widget? buildBackButton() {
    return Get.key.currentState!.canPop()
        ? IconButton(
            icon: Padding(
              padding: EdgeInsetsDirectional.only(start: 0.w),
              child: pageProperties.closeIcon? const Icon(
                 Icons.close,
                color: kPrimary,
              ): const Icon(
                Icons.arrow_back,
                color: kPrimary,
              ),
            ),
            onPressed: onPopup,
          )
        : null;
  }

  //Build Drawer
  Widget? buildDrawer() {
    return null;
  }

  //Build Your Custom Body
  Widget? buildBody(BuildContext context) {
    return null;
  }

  Widget? buildBottomBar(BuildContext context) {
    return null;
  }

  Widget? buildSheet() {
    return null;
  }

  PreferredSize? buildBottomAppBar() {
    return null;
  }

  Widget? buildFloatButton() {
    return null;
  }

  Widget buildAppBarTitle() {
    return Text(
      pageProperties.title ?? '',
      maxLines: 2,
      style: Get.textTheme.displayLarge?.copyWith(fontSize: 17.sp, height: 1.4),
    ).paddingOnly(bottom: 8.h);
  }

  ///POP ***********************************************************************
  Future<bool> onPopup() {
    Get.back();
    return Future.value(true);
  }
}
