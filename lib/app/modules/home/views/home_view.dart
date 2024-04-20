import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/search/views/search_view.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/cards/sales_card.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_app/constants/custom_app_bar.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          backArrow: false,
          actionIcon: true,
          icon: IconButton(
              onPressed: () {
                Get.to(() => SearchView(
                      productList: _homeController.productsListHomeView,
                      collectionReference: FirebaseFirestore.instance.collection('products'),
                      whereToSearch: 'products',
                    ));
              },
              icon: const Icon(IconlyLight.search)),
          name: "products",
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
            FirestoreListView<Map<String, dynamic>>(
              query: FirebaseFirestore.instance.collection('products').orderBy("date", descending: true),
              pageSize: 3,
              shrinkWrap: true,
              showFetchingIndicator: true,
              fetchingIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
              emptyBuilder: (context) => const Text('No data'),
              errorBuilder: (context, error, stackTrace) => Text(error.toString()),
              loadingBuilder: (context) => const Center(
                  child: CircularProgressIndicator(
                color: Colors.amber,
              )),
              itemBuilder: (context, doc) {
                Map<String, dynamic> user = doc.data();
                final product = ProductModel(
                  name: user['name'],
                  brandName: user['brand'].toString(),
                  category: user['category'].toString(),
                  cost: user['cost'],
                  gramm: user['gramm'],
                  image: user['image'].toString(),
                  location: user['location'].toString(),
                  material: user['material'].toString(),
                  quantity: user['quantity'],
                  sellPrice: user['sell_price'].toString(),
                  note: user['note'].toString(),
                  package: user['package'].toString(),
                  documentID: doc.id,
                );
                return ProductCard(product: product, orderView: false);
              },
            ),
          ],
        ));
  }
}
