import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/app/modules/product/views/product_profil_view.dart';
import 'package:stock_managament_app/app/product/sizes/widget_sizes.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
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
  final HomeController homeController = Get.find<HomeController>();
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

  Widget counterWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        borderRadius: borderRadius20,
        border: Border.all(color: kPrimaryColor1.withOpacity(0.4)),
      ),
      child: ListTile(
        title: Text(
          widget.product.name!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
              style: TextStyle(color: Colors.black, fontSize: 18.sp),
              maxLines: 1,
            ), // Yeni: Sayıcıyı göster
            IconButton(
              icon: const Icon(CupertinoIcons.add_circled, color: Colors.black),
              onPressed: () {
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
        homeController.agreeButton.value = false;
        if (!widget.orderView) Get.to(() => ProductProfilView(product: widget.product));
      },
      child: Container(
        color: Colors.white,
        padding: context.padding.verticalNormal,
        child: Row(
          children: [
            Container(
                width: WidgetSizes.normal2x.value,
                height: WidgetSizes.normal2x.value,
                margin: context.padding.onlyRightNormal,
                decoration: BoxDecoration(borderRadius: borderRadius15, color: Colors.grey.shade200, border: Border.all(color: kPrimaryColor2.withOpacity(.2))),
                child: imageView(imageURl: widget.product.image!)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.general.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${"quantity".tr}: ${widget.product.quantity}",
                    overflow: TextOverflow.ellipsis,
                    style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey),
                  ),
                  Text(
                    "${"price".tr} ${widget.product.sellPrice}",
                    overflow: TextOverflow.ellipsis,
                    style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey),
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
