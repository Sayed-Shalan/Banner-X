class Banner{
  final String? image;
  final String? videoPath;
  final String? type;
  final int? duration;

  const Banner({
    this.image,
    this.duration,
    this.videoPath,
    this.type, // video/mp4 or image/png and so on
  });

  factory Banner.fromMap(dynamic map) {
    return Banner(
      image: map['content']?['src'],
      videoPath: map['content']?['path'],
      type: map['content']?['type'],
      duration: int.tryParse(map['timer']) ?? 3, // seconds
    );
  }

  @override
  String toString() {
    return 'Banner{image: $image, videoPath: $videoPath, type: $type, duration: $duration}';
  }

  /// Helpers *******************************************************************
  bool get isVideo => (type ?? '').toLowerCase().startsWith('video');
  bool get isImage => (type ?? '').toLowerCase().startsWith('image');
}