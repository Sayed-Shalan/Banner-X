import 'package:bannerx/models/banner.dart';
import 'package:bannerx/utils/collections.dart';
import 'package:bannerx/utils/constants.dart';
import '../../base/base_repository.dart';
import '../../models/api/resource.dart';

class MainRepository extends BaseRepository {
  Future<Resource> fetchBanners() async {
    return request(
        pushError: false,
        callback: () async {
          var response = await collection(Collections.banners)
              .where("visible", isEqualTo: true)
              .orderBy(Constants.fieldSortIndex, descending: false)
              .get();
          return Resource.success(
              data:
                  response.docs.map((e) => Banner.fromMap(e.data())).toList());
        });
  }
}
