import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class ProductCardMine extends StatefulWidget {
  final int count;

  final ProductModel product;
  const ProductCardMine({super.key, required this.count, required this.product});

  @override
  State<ProductCardMine> createState() => _ProductCardMineState();
}

class _ProductCardMineState extends State<ProductCardMine> {
  int selectedCount = 0;
  @override
  void initState() {
    super.initState();
    changeData();
  }

  changeData() {
    selectedCount = widget.count;
    setState(() {});
  }

  final SalesController salesController = Get.put(SalesController());
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
      elevation: 0.5,
      child: ListTile(
        onTap: () {},
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
                print(widget.product.quantity!);
                if (selectedCount >= widget.product.quantity!) {
                  showSnackBar("Error", "We dont have to much item ", Colors.red);
                } else {
                  selectedCount++;
                  salesController.upgradeCount(int.parse(widget.product.documentID.toString()), selectedCount);
                  salesController.addProductMain(product: widget.product, count: selectedCount);
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
