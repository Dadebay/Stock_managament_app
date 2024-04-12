import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/constants/cards/sales_card.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../controllers/sales_controller.dart';

class SalesProductView extends StatelessWidget {
  const SalesProductView({super.key, required this.orderID});
  final String orderID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order   $orderID'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              IconlyLight.arrowLeftCircle,
              color: Colors.black,
            )),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        children: [
          textWidget(text1: 'Status', text2: 'Delivered'),
          textWidget(text1: 'Date order', text2: '26.04.2024 - 16:45'),
          textWidget(text1: 'Client number', text2: '+993 62990344'),
          textWidget(text1: 'Product count', text2: '7 '),
        ],
      ),
    );
  }

  Widget textWidget({
    required String text1,
    required String text2,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontFamily: gilroyMedium, fontSize: 14.sp),
              ),
              Text(
                text2,
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
    );
  }
}
