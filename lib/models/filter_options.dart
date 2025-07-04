// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

class FilterOptions {
  bool? isForRent = true;
  bool? isForSale = true;
  bool? orderByArea = true;
  bool? orderByPrice = true;
  bool? orderAsc = true;
  bool? villa = true;
  bool? flat = true;
  bool? house = true;
  double? minPrice = 0;
  double? maxPrice = 100000.0;
  double? minArea = 0;
  double? maxArea = 1000.0;
  int? minRooms = 0;
  int? maxRooms = 10;

  List<String> selectedCities = <String>[];
  bool? isActive = true;
  bool? isNotActive = false;
  double? minRating = 0.0;
  double? maxRating = 5.0;
  int? minBaths = 0;
  int? maxBaths = 10;
  FilterOptions({
    this.isForRent,
    this.isForSale,
    this.orderByArea,
    this.orderByPrice,
    this.orderAsc,
    this.villa,
    this.flat,
    this.house,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.minRooms,
    this.maxRooms,
    required this.selectedCities,
  });

  FilterOptions copyWith({
    bool? isForRent,
    bool? isForSale,
    bool? orderByArea,
    bool? orderByPrice,
    bool? orderAsc,
    bool? villa,
    bool? flat,
    bool? house,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? minRooms,
    int? maxRooms,
    List<String>? selectedCities,
  }) {
    return FilterOptions(
      isForRent: isForRent ?? this.isForRent,
      isForSale: isForSale ?? this.isForSale,
      orderByArea: orderByArea ?? this.orderByArea,
      orderByPrice: orderByPrice ?? this.orderByPrice,
      orderAsc: orderAsc ?? this.orderAsc,
      villa: villa ?? this.villa,
      flat: flat ?? this.flat,
      house: house ?? this.house,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      minRooms: minRooms ?? this.minRooms,
      maxRooms: maxRooms ?? this.maxRooms,
      selectedCities: selectedCities ?? this.selectedCities,
    );
  }

  Map<String, dynamic> toJson() {
    String cities = "";
    String ordering = "";
    String types = "";
    try {
      if (flat!) types += "flat";
      if (villa!) {
        if (types.isNotEmpty) {
          types += ',';
        }
        types += 'villa';
      }
      if (house!) {
        if (types.isNotEmpty) {
          types += ',';
        }
        types += 'house';
      }
    } catch (e) {
      print("Error while handling types ... $e");
    }
    try {
      for (int i = 0; i < selectedCities.length; i++) {
        cities += selectedCities[i];
        if (i != selectedCities.length - 1) {
          cities += ',';
        }
      }
    } catch (e) {
      print("error while handling selectedCities : $e");
    }

    if (orderByArea!) {
      if (!orderAsc!) {
        ordering += '-';
      }
      ordering += "area";
      if (orderByPrice!) {
        if (!orderAsc!) {
          ordering += ',-price';
        } else {
          ordering += ',price';
        }
      }
    } else if (orderByPrice!) {
      if (!orderAsc!) {
        ordering += '-price';
      } else {
        ordering += 'price';
      }
    }
    return <String, dynamic>{
      if ((isForRent! ^ isForSale!)) 'is_for_rent': isForRent,
      if (ordering != '') 'ordering': ordering,
      if (types != '') 'types': types,
      'min_price': minPrice,
      'max_price': maxPrice,
      'min_area': minArea,
      'max_area': maxArea,
      'min_rooms': minRooms,
      'max_rooms': maxRooms,
      if (cities != '') 'cities': cities,
    };
  }

  @override
  String toString() {
    return 'FilterOptions(isForRent: $isForRent, isForSale: $isForSale, orderByArea: $orderByArea, orderByPrice: $orderByPrice, orderAsc: $orderAsc, villa: $villa, flat: $flat, house: $house, minPrice: $minPrice, maxPrice: $maxPrice, minArea: $minArea, maxArea: $maxArea, minRooms: $minRooms, maxRooms: $maxRooms, selectedCities: $selectedCities)';
  }

  @override
  bool operator ==(covariant FilterOptions other) {
    if (identical(this, other)) return true;

    return other.isForRent == isForRent &&
        other.isForSale == isForSale &&
        other.orderByArea == orderByArea &&
        other.orderByPrice == orderByPrice &&
        other.orderAsc == orderAsc &&
        other.villa == villa &&
        other.flat == flat &&
        other.house == house &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.minArea == minArea &&
        other.maxArea == maxArea &&
        other.minRooms == minRooms &&
        other.maxRooms == maxRooms &&
        listEquals(other.selectedCities, selectedCities);
  }

  @override
  int get hashCode {
    return isForRent.hashCode ^
        isForSale.hashCode ^
        orderByArea.hashCode ^
        orderByPrice.hashCode ^
        orderAsc.hashCode ^
        villa.hashCode ^
        flat.hashCode ^
        house.hashCode ^
        minPrice.hashCode ^
        maxPrice.hashCode ^
        minArea.hashCode ^
        maxArea.hashCode ^
        minRooms.hashCode ^
        maxRooms.hashCode ^
        selectedCities.hashCode;
  }
}
