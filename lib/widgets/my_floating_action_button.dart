import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/account_page_controller.dart';

class MyFloatingActionButton extends StatelessWidget {
  const MyFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountPageController>(
        id: "sellerMode",
        builder: (controller) {
          return FloatingActionButton(
            backgroundColor: !controller.isSeller ? Colors.grey : null,
            onPressed: !controller.isSeller
                ? null
                : () {
                    Get.offNamed('/addPropertyPage', arguments: {
                      "isAdd": true,
                    });
                  },
            child: Icon(
              Icons.add,
              color: !controller.isSeller ? Colors.grey[300] : null,
            ),
          );
        });
  }
}
