import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/views/product_profil_view.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductProfilView(product: product));
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.h),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 15.w),
                decoration: BoxDecoration(color: Colors.grey.shade200, boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 3, blurRadius: 3)], borderRadius: borderRadius15),
                child: imageView(imageURl: product.image!)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 16.sp),
                  ),
                  Text(
                    "Quantity: ${product.quantity}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                  ),
                  Text(
                    "Sell price: ${product.sellPrice} \$",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(IconlyLight.arrowRightCircle))
          ],
        ),
      ),
    );
  }
}
