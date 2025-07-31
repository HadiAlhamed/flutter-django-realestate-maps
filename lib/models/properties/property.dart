// ignore_for_file: public_member_api_docs, sort_constructors_first

class Property {
  final int? id;
  final int? owner;
  bool? isActive = true;
  final String? propertyType;
  final String? city;
  final int? numberOfRooms;
  final int? bathrooms;
  final double? area;
  final double? price;
  final bool? isForRent;
  final double? latitude;
  final double? longitude;
  final String? mainPhotoUrl;
  final String? address;
  final double? rating;
  Property({
    this.isActive,
    this.bathrooms,
    this.rating,
    this.id,
    this.owner,
    this.propertyType,
    this.city,
    this.numberOfRooms,
    this.area,
    this.price,
    this.isForRent,
    this.latitude,
    this.longitude,
    this.mainPhotoUrl,
    this.address,
  });
  Property copyWith({
    int? id,
    int? owner,
    bool? isActive,
    String? propertyType,
    String? city,
    int? numberOfRooms,
    int? bathrooms,
    double? area,
    double? price,
    bool? isForRent,
    double? latitude,
    double? longitude,
    String? mainPhotoUrl,
    String? address,
    double? rating,
  }) {
    return Property(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      isActive: isActive ?? this.isActive,
      propertyType: propertyType ?? this.propertyType,
      city: city ?? this.city,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      price: price ?? this.price,
      isForRent: isForRent ?? this.isForRent,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
      address: address ?? this.address,
      rating: rating ?? this.rating,
    );
  }

  Property copyWithFromjson(Map<String, dynamic> json) {
    //we will use this with real time update to keep data consistent
    return Property(
      id: (json['id'] as int?) ?? id,
      owner: (json['owner'] as int?) ?? owner,
      area: (double.tryParse(json['area'] ?? '')) ?? area,
      city: (json['city'] as String?) ?? city,
      isForRent: (json['is_for_rent'] as bool?) ?? isForRent,
      numberOfRooms: (json['number_of_rooms'] as int?) ?? numberOfRooms,
      price: (double.tryParse(json['price'] ?? '')) ?? price,
      propertyType: (json['ptype'] as String?) ?? propertyType,
      latitude: (double.tryParse(json['latitude'] ?? '')) ?? latitude,
      longitude: (double.tryParse(json['longitude'] ?? '')) ?? longitude,
      mainPhotoUrl: (json['main_photo'] as String?) ?? mainPhotoUrl,
      address: (json['address'] as String?) ?? address,
      bathrooms: (json['bathrooms'] as int?) ?? bathrooms,
      isActive: (json['is_active'] ?? true) ?? isActive,
      rating: (double.tryParse(json['rating'] ?? '')) ?? rating,
    );
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int?,
      owner: json['owner'] as int?,
      area: double.tryParse(json['area'] ?? ''),
      city: json['city'] as String?,
      isForRent: json['is_for_rent'] as bool?,
      numberOfRooms: json['number_of_rooms'] as int?,
      price: double.tryParse(json['price'] ?? ''),
      propertyType: json['ptype'] as String?,
      latitude: double.tryParse(json['latitude'] ?? ''),
      longitude: double.tryParse(json['longitude'] ?? ''),
      mainPhotoUrl: json['main_photo'] as String?,
      address: json['address'] as String?,
      bathrooms: json['bathrooms'] as int?,
      isActive: json['is_active'] ?? true,
      rating: double.tryParse(json['rating'] ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      if (owner != null) 'owner': owner,
      if (address != null) 'address': address,
      if (mainPhotoUrl != null) 'main_photo': mainPhotoUrl,
      if (propertyType != null && propertyType!.isNotEmpty)
        'ptype': propertyType,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (numberOfRooms != null) 'number_of_rooms': numberOfRooms,
      if (area != null) 'area': area.toString(),
      if (price != null) 'price': price.toString(),
      if (isForRent != null) 'is_for_rent': isForRent,
      if (latitude != null) 'latitude': latitude!.toStringAsFixed(5),
      if (longitude != null) 'longitude': longitude!.toStringAsFixed(5),
      if (isActive != null) 'is_active': isActive,
      if (rating != null) 'rating': rating,
      if (bathrooms != null) 'bathrooms': bathrooms,
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
