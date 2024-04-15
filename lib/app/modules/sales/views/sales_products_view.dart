import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class SalesProductView extends StatelessWidget {
  final OrderModel order;

  const SalesProductView({super.key, required this.order});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order ${order.orderID}'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              IconlyLight.arrowLeftCircle,
              color: Colors.black,
            )),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        children: [
          textWidget(text1: 'Date order', text2: order.date!),
          textWidget(text1: 'Status', text2: order.status!),
          textWidget(text1: 'Package', text2: order.package!),
          textWidget(text1: 'Client number', text2: order.clientNumber!),
          textWidget(text1: 'Client name', text2: order.clientName!),
          textWidget(text1: 'Client address', text2: order.clientAddress!),
          textWidget(text1: 'Discount', text2: order.discount!),
          textWidget(text1: 'Sum Price', text2: order.sumPrice!),
          textWidget(text1: 'Note', text2: order.note!),
          textWidget(text1: 'Product count', text2: order.products!.toString()),
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('sales').doc(order.orderID).collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return spinKit();
                } else if (snapshot.hasError) {
                  return errorData();
                } else if (snapshot.data!.docs.isEmpty) {
                  return emptyData();
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final product = ProductModel(
                        name: snapshot.data!.docs[index]['name'],
                        brandName: snapshot.data!.docs[index]['brand'].toString(),
                        category: snapshot.data!.docs[index]['category'].toString(),
                        cost: snapshot.data!.docs[index]['cost'],
                        gramm: snapshot.data!.docs[index]['gramm'],
                        image: snapshot.data!.docs[index]['image'].toString(),
                        location: snapshot.data!.docs[index]['location'].toString(),
                        material: snapshot.data!.docs[index]['material'].toString(),
                        quantity: snapshot.data!.docs[index]['quantity'],
                        sellPrice: snapshot.data!.docs[index]['sell_price'].toString(),
                        note: snapshot.data!.docs[index]['note'].toString(),
                        package: snapshot.data!.docs[index]['package'].toString(),
                        documentID: snapshot.data!.docs[index].id,
                      );
                      return ProductCard(product: product, orderView: true);
                    },
                  );
                }

                return const Text("No data");
              })
        ],
      ),
    );
  }

  Widget textWidget({required String text1, required String text2}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontFamily: gilroyMedium, fontSize: 14.sp),
              ),
              Text(
                text2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14.sp),
              )
            ],
          ),
        ),
        Divider(
          color: Colors.grey.shade200,
        )
      ],
    );
  }
}
