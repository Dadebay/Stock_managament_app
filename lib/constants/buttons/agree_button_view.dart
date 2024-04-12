// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/constants/constants.dart';

class AgreeButton extends StatelessWidget {
  final Function() onTap;
  final String text;

  const AgreeButton({
    required this.onTap,
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: animatedContaner());
  }

  Widget animatedContaner() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: borderRadius20,
        color: kPrimaryColor2,
      ),
      margin: EdgeInsets.only(top: 14.h),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: Get.size.width,
      child: Text(
        text.tr,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 22),
      ),
    );
  }
}
