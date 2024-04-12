import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/search/views/search_view.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.put(HomeController());
  int sum = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'products'.tr,
            style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 20.sp),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () async {
                  Get.to(() => SearchView());
                },
                icon: const Icon(IconlyLight.search))
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Obx(() => Column(
                children: [
                  homePageTopWidget(
                    stockInHand: _homeController.stockInHand.toString(),
                    totalProducts: _homeController.totalProductCount.toString(),
                  ),
                  productsListView()
                ],
              )),
        ));
  }

  Expanded productsListView() {
    return Expanded(
        flex: 5,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'products'.tr,
                  style: TextStyle(color: Colors.black54, fontFamily: gilroySemiBold, fontSize: 16.sp),
                ),
                IconButton(onPressed: () {}, color: Colors.black54, icon: const Icon(IconlyLight.filter))
              ],
            ),
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('products').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return spinKit();
                      } else if (snapshot.hasError) {
                        return errorData();
                      } else if (snapshot.data!.docs.isEmpty) {
                        return emptyData();
                      } else if (snapshot.hasData) {
                        _homeController.changeValues(snapshot.data!.docs);
                        return ListView.builder(
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

                            return ProductCard(
                              product: product,
                            );
                          },
                        );
                      }

                      return const Text("No data");
                    }))
          ],
        ));
  }
}
