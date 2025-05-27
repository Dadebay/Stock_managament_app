import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/product/views/product_profil_view.dart';
import 'package:stock_managament_app/app/product/sizes/widget_sizes.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.orderView,
    required this.addCounterWidget,
  });

  final bool addCounterWidget;
  final bool orderView;
  final SearchModel product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final HomeController homeController = Get.find<HomeController>();
  final SearchViewController seacrhViewController = Get.find<SearchViewController>();

  @override
  Widget build(BuildContext context) {
    return widget.addCounterWidget ? counterWidget(context) : noCounterWidget();
  }

  Widget counterWidget(BuildContext context) {
    return Container(
      margin: context.padding.onlyTopNormal,
      decoration: BoxDecoration(
        borderRadius: borderRadius20,
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 3, spreadRadius: 3)],
        border: Border.all(color: kPrimaryColor2.withOpacity(0.3)),
      ),
      child: ListTile(
        title: Text(
          widget.product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.general.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        visualDensity: const VisualDensity(vertical: 3),
        contentPadding: EdgeInsets.only(left: 10.w),
        leading: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius15,
              border: Border.all(color: kPrimaryColor2.withOpacity(.3), width: 1),
            ),
            width: 70,
            child: imageView(imageURl: widget.product.img!)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: context.padding.verticalLow,
              child: Text(
                "price".tr + widget.product.price,
                style: context.general.textTheme.bodyMedium!.copyWith(color: Colors.grey),
              ),
            ),
            Text(
              '${"productCount".tr} : ${widget.product.count}',
              style: context.general.textTheme.bodyMedium!.copyWith(color: Colors.grey),
            ),
          ],
        ),
        trailing: Obx(() {
          final selectedCount = seacrhViewController.getProductCount(widget.product.id.toString());

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.minus_circle, color: Colors.black),
                onPressed: () {
                  if (selectedCount > 0) {
                    seacrhViewController.decreaseCount(widget.product.id.toString(), selectedCount - 1);

                    setState(() {});
                  }
                },
              ),
              SizedBox(
                width: 15.w,
                child: Text(
                  selectedCount.toString(),
                  style: TextStyle(color: Colors.black, fontSize: 18.sp),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.add_circled, color: Colors.black),
                onPressed: () {
                  if (selectedCount >= widget.product.count) {
                    showSnackBar("Error", "Not in stock", Colors.red);
                  } else {
                    seacrhViewController.addOrUpdateProduct(product: widget.product, count: selectedCount + 1);

                    setState(() {});
                  }
                },
              ),
            ],
          );
        }),
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
                child: imageView(imageURl: widget.product.img!)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.general.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${"quantity".tr}: ${widget.product.count}",
                    overflow: TextOverflow.ellipsis,
                    style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey),
                  ),
                  Text(
                    "${"price".tr} ${widget.product.price}",
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
