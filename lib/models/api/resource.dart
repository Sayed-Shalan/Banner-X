import 'error_model.dart';
import 'pagination_data.dart';

class Resource {
  //data
  dynamic data;
  ErrorModel? errorData;
  Status status;
  PaginationData? paginationData;

  //Constructors
  Resource({this.data, this.errorData, required this.status});

  Resource.success(
      {required this.data, this.paginationData, this.status = Status.success});

  Resource.error({this.errorData, this.status = Status.error});

  //Checks
  bool isSuccess() => status == Status.success;

  bool isError() => status == Status.error;
}
///Request Status Values
enum Status { error, success }
