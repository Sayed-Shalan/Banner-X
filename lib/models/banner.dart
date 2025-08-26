class Banner{
  final String? image;
  final int? duration;

  const Banner({
    this.image,
    this.duration,
  });

  factory Banner.fromMap(dynamic map) {
    return Banner(
      image: map['content']?['src'],
      duration: int.tryParse(map['timer']) ?? 3, // seconds
    );
  }
}