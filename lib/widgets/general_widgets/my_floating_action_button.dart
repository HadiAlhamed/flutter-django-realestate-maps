import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/main_controllers/account_page_controller.dart';
import 'package:real_estate/textstyles/text_colors.dart';

class MyFloatingActionButton extends StatelessWidget {
  const MyFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountPageController>(
      id: "sellerMode",
      builder: (controller) {
        final isSeller = controller.isSeller;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            // We wrap the FAB inside a container that animates color,
            // but to keep shadow and shape like FAB, use Material with shape
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15),
            color: isSeller
                ? Theme.of(context).brightness == Brightness.dark
                    ? primaryColor
                    : primaryColorInactive
                : Colors.grey,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.3 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor:
                Colors.transparent, // transparent, color handled by container
            elevation: 0,
            onPressed: isSeller
                ? () {
                    Get.offNamed('/addPropertyPage', arguments: {
                      "isAdd": true,
                    });
                  }
                : null,
            child: Icon(
              Icons.add,
              color: isSeller
                  ? Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white
                  : Colors.grey[300],
            ),
          ),
        );
      },
    );
  }
}
