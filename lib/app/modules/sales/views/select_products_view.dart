import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card_with_counter.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class SelectProductsView extends StatefulWidget {
  const SelectProductsView({super.key});

  @override
  State<SelectProductsView> createState() => _SelectProductsViewState();
}

class _SelectProductsViewState extends State<SelectProductsView> {
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  final SalesController salesController = Get.put(SalesController());
  TextEditingController controller = TextEditingController();
  final List _searchResult = [];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    salesController.productList.clear();
    salesController.productListDocuments.clear();
    setState(() {});

    await FirebaseFirestore.instance.collection('products').orderBy("date", descending: true).limit(limit).get().then((value) {
      salesController.productListDocuments.addAll(value.docs);
      for (var element in value.docs) {
        final product = ProductModel(
          name: element['name'],
          brandName: element['brand'].toString(),
          category: element['category'].toString(),
          cost: element['cost'],
          gramm: element['gramm'],
          image: element['image'].toString(),
          location: element['location'].toString(),
          material: element['material'].toString(),
          quantity: element['quantity'],
          sellPrice: element['sell_price'].toString(),
          note: element['note'].toString(),
          package: element['package'].toString(),
          documentID: element.id,
        );
        salesController.addProduct(
          product: product,
          count: 0,
        );
      }
      setState(() {});
    });

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {});
    }
    int length = salesController.productList.length;

    print("asdasdasd");
    print(salesController.productListDocuments.last);
    print(salesController.productListDocuments.last);
    print(salesController.productListDocuments.last);
    print(salesController.productListDocuments.last);
    print(salesController.productListDocuments.last);
    print(salesController.productListDocuments.last);
    final secondQuery = products.orderBy("date", descending: true).startAfterDocument(salesController.productListDocuments.last).limit(limit);
    print("asdasdasd");
    secondQuery.get().then((value) {
      print(value.docs);
      salesController.productListDocuments.addAll(value.docs);

      for (var element in value.docs) {
        final product = ProductModel(
          name: element['name'],
          brandName: element['brand'].toString(),
          category: element['category'].toString(),
          cost: element['cost'],
          gramm: element['gramm'],
          image: element['image'].toString(),
          location: element['location'].toString(),
          material: element['material'].toString(),
          quantity: element['quantity'],
          sellPrice: element['sell_price'].toString(),
          note: element['note'].toString(),
          package: element['package'].toString(),
          documentID: element.id,
        );
        salesController.addProduct(
          product: product,
          count: 0,
        );
      }
      print(length);
      print(salesController.productList.length);
      setState(() {});
      if (length == salesController.productList.length) {
        showSnackBar("Done", "End of the products", Colors.green);
      }
    });

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    products.get().then((value) {
      salesController.productList.clear();
      for (var element in value.docs) {
        final product = ProductModel(
          name: element['name'],
          brandName: element['brand'].toString(),
          category: element['category'].toString(),
          cost: element['cost'],
          gramm: element['gramm'],
          image: element['image'].toString(),
          location: element['location'].toString(),
          material: element['material'].toString(),
          quantity: element['quantity'],
          sellPrice: element['sell_price'].toString(),
          note: element['note'].toString(),
          package: element['package'].toString(),
          documentID: element.id,
        );
        salesController.addProduct(
          product: product,
          count: 0,
        );
      }
      for (var element in salesController.selectedProductsList) {
        final ProductModel product = element['product'];
        salesController.upgradeCount(int.parse(product.documentID.toString()), int.parse(element['count'].toString()));
      }
      setState(() {});
    });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    for (var userDetail in salesController.productList) {
      final ProductModel product = userDetail['product'];
      String name = product.name!;
      if (name.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add({
          'product': product,
          'count': userDetail['count'],
        });
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                IconlyLight.arrowLeftCircle,
                color: Colors.black,
              )),
          title: Text(
            'Select products'.tr,
            style: TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18.sp),
          ),
          centerTitle: true,
          foregroundColor: Colors.white,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: const Icon(
                    IconlyLight.search,
                    color: Colors.black,
                  ),
                  title: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Search', border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  contentPadding: EdgeInsets.only(left: 15.w),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle),
                    onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
            Obx(() {
              return Expanded(
                child: _searchResult.isNotEmpty || controller.text.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResult.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, i) {
                          return ProductCardMine(
                            product: _searchResult[i]['product'],
                            // count: int.parse(_searchResult[i]['count'].toString()),
                          );
                        },
                      )
                    : SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        header: const WaterDropHeader(),
                        footer: customFooter(),
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          itemCount: salesController.productList.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return ProductCardMine(
                              product: salesController.productList[index]['product'],
                              // count: int.parse(salesController.productList[index]['count'].toString()),
                            );
                          },
                        ),
                      ),
              );
            }),
          ],
        ));
  }
}
