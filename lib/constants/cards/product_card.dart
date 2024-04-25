import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/views/product_profil_view.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool orderView;
  final bool addCounterWidget;
  const ProductCard({super.key, required this.product, required this.orderView, required this.addCounterWidget});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int selectedCount = 0;

  final SalesController salesController = Get.put(SalesController());

  changeData() {
    for (var element in salesController.selectedProductsList) {
      final ProductModel data = element['product'];
      if (widget.product.documentID == data.documentID) {
        selectedCount = element['count'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    changeData();

    return widget.addCounterWidget
        ? Card(
            shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
            elevation: 0.5,
            child: ListTile(
              title: Text(
                widget.product.name!,
                maxLines: 2,
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
              ),
              dense: true,
              visualDensity: const VisualDensity(vertical: 3),
              contentPadding: EdgeInsets.only(left: 10.w),
              leading: SizedBox(width: 70, height: 70, child: imageView(imageURl: widget.product.image!)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.product.sellPrice!} TMT',
                    style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                  ),
                  Text(
                    'Count : ${widget.product.quantity!}',
                    style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.minus_circle, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        if (selectedCount > 0) {
                          selectedCount--;
                        }
                        salesController.decreaseCount(int.parse(widget.product.documentID.toString()), selectedCount);
                      });
                    },
                  ),
                  Text(
                    selectedCount.toString(),
                    style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 18.sp),
                    maxLines: 1,
                  ), // Yeni: Sayıcıyı göster
                  IconButton(
                    icon: const Icon(CupertinoIcons.add_circled, color: Colors.black),
                    onPressed: () {
                      if (selectedCount >= widget.product.quantity!) {
                        showSnackBar("Error", "We dont have to much item ", Colors.red);
                      } else {
                        selectedCount++;
                        salesController.upgradeCount(int.parse(widget.product.documentID.toString()), selectedCount);
                        salesController.addProductMain(product: widget.product, count: selectedCount);
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              if (!widget.orderView) Get.to(() => ProductProfilView(product: widget.product));
            },
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(top: 10.h),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Container(
                      width: 70,
                      height: 70,
                      margin: EdgeInsets.only(right: 15.w),
                      decoration: BoxDecoration(color: Colors.grey.shade200, boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 3, blurRadius: 3)], borderRadius: borderRadius15),
                      child: imageView(imageURl: widget.product.image!)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 16.sp),
                        ),
                        Text(
                          "${"quantity".tr}: ${widget.product.quantity}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                        ),
                        Text(
                          "${"price".tr} ${widget.product.sellPrice} TMT",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  widget.orderView ? const SizedBox.shrink() : const Icon(IconlyLight.arrowRightCircle)
                ],
              ),
            ),
          );
  }
}
