import 'package:flutter/material.dart';
import 'package:flash/flash.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class FlashHelper {
  static void showTopFlash(String? msg,
      {bool persistent = true,
      Color bckColor = kWarning,
      String title = "",
      bool showDismiss = false}) {
    showFlash(
      context: Get.context!,
      duration: const Duration(seconds: 5),
      persistent: persistent,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          // brightness: Brightness.light,
          // boxShadows: const [BoxShadow(blurRadius: 0)],
          // barrierBlur: 0.0,
          // barrierColor: Colors.black38,
          // barrierDismissible: true,
          child: FlashBar(
            title: title.isEmpty
                ? null
                : Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        height: 1.5,
                        fontSize: 16),
                  ),
            content: Center(
              child: Text(msg != null && msg.isNotEmpty ? msg : '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      height: 1.5,
                      color: Colors.white,
                      fontSize: 14)),
            ),
            elevation: 6,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(12),
                    bottomStart: Radius.circular(12))),
            behavior: FlashBehavior.fixed,
            position: FlashPosition.top,
            showProgressIndicator: false,
            shadowColor: Colors.black38,
            backgroundColor: bckColor,
            primaryAction: null,
            controller: controller,
          ),
        );
      },
    );
  }
}
