import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SelectProductsView extends StatefulWidget {
  const SelectProductsView({super.key});

  @override
  State<SelectProductsView> createState() => _SelectProductsViewState();
}

class _SelectProductsViewState extends State<SelectProductsView> {
  TextEditingController controller = TextEditingController();
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  final SalesController salesController = Get.put(SalesController());

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final List _searchResult = [];

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

    final secondQuery = products.orderBy("date", descending: true).startAfterDocument(salesController.productListDocuments.last).limit(limit);
    secondQuery.get().then((value) {
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
      if (length == salesController.productList.length) {
        showSnackBar("Done", "End of the products", Colors.green);
      }
    });

    _refreshController.loadComplete();
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
                          return ProductCard(
                            product: _searchResult[i]['product'],
                            orderView: false,
                            addCounterWidget: true,
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
                            return ProductCard(
                              product: salesController.productList[index]['product'],
                              orderView: false,
                              addCounterWidget: true,
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
