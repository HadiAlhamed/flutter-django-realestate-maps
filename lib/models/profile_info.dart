// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:intl/intl.dart';

class ProfileInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String gender;
  final String profilePhoto;
  final DateTime birthDate;
  final String country;
  final String phoneNumber;
  final int points;
  final bool isSeller;
  ProfileInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.profilePhoto,
    required this.birthDate,
    required this.country,
    required this.phoneNumber,
    required this.points,
    required this.isSeller,
  });

  ProfileInfo copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? gender,
    String? profilePhoto,
    DateTime? birthData,
    String? country,
    String? phoneNumber,
    int? points,
    bool? isSeller,
  }) {
    return ProfileInfo(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      birthDate: birthData ?? birthDate,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      points: points ?? this.points,
      isSeller: isSeller ?? this.isSeller,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'photo': profilePhoto,
      'birth_date': DateFormat('yyyy-MM-dd').format(birthDate),
      'country': country,
      'phone_number': phoneNumber,
      'points': points,
      'is_seller': isSeller,
    };
  }

  factory ProfileInfo.fromJson(Map<String, dynamic> map) {
    return ProfileInfo(
      id: map['id'] as int,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      gender: map['gender'] as String,
      profilePhoto: map['photo'] as String,
      birthDate: DateTime.parse(map['birth_date'] as String),
      country: map['country'] as String,
      phoneNumber: map['phone_number'] as String,
      points: map['points'],
      isSeller: map['is_seller'] as bool,
    );
  }

  @override
  String toString() {
    return 'ProfileInfo(id: $id, firstName: $firstName, lastName: $lastName, gender: $gender, profilePhoto: $profilePhoto, birthData: ${DateFormat('yyyy-MM-dd').format(birthDate)}, country: $country, phoneNumber: $phoneNumber, points: $points, isSeller: $isSeller)';
  }

  @override
  bool operator ==(covariant ProfileInfo other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.gender == gender &&
        other.profilePhoto == profilePhoto &&
        other.birthDate == birthDate &&
        other.country == country &&
        other.phoneNumber == phoneNumber &&
        other.points == points &&
        other.isSeller == isSeller;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        gender.hashCode ^
        profilePhoto.hashCode ^
        birthDate.hashCode ^
        country.hashCode ^
        phoneNumber.hashCode ^
        points.hashCode ^
        isSeller.hashCode;
  }
}
