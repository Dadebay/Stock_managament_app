import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/product/views/product_profil_view.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, required this.orderView, required this.addCounterWidget});

  final bool addCounterWidget;
  final bool orderView;
  final ProductModel product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final SalesController salesController = Get.put(SalesController());
  int selectedCount = 0;

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

    return widget.addCounterWidget ? counterWidget() : noCounterWidget();
  }

  Card counterWidget() {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
      elevation: 0.5,
      child: ListTile(
        title: Text(
          widget.product.name!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 15.sp),
        ),
        dense: true,
        visualDensity: const VisualDensity(vertical: 3),
        contentPadding: EdgeInsets.only(left: 10.w),
        leading: SizedBox(width: 70, height: 70, child: imageView(imageURl: widget.product.image!)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.sellPrice!,
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
                  salesController.decreaseCount(widget.product.documentID.toString(), selectedCount);
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
                print(widget.product.quantity);
                if (selectedCount >= widget.product.quantity!) {
                  showSnackBar("Error", "Not in stock", Colors.red);
                } else {
                  selectedCount++;
                  salesController.upgradeCount(widget.product.documentID.toString(), selectedCount);
                  salesController.addProductMain(product: widget.product, count: selectedCount);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector noCounterWidget() {
    return GestureDetector(
      onTap: () {
        Get.find<HomeController>().agreeButton.value = false;
        if (!widget.orderView) Get.to(() => ProductProfilView(product: widget.product));
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
                width: 65.w,
                height: 60.h,
                margin: EdgeInsets.only(right: 15.w),
                decoration: BoxDecoration(borderRadius: borderRadius15, color: Colors.grey.shade200),
                child: imageView(imageURl: widget.product.image!)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 16.sp),
                  ),
                  Text(
                    "${"quantity".tr}: ${widget.product.quantity}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                  ),
                  Text(
                    "${"price".tr} ${widget.product.sellPrice}",
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
