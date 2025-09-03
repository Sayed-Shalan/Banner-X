import 'dart:developer';
import 'package:bannerx/models/banner.dart';
import 'package:bannerx/utils/collections.dart';
import 'package:bannerx/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
          
          final banners = <Banner>[];
          for (final doc in response.docs) {
            final banner = Banner.fromMap(doc.data());
            
            // If it's a video, we need to handle the path correctly
            if (banner.isVideo && banner.videoPath != null) {
              try {
                // Extract the path from the full URL
                // From: https://storage.googleapis.com/bannerex.firebasestorage.app/output/uvfsqn5yg9l_WhatsApp Video 2025-09-03 at 7.07.58 PM.mp4/
                // To: output/uvfsqn5yg9l_WhatsApp Video 2025-09-03 at 7.07.58 PM.mp4/
                final uri = Uri.parse(banner.videoPath!);
                final pathSegments = uri.pathSegments;
                if (pathSegments.isNotEmpty) {
                  // Remove the first segment (bucket name) and join the rest
                  final storagePath = pathSegments.skip(1).join('/');
                  final storageRef = FirebaseStorage.instance.ref(storagePath);
                  final downloadUrl = await storageRef.getDownloadURL();
                  
                  log('Generated download URL: $downloadUrl');
                  
                  // Create a new banner with the download URL
                  final updatedBanner = Banner(
                    image: banner.image,
                    videoPath: downloadUrl,
                    type: banner.type,
                    duration: banner.duration,
                  );
                  banners.add(updatedBanner);
                } else {
                  banners.add(banner);
                }
              } catch (e) {
                log('Failed to generate download URL: $e');
                // If we can't get download URL, add the original banner
                banners.add(banner);
              }
            } else {
              banners.add(banner);
            }
          }
          
          return Resource.success(data: banners);
        });
  }
}
