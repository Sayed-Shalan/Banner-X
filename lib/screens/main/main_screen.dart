import 'package:bannerx/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bannerx/widgets/video_banner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../base/base_view.dart';
import '../../models/api/page_properties.dart';
import '../../models/banner.dart' as banner_model;
import 'main_controller.dart';

class MainScreen extends BaseView<MainController> {
  MainScreen({super.key});

  @override
  PageProperties get pageProperties => PageProperties(
    showAppBar: false,
    extendBody: false,
  );

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return _buildLoadingWidget();
      }

      if (controller.banners.isEmpty) {
        return _buildEmptyWidget();
      }

      return _buildBannerPageView();
    });
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: Get.width,
      height: Get.height,
      alignment: Alignment.center,
      child: const SpinKitFadingCircle(
        color: kPrimary,
        size: 50.0,
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      width: Get.width,
      height: Get.height,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'لا يوجد اعلانات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPageView() {
    return Stack(
      children: [
        PageView.builder(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.banners.length,
          itemBuilder: (context, index) {
            final banner = controller.banners[index];
            return _buildBannerItem(banner);
          },
        ),
        // _buildPageIndicator(),
        // _buildTimerIndicator(),
      ],
    );
  }

  Widget _buildBannerItem(banner_model.Banner banner) {
    if (banner.isVideo && (banner.videoPath ?? '').isNotEmpty) {
      return VideoBanner(
        manifestPath: banner.videoPath!,
        onFinished: controller.goToNextBanner,
      );
    }

    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: CachedNetworkImage(
        imageUrl: banner.image ?? '',
        fit: BoxFit.contain,
        placeholder: (context, url) => _buildImagePlaceholder(),
        errorWidget: (context, url, error) => _buildImageError(),
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitPulse(
              color: kPrimary,
              size: 60.0,
            ),
            SizedBox(height: 16),
            // Text('جاري تحميل الصورة٫٫٫',
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.grey,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: Get.width,
      height: Get.height,
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 80,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text('فشل تحميل الصورة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.banners.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: controller.currentIndex.value == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: controller.currentIndex.value == index
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildTimerIndicator() {
    return Positioned(
      top: 50,
      right: 20,
      child: Obx(() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 3,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
              ),
            ),
            // Progress circle
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: controller.timerProgress.value,
                strokeWidth: 3,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            // Timer text
            Text(
              '${((1 - controller.timerProgress.value) * (controller.banners.isNotEmpty ? (controller.banners[controller.currentIndex.value].duration ?? 3) : 3)).ceil()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )),
    );
  }
}
