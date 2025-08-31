import 'package:real_estate/models/properties/property.dart';

class PaginatedProperty {
  final String? nextPageUrl;
  final List<Property> properties;

  PaginatedProperty({
    required this.nextPageUrl,
    required this.properties,
  });
}
