import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/modules/sales/views/sales_products_view.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class SalesCard extends StatelessWidget {
  final OrderModel order;

  const SalesCard({super.key, required this.order});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(SalesProductView(
          order: order,
        ));
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(borderRadius: borderRadius15, color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 3, spreadRadius: 3),
        ]),
        child: Column(
          children: [
            topPart(order.orderID!),
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
                        textWidget(text1: "Date order", text2: order.date!),
                        textWidget(text1: "Status", text2: order.status!),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      textWidget(text1: "Client number", text2: '+993${order.clientNumber}'),
                      textWidget(text1: "Products count", text2: order.products.toString()),
                    ],
                  ))
                ],
              ),
            )),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            bottomPart(order.sumPrice!),
          ],
        ),
      ),
    );
  }
}
