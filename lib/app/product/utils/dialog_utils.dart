import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/four_in_one_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/product/constants/icon_constants.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/app/product/sizes/widget_sizes.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

import '../../../constants/buttons/agree_button_view.dart';

class DialogUtils {
  void showSelectableDialog({
    required BuildContext context,
    required String title,
    required String url,
    required TextEditingController targetController,
    required void Function(String id) onIdSelected,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(color: Colors.black, fontSize: 22.sp, fontWeight: FontWeight.bold),
      titlePadding: const EdgeInsets.only(top: 20),
      content: Container(
        height: Get.size.height / 2,
        width: Get.size.width,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        child: FutureBuilder<List<FourInOneModel>>(
          future: FourInOnePageService().getData(url: url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return spinKit();
            } else if (snapshot.hasError) {
              return errorData();
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return emptyData();
            }

            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  minVerticalPadding: 10.h,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  title: Text(
                    item.name,
                    style: TextStyle(color: Colors.black, fontSize: 18.sp),
                  ),
                  trailing: const Icon(IconlyLight.arrowRightCircle),
                  onTap: () {
                    targetController.text = item.name;
                    onIdSelected(item.id.toString());
                    Get.back();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  static orderFilterDialog() {
    List nameMapping = ['Preparing', 'Shipped', 'Cancelled', 'Refund', 'Ready to ship'];
    List numberMapping = [1, 2, 3, 4, 5];
    final OrderController orderViewController = Get.find();
    return Get.defaultDialog(
        title: 'Filter by status',
        titleStyle: TextStyle(color: Colors.black, fontSize: 24.sp, fontWeight: FontWeight.bold),
        titlePadding: const EdgeInsets.only(top: 20),
        content: Container(
          width: Get.size.width,
          height: Get.size.height / 2,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: nameMapping.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        orderViewController.filterByStatus(numberMapping[index].toString());
                        Get.back();
                      },
                      minVerticalPadding: 10.h,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      title: Text(
                        nameMapping[index].toString(),
                        style: TextStyle(color: const Color.fromARGB(255, 115, 109, 109), fontSize: 18.sp, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(IconlyLight.arrowRightCircle),
                    );
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    orderViewController.clearFilter();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                  child: Text(
                    "Clear Filter",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        ));
  }

  static filterDialogSearchView(BuildContext context) {
    final SearchViewController searchViewController = Get.find();

    return Get.bottomSheet(Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: Get.size.height / 2,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Column(
        children: [
          Text(
            'filter'.tr,
            style: context.general.textTheme.titleLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ListConstants.searchViewFilters.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: () => filterHelper(index: index, context: context),
                  minVerticalPadding: 10.h,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  title: Text(
                    ListConstants.searchViewFilters[index]['name'].toString(),
                    style: context.general.textTheme.titleMedium!.copyWith(fontSize: 20),
                  ),
                  trailing: const Icon(IconlyLight.arrowRightCircle),
                );
              },
            ),
          ),
          ElevatedButton(
              onPressed: () {
                searchViewController.clearFilter();
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
              child: Text(
                "Clear Filter",
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ))
        ],
      ),
    ));
  }

  static filterHelper({required int index, required BuildContext context}) {
    final SearchViewController searchViewController = Get.find();
    final String filterTypeForController = ListConstants.searchViewFilters[index]['searchName'].toString();
    final String dialogTitle = ListConstants.searchViewFilters[index]['name'].toString();
    Get.bottomSheet(Container(
        height: Get.size.height / 1.8,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              "${"Select".tr} ${dialogTitle.tr}",
              style: context.general.textTheme.titleLarge!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<FourInOneModel>>(
                future: FourInOnePageService().getData(url: ListConstants.four_in_one_names[index]['url'].toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return spinKit();
                  } else if (snapshot.hasError) {
                    return errorData();
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return emptyData();
                  }
                  final filterValues = snapshot.data!;

                  return ListView.builder(
                    itemCount: filterValues.length,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      return ListTile(
                        minVerticalPadding: 10.h,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onTap: () {
                          searchViewController.applyFilter(filterTypeForController, filterValues[i].name);
                          Get.back();
                          Get.back();
                        },
                        trailing: const Icon(IconlyLight.arrowRightCircle),
                        title: Text(
                          filterValues[i].name,
                          style: context.general.textTheme.titleMedium!.copyWith(fontSize: 20),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        )));
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
                      onTap: onRetry,
                      text: 'noConnection3'.tr,
                    ),
                    SizedBox(height: WidgetSizes.normal.value),
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
