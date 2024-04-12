import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/constants.dart';

class ProductCardMine extends StatefulWidget {
  final String name;
  final String image;
  final String price;
  final String id;
  final int count;
  final String brand;
  final String category;
  final String location;
  final String material;
  final String note;
  final String package;
  final int quantity;
  final int cost;
  final int gramm;
  const ProductCardMine(
      {super.key,
      required this.name,
      required this.image,
      required this.price,
      required this.id,
      required this.count,
      required this.brand,
      required this.category,
      required this.location,
      required this.material,
      required this.note,
      required this.package,
      required this.quantity,
      required this.cost,
      required this.gramm});

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
      child: ListTile(
        title: Text(
          widget.name,
          maxLines: 2,
          style: TextStyle(color: Colors.black, fontSize: 12.sp),
        ),
        leading: SizedBox(
          width: 70,
          height: 70,
          child: CachedNetworkImage(
            fadeInCurve: Curves.ease,
            imageUrl: widget.image,
            useOldImageOnUrlChange: true,
            imageBuilder: (context, imageProvider) => Container(
              width: Get.size.width,
              decoration: BoxDecoration(
                borderRadius: borderRadius15,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Text('No Image'),
            ),
          ),
        ),
        subtitle: Text('\$${widget.price}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
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
              maxLines: 1,
            ), // Yeni: Sayıcıyı göster
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                selectedCount++;
                salesController.upgradeCount(int.parse(widget.id.toString()), selectedCount);
                salesController.addProductMain(
                    name: widget.name,
                    image: widget.image,
                    price: widget.price,
                    count: selectedCount,
                    id: widget.id,
                    brand: widget.brand,
                    category: widget.category,
                    location: widget.location,
                    material: widget.material,
                    note: widget.note,
                    package: widget.package,
                    quantity: widget.quantity,
                    cost: widget.cost,
                    gramm: widget.gramm);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
