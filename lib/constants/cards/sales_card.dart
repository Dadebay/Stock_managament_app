import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/sales/views/sales_products_view.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SalesCard extends StatelessWidget {
  const SalesCard({super.key, required this.date, required this.status, required this.productCount, required this.clientNumber, required this.orderSum, required this.orderID});
  final String date;
  final String status;
  final String productCount;
  final String clientNumber;
  final String orderSum;
  final String orderID;
  Column textWidget({
    required String text1,
    required String text2,
  }) {
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

  Container bottomPart() {
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

  Container topPart() {
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
            orderID,
            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: gilroySemiBold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(const SalesProductView(orderID: "#24TRHY%QD"));
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(borderRadius: borderRadius15, color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 3, spreadRadius: 3),
        ]),
        child: Column(
          children: [
            topPart(),
            Expanded(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        textWidget(text1: "Date order", text2: date),
                        textWidget(text1: "Status", text2: status),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      textWidget(text1: "Client number", text2: '+993$clientNumber'),
                      textWidget(text1: "Products count", text2: productCount),
                    ],
                  ))
                ],
              ),
            )),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            bottomPart(),
          ],
        ),
      ),
    );
  }
}
