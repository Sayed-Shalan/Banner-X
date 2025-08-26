import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class Loader extends StatelessWidget {
  //Data
  final LoaderSize size;
  final Color? color;

  //Constructor
  const Loader({super.key, this.size = LoaderSize.normal, this.color});

  //Build *****************************
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size == LoaderSize.normal
            ? 25
            : size == LoaderSize.small
                ? 15
                : 35,
        height: size == LoaderSize.normal
            ? 25
            : size == LoaderSize.small
                ? 15
                : 35,
        child: SpinKitWaveSpinner(
          color: color ?? Get.theme.primaryColor,
          size: size == LoaderSize.normal
              ? 25
              : size == LoaderSize.small
                  ? 15
                  : 35,
        ));
  }
}

enum LoaderSize { normal, large, small }
