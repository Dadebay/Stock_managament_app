import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/app/product/constants/icon_constants.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/app/product/sizes/widget_sizes.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

import '../../../constants/buttons/agree_button_view.dart';

class DialogUtils {
  static Future<dynamic> appBarOrderFilter() {
    final SalesController salesController = Get.put(SalesController());

    return Get.bottomSheet(Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Wrap(
        children: [
          filterTextWidget('filter'.tr),
          ListView.builder(
            itemCount: salesController.statuses.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  salesController.sortSalesCards(index);
                },
                title: Text(salesController.statuses[index]),
                trailing: const Icon(IconlyLight.arrowRightCircle),
              );
            },
          ),
        ],
      ),
    ));
  }

  static Future<dynamic> filter(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: context.padding.normal,
              child: Text(
                'filter'.tr,
                style: context.general.textTheme.titleLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ListConstants.filters.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      _miniBottomSheet(index, homeController, context);
                    },
                    title: Text(ListConstants.filters[index]['name'].toString(), maxLines: 1, style: context.general.textTheme.titleMedium!.copyWith(fontSize: 20)),
                    trailing: Icon(IconlyLight.arrowRightCircle, size: WidgetSizes.mini2x.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<dynamic> _miniBottomSheet(int index, HomeController homeController, BuildContext context) {
    return Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: context.padding.normal,
              child: Text(
                ListConstants.filters[index]['name'],
                style: context.general.textTheme.titleLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection(ListConstants.filters[index]['name'].toLowerCase()).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int indexx) {
                        return ListTile(
                          onTap: () {
                            homeController.filterProducts(
                              ListConstants.filters[index]['searchName'],
                              snapshot.data!.docs[indexx]['name'],
                            );
                            Get.back();
                            Get.back();
                          },
                          title: Text(
                            snapshot.data!.docs[indexx]['name'],
                            maxLines: 1,
                            style: context.general.textTheme.titleLarge!.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: spinKit());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showNoConnectionDialog({required VoidCallback onRetry, required BuildContext context}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: context.border.normalBorderRadius),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              padding: context.padding.onlyTopNormal,
              child: Container(
                padding: const EdgeInsets.only(top: 100, left: 15, right: 15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: context.border.normalBorderRadius),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'noConnection1'.tr,
                      style: context.general.textTheme.bodyLarge,
                    ),
                    Padding(
                      padding: context.padding.normal,
                      child: Text(
                        'noConnection2'.tr,
                        textAlign: TextAlign.center,
                        style: context.general.textTheme.bodyMedium,
                      ),
                    ),
                    AgreeButton(
                      onTap: () {},
                      text: 'noConnection3'.tr,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                maxRadius: WidgetSizes.small.value,
                child: ClipOval(
                  child: Image.asset(IconConstants.noConnection, fit: BoxFit.fill),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
