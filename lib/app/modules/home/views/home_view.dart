import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List filters = [
    {'name': 'Brands', 'searchName': 'brand'},
    {'name': 'Categories', 'searchName': 'category'},
    {'name': 'Locations', 'searchName': 'location'},
    {'name': 'Materials', 'searchName': 'material'}
  ];
  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _homeController.onRefreshController();
    _refreshControllerMine.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _homeController.onLoadingController();
    _refreshControllerMine.loadComplete();
  }

  final HomeController _homeController = Get.put(HomeController());
  final RefreshController _refreshControllerMine = RefreshController(initialRefresh: false);

  Future<dynamic> filter() {
    return Get.defaultDialog(
        title: 'filter'.tr,
        titleStyle: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 20.sp),
        content: Container(
          width: Get.size.width / 1.5,
          height: Get.size.height / 2,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: ListView.builder(
            itemCount: filters.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  Get.defaultDialog(
                      title: filters[index]['name'],
                      titleStyle: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 18.sp),
                      content: Container(
                        width: Get.size.width / 1.5,
                        height: Get.size.height / 2,
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection(filters[index]['name'].toLowerCase()).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (BuildContext context, int indexx) {
                                    return ListTile(
                                      onTap: () {
                                        _homeController.filterProducts(filters[index]['searchName'], snapshot.data!.docs[indexx]['name']);
                                      },
                                      title: Text(snapshot.data!.docs[indexx]['name']),
                                    );
                                  },
                                );
                              }
                              return Center(
                                child: spinKit(),
                              );
                            }),
                      ));
                },
                title: Text(
                  filters[index]['name'].toString(),
                  style: TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18.sp),
                ),
                trailing: const Icon(IconlyLight.arrowRightCircle),
              );
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(children: [
        Expanded(
          flex: 1,
          child: Obx(() {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                textWidgetHomeVIew(_homeController.totalProductCount.toString(), 'totalProducts'.tr),
                textWidgetHomeVIew(_homeController.stockInHand.toString(), 'stockInHand'.tr),
              ],
            );
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('products'.tr, style: TextStyle(color: Colors.black54, fontFamily: gilroySemiBold, fontSize: 16.sp)),
            IconButton(onPressed: () => filter(), color: Colors.black54, icon: const Icon(IconlyLight.filter))
          ],
        ),
        Expanded(
          flex: 5,
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: const WaterDropHeader(),
            footer: customFooter(),
            controller: _refreshControllerMine,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: Obx(() {
              return _homeController.loadingData.value == true
                  ? spinKit()
                  : _homeController.productsListHomeView.isEmpty
                      ? emptyData()
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _homeController.productsListHomeView.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            final product = ProductModel(
                                name: _homeController.productsListHomeView[index]['name'],
                                brandName: _homeController.productsListHomeView[index]['brand'].toString(),
                                category: _homeController.productsListHomeView[index]['category'].toString(),
                                cost: _homeController.productsListHomeView[index]['cost'].toString(),
                                gramm: _homeController.productsListHomeView[index]['gramm'].toString(),
                                image: _homeController.productsListHomeView[index]['image'].toString(),
                                location: _homeController.productsListHomeView[index]['location'].toString(),
                                material: _homeController.productsListHomeView[index]['material'].toString(),
                                quantity: _homeController.productsListHomeView[index]['quantity'],
                                sellPrice: _homeController.productsListHomeView[index]['sell_price'].toString(),
                                note: _homeController.productsListHomeView[index]['note'].toString(),
                                package: _homeController.productsListHomeView[index]['package'].toString(),
                                documentID: _homeController.productsListHomeView[index].id);
                            return ProductCard(
                              product: product,
                              orderView: false,
                              addCounterWidget: false,
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Divider(thickness: 1, color: Colors.grey.shade200),
                            );
                          },
                        );
            }),
          ),
        )
      ]),
    );
  }
}
