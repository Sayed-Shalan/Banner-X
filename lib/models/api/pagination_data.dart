
class PaginationData {
  int? startIndex, lastIndex, totalPage;
  bool? replace; // if coming from real-time -> replace old list with new one from $startIndex to $lastIndex
  String? tabName; // refers to name of tab that sent the request

  PaginationData.elastic({
    required this.totalPage,
  });

  PaginationData({this.startIndex, this.lastIndex, this.replace, this.tabName});

  bool get clear => startIndex==0;

}
