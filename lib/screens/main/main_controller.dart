import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../../models/banner.dart' as banner_model;
import 'main_repository.dart';


class MainController extends BaseController<MainRepository>
    with GetSingleTickerProviderStateMixin {

  @override
  MainRepository get repository => Get.find(tag: tag);

  /// Data *********************************************************************
  final pageController = PageController();
  final banners = <banner_model.Banner>[].obs;
  final currentIndex = 0.obs;
  final timerProgress = 0.0.obs;
  Timer? _autoTransitionTimer;
  Timer? _progressTimer;

  /// Lifecycle methods ********************************************************
  @override
  onCreate() {
    loading.value = true;
    _fetchBanners();
  }

  @override
  onClose() {
    _autoTransitionTimer?.cancel();
    _progressTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  /// Auto transition methods **************************************************
  void _startAutoTransition() {
    if (banners.isEmpty) return;

    _autoTransitionTimer?.cancel();
    _progressTimer?.cancel();

    final currentBanner = banners[currentIndex.value];
    final durationSeconds = currentBanner.duration ?? 3;
    final duration = Duration(seconds: durationSeconds);

    // Reset progress
    timerProgress.value = 0.0;

    // Start progress timer (updates every 50ms for smooth animation)
    const progressInterval = Duration(milliseconds: 50);
    final totalSteps = duration.inMilliseconds / progressInterval.inMilliseconds;
    var currentStep = 0;

    _progressTimer = Timer.periodic(progressInterval, (timer) {
      currentStep++;
      timerProgress.value = currentStep / totalSteps;

      if (currentStep >= totalSteps) {
        timer.cancel();
      }
    });

    // Start main transition timer
    _autoTransitionTimer = Timer(duration, () {
      _goToNextBanner();
    });
  }

  void _goToNextBanner() {
    if (banners.isEmpty) return;

    final nextIndex = (currentIndex.value + 1) % banners.length;
    currentIndex.value = nextIndex;

    pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    _startAutoTransition();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    _startAutoTransition();
  }

  void pauseAutoTransition() {
    _autoTransitionTimer?.cancel();
    _progressTimer?.cancel();
  }

  void resumeAutoTransition() {
    _startAutoTransition();
  }

  /// APIs & Requests **********************************************************
  _fetchBanners()async{
    var resource = await repository.fetchBanners();
    if(resource.isSuccess()){
      banners.assignAll(resource.data);
      if (banners.isNotEmpty) {
        _startAutoTransition();
      }
    }
    loading.value = false;
  }
}
