// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'package:real_estate/models/facility.dart';
import 'package:real_estate/models/property.dart';
import 'package:real_estate/models/property_image.dart';

class PropertyDetails {
  final int id;
  final int? owner;
  final String propertyType;
  final String city;
  final int numberOfRooms;
  final double area;
  final String? locationText;
  final double price;
  final bool isForRent;
  final String? details;
  final double? latitude;
  final double? longitude;
  final List<Facility?> facilities;
  final List<PropertyImage?> images;
  PropertyDetails({
    required this.id,
    this.owner,
    required this.propertyType,
    required this.city,
    required this.numberOfRooms,
    required this.area,
    this.locationText,
    required this.price,
    required this.isForRent,
    this.details,
    this.latitude,
    this.longitude,
    required this.facilities,
    required this.images,
  });

  PropertyDetails copyWith({
    int? id,
    int? owner,
    String? propertyType,
    String? city,
    int? numberOfRooms,
    double? area,
    String? locationText,
    double? price,
    bool? isForRent,
    String? details,
    double? latitude,
    double? longitude,
    List<Facility?>? facilities,
    List<PropertyImage?>? images,
  }) {
    return PropertyDetails(
      id: id ?? this.id,
      owner : owner ?? owner,
      propertyType: propertyType ?? this.propertyType,
      city: city ?? this.city,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      area: area ?? this.area,
      locationText: locationText ?? this.locationText,
      price: price ?? this.price,
      isForRent: isForRent ?? this.isForRent,
      details: details ?? this.details,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      facilities: facilities ?? this.facilities,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'owner' : owner,
      'ptype': propertyType,
      'city': city,
      'number_of_rooms': numberOfRooms,
      'area': area.toString(),
      'location_text': locationText,
      'price': price.toString(),
      'is_for_rent': isForRent,
      'details': details,
      'latitude': latitude,
      'longitude': longitude,
      'facilities': facilities.map((x) => x?.toJson()).toList(),
      'images': images.map((x) => x?.toJson()).toList(),
    };
  }

  Property toProperty() {
    return Property(
      id: id,
      owner: owner,
      propertyType: propertyType,
      city: city,
      numberOfRooms: numberOfRooms,
      area:   area,
      price:   price,
      isForRent:   isForRent,
      latitude:   latitude,
      longitude:   longitude,
      mainPhotoUrl:   images.isNotEmpty ? images[0]!.imageUrl : null,
    );
  }


  factory PropertyDetails.fromJson(Map<String, dynamic> map) {
    return PropertyDetails(
      id: map['id'] as int,
      owner: map['owner'] as int,
      propertyType: map['ptype'] as String,
      city: map['city'] as String,
      numberOfRooms: map['number_of_rooms'] as int,
      area: double.parse(map['area'] as String),
      locationText:
          map['location_text'] != null ? map['location_text'] as String : null,
      price: double.parse(map['price'] as String),
      isForRent: map['is_for_rent'] as bool,
      details: map['details'] != null ? map['details'] as String : null,
      latitude: double.tryParse(map['latitude'] as String),
      longitude: double.tryParse(map['longitude'] as String), 
      facilities: List<Facility?>.from(
        (map['facilities'] as List).map<Facility?>(
          (x) => Facility.fromJson(x as Map<String, dynamic>),
        ),
      ),
      images: List<PropertyImage?>.from(
        (map['images'] as List).map<PropertyImage?>(
          (x) => PropertyImage.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'PropertyDetails(id: $id, owner: $owner,  propertyType: $propertyType, city: $city, numberOfRooms: $numberOfRooms, area: $area, locationText: $locationText, price: $price, isForRent: $isForRent, details: $details, latitude: $latitude, longitude: $longitude, facilities: $facilities, images: $images)';
  }

  @override
  bool operator ==(covariant PropertyDetails other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.owner == owner &&
        other.propertyType == propertyType &&
        other.city == city &&
        other.numberOfRooms == numberOfRooms &&
        other.area == area &&
        other.locationText == locationText &&
        other.price == price &&
        other.isForRent == isForRent &&
        other.details == details &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        listEquals(other.facilities, facilities) &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      
        propertyType.hashCode ^
        city.hashCode ^
        numberOfRooms.hashCode ^
        area.hashCode ^
        locationText.hashCode ^
        price.hashCode ^
        isForRent.hashCode ^
        details.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        facilities.hashCode ^
        images.hashCode;
  }
}
