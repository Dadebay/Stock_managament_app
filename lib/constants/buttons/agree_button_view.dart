// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';

import '../../app/modules/home/controllers/home_controller.dart';

class AgreeButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final bool? showBorder;

  AgreeButton({super.key, required this.onTap, required this.text, this.showBorder});
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: animatedContaner(context));
  }

  Widget animatedContaner(BuildContext context) {
    return Obx(() {
      return AnimatedContainer(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: showBorder == true ? Colors.transparent : kPrimaryColor2, border: Border.all(color: kPrimaryColor2)),
        margin: context.padding.onlyTopNormal,
        padding: context.padding.normal.copyWith(top: 15, bottom: 15),
        width: homeController.agreeButton.value ? 60.w : Get.size.width,
        duration: const Duration(milliseconds: 800),
        alignment: Alignment.center,
        child: homeController.agreeButton.value
            ? SizedBox(
                width: 34.w,
                height: 25.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Text(
                text.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp, color: showBorder == true ? kPrimaryColor2 : Colors.white),
              ),
      );
    });
  }
}
