import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';

SnackbarController showSnackBar(String title, String subtitle, Color color) {
  if (SnackbarController.isSnackbarBeingShown) {
    SnackbarController.cancelAllSnackbars();
  }
  return Get.snackbar(
    title,
    subtitle,
    snackStyle: SnackStyle.FLOATING,
    titleText: title == ''
        ? const SizedBox.shrink()
        : Text(
            title.tr,
            style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 18, color: Colors.white),
          ),
    messageText: Text(
      subtitle.tr,
      style: const TextStyle(fontFamily: gilroyRegular, fontSize: 16, color: Colors.white),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: color,
    borderRadius: 20.0,
    duration: const Duration(milliseconds: 800),
    margin: const EdgeInsets.all(8),
  );
}

Center spinKit() {
  return Center(
    child: Lottie.asset(loadingLottie, width: 70.w, height: 70.h),
  );
}

Center errorData() {
  return const Center(
    child: Text("Error data"),
  );
}

Center emptyData() {
  return Center(
      child: Text(
    "noProduct".tr,
    style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 20.sp),
  ));
}

CustomFooter customFooter() {
  return CustomFooter(
    builder: (BuildContext context, LoadStatus? mode) {
      Widget body;
      if (mode == LoadStatus.idle) {
        body = const Text('Garaşyň...');
      } else if (mode == LoadStatus.loading) {
        body = const CircularProgressIndicator(color: kPrimaryColor2);
      } else if (mode == LoadStatus.failed) {
        body = const Text('Load Failed!Click retry!');
      } else if (mode == LoadStatus.canLoading) {
        body = const Text('');
      } else {
        body = const Text('No more Data');
      }
      return SizedBox(
        height: 55.0,
        child: Center(child: body),
      );
    },
  );
}

Expanded textWidgetHomeVIew(String totalProducts, String text) {
  return Expanded(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey, fontFamily: gilroySemiBold, fontSize: 16.sp),
      ),
      Text(
        totalProducts,
        style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 30.sp),
      ),
    ],
  ));
}

Container bottomPart(String orderSum) {
  return Container(
    width: Get.size.width,
    padding: EdgeInsets.only(bottom: 6.h, left: 10.w, right: 10.2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "priceProduct".tr,
          style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: gilroySemiBold),
        ),
        Text(
          orderSum,
          style: TextStyle(color: Colors.black, fontSize: 14.sp, fontFamily: gilroyBold),
        ),
      ],
    ),
  );
}

Container topPart(String text, String status) {
  Map<String, Color> colorMapping = {"shipped": Colors.green, "canceled": Colors.red, "refund": Colors.red, "preparing": kPrimaryColor2, "ready to ship": Colors.purple};
  return Container(
    width: Get.size.width,
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
    decoration: BoxDecoration(
        color: colorMapping[status.toLowerCase()],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${"order".tr} ID",
          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: gilroySemiBold),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: gilroySemiBold),
        ),
      ],
    ),
  );
}

Column textWidget({required String text1, required String text2}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text1.tr,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14.sp),
      ),
      Text(
        text2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey, fontFamily: gilroyMedium, fontSize: 14.sp),
      )
    ],
  );
}

Widget textWidgetOrderedPage(
    {required bool ontap, required String status, required BuildContext context, required String text1, required String text2, required String labelName, required OrderModel order}) {
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  textEditingController.text = text2;
  Map<String, bool> statusMapping = {"Shipped": false, "Canceled": false, "Refund": false, "Preparing": true, "Ready to ship": true};

  return GestureDetector(
    onTap: () {
      if (ontap) {
        if (statusMapping[status] == true) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                alignment: Alignment.center,
                title: Text(text1.tr, textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 20.sp)),
                backgroundColor: Colors.white,
                shadowColor: Colors.red,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CustomTextField(labelName: text1.toString(), controller: textEditingController, focusNode: focusNode, requestfocusNode: focusNode, unFocus: false, readOnly: true)],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: <Widget>[
                  TextButton(
                    child: Text('no'.tr, style: TextStyle(fontFamily: gilroyMedium, fontSize: 18.sp)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('yes'.tr, style: TextStyle(fontFamily: gilroyBold, fontSize: 18.sp)),
                    onPressed: () {
                      if (text1 == 'discount') {
                        double sumPrice = double.parse(order.sumPrice.toString());
                        double discount = textEditingController.text.isEmpty ? 0.0 : double.parse(textEditingController.text.toString());
                        if (sumPrice == discount) {
                          showSnackBar('errorTitle', 'notHigherThanSumPrice', Colors.red);
                        } else if (discount > sumPrice) {
                          showSnackBar('errorTitle', 'notHigherThanSumPrice', Colors.red);
                        } else {
                          FirebaseFirestore.instance
                              .collection('sales')
                              .doc(order.orderID)
                              .update({labelName: textEditingController.text, 'sum_price': double.parse(order.sumPrice!.toString()) - discount}).then((value) {
                            showSnackBar("copySucces", "changesUpdated", Colors.green);
                          });
                          Navigator.of(context).pop();
                        }
                      } else {
                        FirebaseFirestore.instance.collection('sales').doc(order.orderID).update({
                          labelName: textEditingController.text,
                        }).then((value) {
                          showSnackBar("copySucces", "changesUpdated", Colors.green);
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          );
        } else {
          showSnackBar("errorTitle", "cannotChangeOrderStatus", Colors.red);
        }
      }
    },
    child: Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text1.tr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontFamily: gilroyMedium, fontSize: 14.sp),
                ),
                Text(
                  text1 == "clientNumber"
                      ? "+993 $text2"
                      : text1 == "priceProduct"
                          ? text2
                          : text1 == "discount" || text1 == "Coupon"
                              ? text2
                              : text2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14.sp),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.grey.shade200,
          )
        ],
      ),
    ),
  );
}

CachedNetworkImage imageView({required String imageURl}) {
  return CachedNetworkImage(
    fadeInCurve: Curves.ease,
    imageUrl: imageURl,
    useOldImageOnUrlChange: true,
    imageBuilder: (context, imageProvider) => Container(
      width: Get.size.width,
      decoration: BoxDecoration(
        borderRadius: borderRadius15,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    placeholder: (context, url) => spinKit(),
    errorWidget: (context, url, error) => Center(
      child: Text('noImage'.tr),
    ),
  );
}

Text filterTextWidget(String name) {
  return Text(
    name,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.black,
      fontFamily: gilroySemiBold,
      fontSize: 22.sp,
    ),
  );
}
