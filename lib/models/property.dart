// ignore_for_file: public_member_api_docs, sort_constructors_first

class Property {
  final int? id;
  final int? owner;
  bool? isActive = true;
  final String propertyType;
  final String city;
  final int numberOfRooms;
  final int bathrooms;
  final double area;
  final double price;
  final bool isForRent;
  final double? latitude;
  final double? longitude;
  final String? mainPhotoUrl;
  final String? address;
  final double? rating;
  Property({
    this.isActive,
    required this.bathrooms,
    this.rating,
    this.id,
    this.owner,
    required this.propertyType,
    required this.city,
    required this.numberOfRooms,
    required this.area,
    required this.price,
    required this.isForRent,
    this.latitude,
    this.longitude,
    this.mainPhotoUrl,
    this.address,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      owner: json['owner'] as int,
      area: double.parse(json['area'] as String),
      city: json['city'] as String,
      isForRent: json['is_for_rent'] as bool,
      numberOfRooms: json['number_of_rooms'] as int,
      price: double.parse(json['price'] as String),
      propertyType: json['ptype'] as String,
      latitude: double.tryParse(json['latitude']),
      longitude: double.tryParse(json['longitude']),
      mainPhotoUrl: json['main_photo'],
      address: json['address'],
      bathrooms: json['bathrooms'],
      isActive: json['is_active'] ?? true,
      rating: double.tryParse(json['rating']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ptype': propertyType,
      'city': city,
      'number_of_rooms': numberOfRooms,
      'area': area.toString(),
      'price': price.toString(),
      'is_for_rent': isForRent,
      'latitude': latitude!.toStringAsFixed(5),
      'longitude': longitude!.toStringAsFixed(5),
      'is_active': isActive ?? true,
      'rating': rating ?? 0.0,
      'bathrooms': bathrooms,
    };
  }

  @override
  String toString() {
    return 'Property(id: $id, propertyType: $propertyType, city: $city, numberOfRooms: $numberOfRooms, area: $area, price: $price, isForRent: $isForRent, latitude: $latitude, longitude: $longitude, mainPhotoUrl: $mainPhotoUrl)';
  }

  @override
  bool operator ==(covariant Property other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.propertyType == propertyType &&
        other.city == city &&
        other.numberOfRooms == numberOfRooms &&
        other.area == area &&
        other.price == price &&
        other.isForRent == isForRent &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.mainPhotoUrl == mainPhotoUrl &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyType.hashCode ^
        city.hashCode ^
        numberOfRooms.hashCode ^
        area.hashCode ^
        price.hashCode ^
        isForRent.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        mainPhotoUrl.hashCode;
  }
}
