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
