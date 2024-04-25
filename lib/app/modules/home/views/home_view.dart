import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.put(HomeController());

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _homeController.productsListHomeView.clear();
    setState(() {});

    await FirebaseFirestore.instance.collection('products').orderBy("date", descending: true).limit(limit).get().then((value) {
      _homeController.productsListHomeView = value.docs;
      setState(() {});
    });

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {});
    }
    int length = _homeController.productsListHomeView.length;

    final secondQuery = isFiltered == true
        ? FirebaseFirestore.instance.collection('products').where(filteredName.toLowerCase(), isEqualTo: filteredNameIndex).startAfterDocument(_homeController.productsListHomeView.last).limit(limit)
        : _homeController.collectionReference.orderBy("date", descending: true).startAfterDocument(_homeController.productsListHomeView.last).limit(limit);

    secondQuery.get().then((value) {
      _homeController.productsListHomeView.addAll(value.docs);
      setState(() {});
      if (length == _homeController.productsListHomeView.length) {
        showSnackBar("Done", "End of the products", Colors.green);
      }
    });

    _refreshController.loadComplete();
  }

  onFilteredProducts() {
    _homeController.productsListHomeView.clear();
  }

  String filteredName = '';
  String filteredNameIndex = '';

  List filters = ['Brands', 'Categories', 'Locations', 'Materials'];
  List filtersSearch = ['brand', 'category', 'location', 'material'];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Obx(() => Column(
            children: [
              homePageTopWidget(
                stockInHand: _homeController.stockInHand.toString(),
                totalProducts: _homeController.totalProductCount.toString(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'products'.tr,
                    style: TextStyle(color: Colors.black54, fontFamily: gilroySemiBold, fontSize: 16.sp),
                  ),
                  IconButton(
                      onPressed: () {
                        filter();
                      },
                      color: Colors.black54,
                      icon: const Icon(IconlyLight.filter))
                ],
              ),
              productsListView()
            ],
          )),
    );
  }

  bool isFiltered = false;
  Future<dynamic> filter() {
    return Get.bottomSheet(Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Wrap(
        children: [
          Text(
            'filter'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontFamily: gilroySemiBold,
              fontSize: 22.sp,
            ),
          ),
          ListView.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  String data = filters[index];
                  Get.bottomSheet(Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                    child: Wrap(
                      children: [
                        Text(
                          filters[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: gilroySemiBold,
                            fontSize: 22.sp,
                          ),
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance.collection(data.toLowerCase()).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (BuildContext context, int indexx) {
                                    return ListTile(
                                      onTap: () {
                                        String name = filtersSearch[index];
                                        filteredName = name;
                                        filteredNameIndex = snapshot.data!.docs[indexx]['name'];
                                        _homeController.productsListHomeView.clear();
                                        FirebaseFirestore.instance.collection('products').where(name.toLowerCase(), isEqualTo: snapshot.data!.docs[indexx]['name']).get().then((value) {
                                          if (value.docs.isEmpty) {
                                            _homeController.productsListHomeView.clear();
                                          } else {
                                            _homeController.productsListHomeView.addAll(value.docs);
                                          }
                                          isFiltered = true;
                                          setState(() {});
                                        });
                                        Get.back();
                                        Get.back();
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
                      ],
                    ),
                  ));
                },
                title: Text(filters[index]),
                trailing: const Icon(IconlyLight.arrowRightCircle),
              );
            },
          ),
        ],
      ),
    ));
  }

  Widget productsListView() {
    return Expanded(
      flex: 5,
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: customFooter(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: _homeController.productsListHomeView.isEmpty
            ? emptyData()
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
                  return ProductCard(
                    product: product,
                    orderView: false,
                    addCounterWidget: false,
                  );
                },
              ),
      ),
    );
  }
}
