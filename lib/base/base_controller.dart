import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../helper/flash_helper.dart';
import '../theme/app_colors.dart';
import 'base_repository.dart';
import 'mixin_overlays.dart';

abstract class BaseController<R extends BaseRepository> extends GetxController
    with Overlays {
  /// Constructor **************************************************************
  final String tag = Get.currentRoute + kNumOfNav.toString();

  ///Data & Observables ********************************************************
  var loading = false.obs;
  bool get globalRepository => false;

  /// inject repo
  R? get repository;

  injectRepository() {}

  /// U need to inject a repo instance if not coming from a root , Bindings()

  // add all listeners to dispose them
  final List<StreamSubscription?> _disposableList = [];

  ///Matches on page creates
  @override
  void onInit() {
    injectRepository();
    onCreate();
    super.onInit();
  }

  ///Matches on page resume
  @override
  void onReady() {
    _observeError();
    onResume();
    super.onReady();
  }

  @override
  void dispose() {
    repository?.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    onDestroy();
    for (StreamSubscription? subscription in _disposableList) {
      subscription?.cancel();
    }
    _deleteRepository();
    super.onClose();
  }

  _deleteRepository() {
    loading.close();
    if (!globalRepository && GetInstance().isRegistered<R>(tag: tag)) {
      GetInstance().delete<R>(tag: tag);
    }
  }

  //observe error
  _observeError() {
    var subscription = repository?.errorObservable.stream.listen((event) {
      showErrorMessage(event.message);
    });
    _disposableList.add(subscription);
  }

  /// Messages
  showErrorMessage(String? msg) {
    show(msg!, kRed);
  }

  showSuccessMessage(String msg) {
    show(msg, kGreen);
  }

  showMessage(String msg) {
    show(msg, kWarning);
  }

  show(String msg, Color color) {
    FlashHelper.showTopFlash(msg, bckColor: color);
  }

  delay()async{
   await Future.delayed(const Duration(seconds: 1));
  }

  ///Abstract - instance  methods to do extra work after init
  onCreate() {}

  onResume() {}

  onDestroy() {}

  ///Helper methods ************************************************************
  addDisposable(StreamSubscription subscription) =>
      _disposableList.add(subscription);

  closeDisposableAtIndex(int index) {
    _disposableList[index]?.cancel();
    _disposableList.removeAt(index);
  }

  stopLoading() {
    loading.value = false;
  }

  hideKeyboard() => FocusScope.of(Get.context!).requestFocus(FocusNode());

}
