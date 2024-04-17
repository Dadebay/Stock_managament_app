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
  void initState() {
    super.initState();
    _homeController.collectionReference.get().then((value) {
      _homeController.productsListHomeView = value.docs;
      setState(() {});
      _homeController.stockInHand.value = 0;
      _homeController.totalProductCount.value = value.docs.length;
      for (var element in value.docs) {
        _homeController.updateStock(int.parse(element['quantity'].toString()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          backArrow: false,
          actionIcon: true,
          icon: IconButton(
              onPressed: () {
                Get.to(() => SearchView(orderedProductsSearch: false, productList: _homeController.productsListHomeView));
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
            Expanded(
                child: _homeController.productsListHomeView.isEmpty
                    ? _homeController.stockInHand.value == 0
                        ? spinKit()
                        : emptyData()
                    : ListView.builder(
                        itemCount: _homeController.productsListHomeView.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          final product = ProductModel(
                            name: _homeController.productsListHomeView[index]['name'],
                            brandName: _homeController.productsListHomeView[index]['brand'].toString(),
                            category: _homeController.productsListHomeView[index]['category'].toString(),
                            cost: _homeController.productsListHomeView[index]['cost'],
                            gramm: _homeController.productsListHomeView[index]['gramm'],
                            image: _homeController.productsListHomeView[index]['image'].toString(),
                            location: _homeController.productsListHomeView[index]['location'].toString(),
                            material: _homeController.productsListHomeView[index]['material'].toString(),
                            quantity: _homeController.productsListHomeView[index]['quantity'],
                            sellPrice: _homeController.productsListHomeView[index]['sell_price'].toString(),
                            note: _homeController.productsListHomeView[index]['note'].toString(),
                            package: _homeController.productsListHomeView[index]['package'].toString(),
                            documentID: _homeController.productsListHomeView[index].id,
                          );
                          return ProductCard(product: product, orderView: false);
                        },
                      )),
          ],
        ));
  }
}
