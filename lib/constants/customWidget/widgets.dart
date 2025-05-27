import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/product/constants/icon_constants.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';

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
            style: const TextStyle(fontSize: 18, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, color: Colors.white),
          ),
    messageText: Text(
      subtitle.tr,
      style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: color,
    borderRadius: 20.0,
    duration: const Duration(milliseconds: 1000),
    margin: const EdgeInsets.all(8),
  );
}

Future<DateTime?> showDateTimePickerWidget({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  final TimeOfDay? selectedTime = await showTimePicker(
    // ignore: use_build_context_synchronously
    context: context,
    initialTime: TimeOfDay.fromDateTime(selectedDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}

Center spinKit() {
  return Center(
    child: Lottie.asset(IconConstants.loadingLottie, width: 70.w, height: 70.h),
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
    style: TextStyle(color: Colors.black, fontSize: 20.sp),
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
      child: Text('noImage'.tr, textAlign: TextAlign.center),
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
      fontSize: 22.sp,
    ),
  );
}
