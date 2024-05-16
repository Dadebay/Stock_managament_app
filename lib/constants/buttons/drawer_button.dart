import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';

class DrawerButtonMine extends StatelessWidget {
  DrawerButtonMine({
    super.key,
    required this.onTap,
    required this.index,
    required this.selectedIndex,
    required this.showIconOnly,
  });
  final bool showIconOnly;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  List icons = [
    IconlyLight.category,
    IconlyLight.plus,
    IconlyLight.search,
    IconlyLight.setting,
    IconlyLight.infoSquare,
  ];
  List titles = [
    'home',
    'add_product_page',
    'search',
    'settings',
    'contactInformation',
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(12),
        width: Get.size.width,
        child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: borderRadius10),
                foregroundColor: Colors.white,
                backgroundColor: selectedIndex == index ? Colors.amber : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10)),
            child: showIconOnly
                ? Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Icon(
                      icons[index],
                      color: selectedIndex == index ? Colors.black : Colors.white,
                    ),
                  )
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Icon(
                          icons[index],
                          color: selectedIndex == index ? Colors.black : Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          child: Text(
                            "${titles[index]}".tr,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: selectedIndex == index ? Colors.black : Colors.white, fontFamily: selectedIndex == index ? gilroyBold : gilroyRegular, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  )));
  }
}
