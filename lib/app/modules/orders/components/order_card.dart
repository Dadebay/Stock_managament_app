import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/modules/orders/views/ordered_products_view.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/app/product/sizes/widget_sizes.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({
    super.key,
    required this.order,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => OrderCardsProfil(order: order, docID: order.clientName));
      },
      child: Container(
        height: WidgetSizes.high2x.value,
        margin: context.padding.normal,
        decoration: BoxDecoration(
          borderRadius: borderRadius15,
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 3, spreadRadius: 3),
          ],
        ),
        child: Column(
          children: [
            topPart(order.clientName, order.status, context),
            Expanded(
                child: Padding(
              padding: context.padding.low,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        textWidget(text1: "dateOrder", text2: order.date, context: context),
                        textWidget(text1: "status", text2: order.status, context: context),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      textWidget(text1: "clientNumber", text2: '+993${order.clientNumber}', context: context),
                      textWidget(text1: "productCount", text2: order.products.toString(), context: context),
                    ],
                  ))
                ],
              ),
            )),
            Divider(
              color: kPrimaryColor2.withOpacity(.5),
              thickness: 1,
            ),
            bottomPart(order.sumPrice, context),
          ],
        ),
      ),
    );
  }

  Container bottomPart(String orderSum, BuildContext context) {
    return Container(
      width: Get.size.width,
      padding: EdgeInsets.only(bottom: 6.h, left: 10.w, right: 10.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "priceProduct".tr,
            style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey, fontWeight: FontWeight.w400),
          ),
          Text(
            orderSum,
            style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Column textWidget({required String text1, required String text2, required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text1.tr, overflow: TextOverflow.ellipsis, style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey, fontWeight: FontWeight.w400)),
        Text(text2, overflow: TextOverflow.ellipsis, style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Container topPart(String text, String status, BuildContext context) {
    return Container(
      padding: context.padding.low,
      decoration: BoxDecoration(color: ListConstants.colorMapping[status.toLowerCase()], borderRadius: borderRadius15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "order".tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              text,
              maxLines: 1,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
