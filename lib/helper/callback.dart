import '../models/api/resource.dart';

///Request methods middleware callbacks
typedef RequestCallback = Future<Resource> Function();
