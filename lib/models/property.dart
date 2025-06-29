// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:latlong2/latlong.dart';

class Property {
  final int? id;
  final int? owner;
  final String propertyType;
  final String city;
  final int numberOfRooms;
  final double area;
  final double price;
  final bool isForRent;
  final LatLng? latitude;
  final LatLng? longitude;
  final String? mainPhotoUrl;
  final String? address;

  Property({
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
      owner : json['owner'] as int,
      area: double.parse(json['area'] as String),
      city: json['city'] as String,
      isForRent: json['is_for_rent'] as bool,
      numberOfRooms: json['number_of_rooms'] as int,
      price: double.parse(json['price'] as String),
      propertyType: json['ptype'] as String,
      latitude: json['latitude'],
      longitude: json['longitude'],
      mainPhotoUrl: json['main_photo'],
      address: json['address'],
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
