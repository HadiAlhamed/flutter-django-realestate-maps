class PropertyImage {
  final int id;
  final String image;
  final String imageUrl;
  final String? caption;

  PropertyImage({
    required this.id,
    required this.image,
    required this.imageUrl,
    this.caption,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'],
      image: json['image'],
      imageUrl: json['image_url'],
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'image': image,
      'image_url': imageUrl,
      'caption': caption,
    };
  }
}
