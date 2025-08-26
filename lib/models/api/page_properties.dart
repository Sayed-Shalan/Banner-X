import 'package:flutter/material.dart';

class PageProperties {
  //Data
  final String? title;
  final bool showAppBar, resizeToAvoidBottomInset, extendBody;
  final double appBarElevation;
  final bool closeIcon;
  final bool centerTitle;
  final bool statusBarIconsWhite;
  final Color? statusBarColor;
  final Color? scaffoldColor;

  PageProperties(
      {this.showAppBar = true,
      this.appBarElevation = 0,
      this.extendBody = false,
      this.closeIcon = false,
      this.statusBarIconsWhite = false,
      this.title,
      this.statusBarColor,
      this.resizeToAvoidBottomInset = false,
      this.centerTitle = false,
      this.scaffoldColor});
}
