import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/property_details_controller.dart';
import 'package:real_estate/models/property.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/textstyles/text_styles.dart';
import 'package:real_estate/widgets/my_snackbar.dart';

class PropertyCard extends StatelessWidget {
  final bool? favorite;
  final Property property;
  final PropertyDetailsController? pdController;
  final dynamic scaleController;
  final void Function()? onTap;
  final int index;
  const PropertyCard({
    super.key,
    this.favorite,
    this.pdController,
    required this.property,
    this.onTap,
    required this.scaleController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            Get.toNamed('/propertyDetails',
                arguments: {'propertyId': property.id!});
          },
      onTapDown: (_) {
        print("on tap down...");
        scaleController.changeCardScale(index, property.id!, 0.95);
        print("current scale : ${scaleController.cardAnimationScale[index]}");
      },
      onTapUp: (_) {
        print("on tap up...");

        scaleController.changeCardScale(index, property.id!, 1.0);
        onTap?.call();
      },
      onTapCancel: () =>
          scaleController.changeCardScale(index, property.id!, 1.0),
      child: Card(
        // color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Image.asset(
                "assets/images/house.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${property.price.toString()} \$",
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${property.propertyType} located in ${property.city}",
                    style: h4TitleStyleGrey.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoIconText(Icons.aspect_ratio_outlined,
                          property.area.toStringAsFixed(0)),
                      infoIconText(Icons.bed_outlined,
                          property.numberOfRooms.toString()),
                      infoIconText(Icons.bathtub_outlined,
                          property.bathrooms.toString()),
                      if (favorite != null)
                        IconButton(
                          onPressed: () async {
                            bool result = pdController!.isFavorite[property.id!]
                                ? await PropertiesApis.cancelFavorite(
                                    propertyId: property.id!)
                                : await PropertiesApis.addFavorite(
                                    propertyId: property.id!);
                            if (result) {
                              pdController?.flipIsFavorite(
                                propertyId: property.id!,
                              );
                            } else {
                              Get.showSnackbar(MySnackbar(
                                  success: false,
                                  title: "Favorite",
                                  message:
                                      "Failed to update Favorite,please try again later"));
                            }
                          },
                          icon: Icon(Icons.favorite,
                              color: favorite! ? primaryColor : Colors.grey),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: h4TitleStyleGrey.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
