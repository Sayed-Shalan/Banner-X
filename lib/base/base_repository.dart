import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../helper/callback.dart';
import '../models/api/error_model.dart';
import '../models/api/resource.dart';

abstract class BaseRepository {
  /// Use [fetch,update,create,delete] ex fetchUserData(), updatePhoneNumber(), deletePost() || action name in unique cases .. and so on.

  //Controllers needs to disabled
  final List<StreamSubscription> _disposableList = [];

  //Paging
  final pageLimit = 6;

  // For firebase pagination
  var endDocuments = false;
  DocumentSnapshot? lastDocSnap;

  //error rx
  var errorObservable = ErrorModel().obs;

  setError(ErrorModel? errorData) {
    errorObservable.value = errorData!;
  }

  //Error Handler
  Resource handleError(e) {
    if (e is DioException && e.error is SocketException) {
      return Resource.error(
          errorData: ErrorModel(message: 'no_internet_connection'.tr));
    }
    if (e is SocketException) {
      return Resource.error(
          errorData: ErrorModel(message: 'no_internet_connection'.tr));
    } else if (e is FirebaseException) {
      return Resource.error(errorData: ErrorModel(message: e.message));
    } else {
      return Resource.error(errorData: ErrorModel(message: e.toString()));
    }
  }

  /// Request methods *******************************************

  //Generic request methods
  Future<Resource> request(
      {bool pushError = true, required RequestCallback callback}) async {
    try {
      Resource resource = await callback.call();
      if (resource.isSuccess()) if (kDebugMode) log("DATA = ${resource.data}");
      if (resource.isError() && pushError && resource.errorData != null) {
        setError(resource.errorData);
      }
      return resource;
    } catch (e, stackTrace) {
      debugPrint("Error = $stackTrace");
      debugPrint("Error = $e");
      Resource resource = handleError(e);
      if (resource.isError() && pushError && resource.errorData != null) {
        setError(resource.errorData);
      }
      return resource;
    }
  }

  //Generic request real-time methods

  ///fire-store helper
  CollectionReference collection(String name) =>
      FirebaseFirestore.instance.collection(name);

  ///close controllers
  void dispose() {
    errorObservable.close();
    for (StreamSubscription? controller in _disposableList) {
      if (controller != null) controller.cancel();
    }
  }

  ///Helper methods ****
  addDisposable(StreamSubscription subscription) =>
      _disposableList.add(subscription);

  ///reset Pagination
  resetPagination() {
    endDocuments = false;
    lastDocSnap = null;
  }
}
