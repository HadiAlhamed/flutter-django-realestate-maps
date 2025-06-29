import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_estate/models/facility.dart';
import 'package:real_estate/models/filter_options.dart';
import 'package:real_estate/models/paginated_property.dart';
import 'package:real_estate/models/property.dart';
import 'package:real_estate/models/property_details.dart';
import 'package:real_estate/models/property_image.dart';
import 'package:real_estate/services/api.dart';
import 'package:real_estate/services/auth_services/auth_interceptor.dart';

class PropertiesApis {
  static final Dio _dio = Dio();
  static Future<void> init() async {
    _dio.interceptors.add(AuthInterceptor(_dio));
  }

  static Future<Property?> addProperty({required Property property}) async {
    print("trying to add a property...");
    print(property);
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/properties/add/",
        data: property.toJson(),
      );
      print("HI");
      if (response.statusCode == 201) {
        print("property added Successfully...");
        final Map<String, dynamic> data = response.data;
        final Property pro = Property.fromJson(data);
        return pro;
      } else {
        print(response.statusMessage);
        return null;
      }
    } catch (e) {
      print("Network Error : $e");
      return null;
    }
  }

  static Future<Property?> updateProperty({required Property property}) async {
    print("trying to update a property...");
    print(property);
    try {
      final response = await _dio.patch(
        "${Api.baseUrl}/properties/${property.id!}/edit/",
        data: property.toJson(),
      );
      print("HI");
      if (response.statusCode == 200) {
        print("property added Successfully...");
        final Map<String, dynamic> data = response.data;
        final Property pro = Property.fromJson(data);
        return pro;
      } else {
        print(response.statusMessage);
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Exception : ${e.response?.data}");
      }
      else {
        print("Network Error : $e");
      }
    }
    return null;
  }

  static Future<PropertyImage?> addImageToProperty(
      {required int propertyId, required XFile image}) async {
    print("trying to add a property image ...");
    try {
      // Read image bytes
      final bytes = await image.readAsBytes();

      // Prepare MultipartFile from bytes
      final multipartImage = MultipartFile.fromBytes(
        bytes,
        filename: image.name,
      );

      // Create FormData
      final formData = FormData.fromMap({
        'image': multipartImage, // Make sure this key matches your backend
        'propertyId': propertyId, // optional extra fields
      });

      final response = await _dio.post(
        "${Api.baseUrl}/properties/$propertyId/images/add/",
        data: formData,
      );
      if (response.statusCode == 201) {
        print("property image added Successfully...");
        final Map<String, dynamic> data = response.data;
        final PropertyImage proImage = PropertyImage.fromJson(data);
        return proImage;
      } else {
        print(response.statusMessage);
        return null;
      }
    } catch (e) {
      print("Network Error : $e");
      return null;
    }
  }

  static Future<Facility?> addFacilityToProperty(
      {required int propertyId, required int facilityId}) async {
    print("trying to add a property facility ...");
    print('facility_id: $facilityId (${facilityId.runtimeType})');

    try {
      final response = await _dio.post(
        "${Api.baseUrl}/properties/$propertyId/facilities/add/",
        data: {
          'property_id': propertyId,
          'facility_id': facilityId,
        },
      );
      print(
          "response for adding facility : ${response.data} ${response.statusMessage}");
      if (response.statusCode == 201) {
        print("property Facility added Successfully...");
        final Map<String, dynamic> data = response.data;
        final Facility facility = Facility.fromJson(data);
        return facility;
      } else {
        print(response.statusMessage);
        return null;
      }
    } catch (e) {
      if (e is DioException) {
        print('Error: ${e.response?.data}');
      }
      print("Network Error : $e");
      return null;
    }
  }

  static Future<PaginatedProperty> getProperties(
      {String? url, FilterOptions? filterOptions}) async {
    print("trying to get property page : $url");
    try {
      final response = await _dio.get(
        url ?? "${Api.baseUrl}/properties/",
        queryParameters: filterOptions == null ? {} : filterOptions.toJson(),
      );
      if (response.statusCode == 200) {
        print("Retrived successfully");
        Map<String, dynamic> data = response.data;
        List<Property> properties = (data['results'] as List).map((property) {
          return Property.fromJson(property);
        }).toList();
        return PaginatedProperty(
            nextPageUrl: data['next'] as String?, properties: properties);
      } else {
        print(response.statusMessage);
        return PaginatedProperty(nextPageUrl: null, properties: []);
      }
    } catch (e) {
      print("Network Error : $e");
      return PaginatedProperty(nextPageUrl: null, properties: []);
    }
  }

  static Future<PropertyDetails?> getPropertyDetails(
      {required int propertyId}) async {
    try {
      final response =
          await _dio.get('${Api.baseUrl}/properties/$propertyId/', data: {
        'property_id': propertyId,
      });
      print(response.statusMessage);
      if (response.statusCode == 200) {
        return PropertyDetails.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Network Error : $e");

      return null;
    }
  }

  static Future<bool> addFavorite({required int propertyId}) async {
    print("trying to get property $propertyId to favorites...");
    try {
      final response = await _dio.post(
        "${Api.baseUrl}/properties/$propertyId/favorite/",
      );
      if (response.statusCode == 200) {
        return true;
      }
      print(response.statusMessage);
    } catch (e) {
      if (e is DioException) {
        print('Error: ${e.response?.data}');
      } else {
        print("Network Error : $e");
      }
    }
    return false;
  }

  static Future<bool> cancelFavorite({required int propertyId}) async {
    print("trying to delete property $propertyId from favorites...");
    try {
      final response = await _dio.delete(
        "${Api.baseUrl}/properties/$propertyId/unfavorite/",
      );
      if (response.statusCode == 200) {
        return true;
      }
      print(response.statusMessage);
    } catch (e) {
      if (e is DioException) {
        print('Error: ${e.response?.data}');
      } else {
        print("Network Error : $e");
      }
    }
    return false;
  }

  static Future<PaginatedProperty> getFavorites(
      {String? url, FilterOptions? filterOptions}) async {
    print("trying to get favorites property page : $url");
    try {
      final response = await _dio.get(
        url ?? "${Api.baseUrl}/properties/favorites/",
        queryParameters: filterOptions == null ? {} : filterOptions.toJson(),
      );
      if (response.statusCode == 200) {
        print("Retrived successfully");
        Map<String, dynamic> data = response.data;
        List<Property> properties = (data['results'] as List).map((property) {
          return Property.fromJson(property);
        }).toList();
        return PaginatedProperty(
            nextPageUrl: data['next'] as String?, properties: properties);
      } else {
        print(response.statusMessage);
      }
    } catch (e) {
      print("Network Error : $e");
    }
    return PaginatedProperty(nextPageUrl: null, properties: []);
  }
}
