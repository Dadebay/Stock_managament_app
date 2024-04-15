import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/constants/constants.dart';

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
    animationDuration: const Duration(seconds: 2),
    margin: const EdgeInsets.all(8),
  );
}

Center spinKit() {
  return const Center(
    child: CircularProgressIndicator(
      color: kPrimaryColor,
    ),
  );
}

Center errorData() {
  return const Center(
    child: Text("Error data"),
  );
}

Center emptyData() {
  return const Center(child: Text("Empty Data"));
}

Expanded homePageTopWidget({required String stockInHand, required String totalProducts}) {
  return Expanded(
    flex: 1,
    child: Row(
      children: [
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'totalProducts'.tr,
              style: TextStyle(color: Colors.grey, fontFamily: gilroySemiBold, fontSize: 16.sp),
            ),
            Text(
              totalProducts,
              style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 30.sp),
            ),
          ],
        )),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'stockInHand'.tr,
              style: TextStyle(color: Colors.grey, fontFamily: gilroySemiBold, fontSize: 16.sp),
            ),
            Text(
              stockInHand,
              style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 30.sp),
            ),
          ],
        )),
      ],
    ),
  );
}

Container bottomPart(String orderSum) {
  return Container(
    width: Get.size.width,
    padding: EdgeInsets.only(bottom: 6.h, left: 10.w, right: 10.2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Order sum:",
          style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: gilroySemiBold),
        ),
        Text(
          "$orderSum TMT",
          style: TextStyle(color: Colors.black, fontSize: 14.sp, fontFamily: gilroyBold),
        ),
      ],
    ),
  );
}

Container topPart(String text) {
  return Container(
    width: Get.size.width,
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
    decoration: const BoxDecoration(
        color: kPrimaryColor2,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Order ID",
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
        text1,
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
    errorWidget: (context, url, error) => const Center(
      child: Text('No Image'),
    ),
  );
}
