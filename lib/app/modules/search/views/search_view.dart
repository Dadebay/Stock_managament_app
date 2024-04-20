import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/cards/sales_card.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:stock_managament_app/constants/custom_app_bar.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class SearchView extends StatefulWidget {
  final List productList;
  final String whereToSearch;

  const SearchView({super.key, required this.whereToSearch, required this.productList});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController controller = TextEditingController();
  List productsList = [];
  final List _searchResult = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getClientStream();
  }

  getClientStream() {
    if (widget.whereToSearch == 'orders') {
      productsList = widget.productList;
    } else {
      productsList = widget.productList;
    }
    setState(() {});
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    if (widget.whereToSearch == 'orders') {
      await FirebaseFirestore.instance.collection('sales').where('client_number', isGreaterThanOrEqualTo: text).where('client_number', isLessThanOrEqualTo: '$text\uf8ff').get().then((value) {
        for (var element in value.docs) {
          final order = OrderModel(
              orderID: element.id,
              clientAddress: element['client_address'],
              clientName: element['client_name'],
              clientNumber: element['client_number'],
              coupon: element['coupon'],
              date: element['date'],
              discount: element['discount'],
              note: element['note'],
              package: element['package'],
              status: element['status'],
              sumCost: element['sum_cost'],
              sumPrice: element['sum_price'],
              products: element['product_count']);
          _searchResult.add({'order': order});
        }
      });
    } else {
      await FirebaseFirestore.instance.collection('products').where('name', isGreaterThanOrEqualTo: text).where('name', isLessThanOrEqualTo: '$text\uf8ff').get().then((value) {
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
          _searchResult.add({'product': product});
        }
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(backArrow: true, actionIcon: false, centerTitle: true, name: "search"),
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
                    decoration: InputDecoration(hintText: 'search'.tr, border: InputBorder.none),
                    onChanged: (String value) {
                      onSearchTextChanged(value.toLowerCase());
                    },
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
            searchWidget()
          ],
        ));
  }

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    productsList.clear();
    setState(() {});
    if (widget.whereToSearch == 'orders') {
      await FirebaseFirestore.instance.collection('sales').orderBy("date", descending: true).limit(limit).get().then((value) {
        productsList = value.docs;
        setState(() {});
      });
    } else if (widget.whereToSearch == 'products') {
      await FirebaseFirestore.instance.collection('products').orderBy("date", descending: true).limit(limit).get().then((value) {
        productsList = value.docs;
        setState(() {});
      });
    }

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {});
    }
    int length = productsList.length;
    if (widget.whereToSearch == 'orders') {
      final secondQuery = FirebaseFirestore.instance.collection('sales').orderBy("date", descending: true).startAfterDocument(productsList.last).limit(limit);
      secondQuery.get().then((value) {
        productsList.addAll(value.docs);
        setState(() {});
        if (length == productsList.length) {
          showSnackBar("Done", "End of the products", Colors.green);
        }
      });
    } else {
      final secondQuery = FirebaseFirestore.instance.collection('products').orderBy("date", descending: true).startAfterDocument(productsList.last).limit(limit);
      secondQuery.get().then((value) {
        productsList.addAll(value.docs);
        setState(() {});
        if (length == productsList.length) {
          showSnackBar("Done", "End of the products", Colors.green);
        }
      });
    }

    _refreshController.loadComplete();
  }

  Expanded searchWidget() {
    return Expanded(
      child: _searchResult.isNotEmpty || controller.text.isNotEmpty
          ? ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              itemCount: _searchResult.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                if (widget.whereToSearch == 'orders') {
                  final OrderModel order = _searchResult[i]['order'];
                  return SalesCard(
                    docID: order.orderID!,
                    order: order,
                  );
                } else if (widget.whereToSearch == 'products') {
                  final ProductModel product = _searchResult[i]['product'];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: ProductCard(
                      product: product,
                      orderView: false,
                    ),
                  );
                }
                return const Text("No error text find it ");
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
                itemCount: productsList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (widget.whereToSearch == 'orders') {
                    final order = OrderModel(
                        orderID: productsList[index].id,
                        clientAddress: productsList[index]['client_address'],
                        clientName: productsList[index]['client_name'],
                        clientNumber: productsList[index]['client_number'],
                        coupon: productsList[index]['coupon'],
                        date: productsList[index]['date'],
                        discount: productsList[index]['discount'],
                        note: productsList[index]['note'],
                        package: productsList[index]['package'],
                        status: productsList[index]['status'],
                        sumCost: productsList[index]['sum_cost'],
                        sumPrice: productsList[index]['sum_price'],
                        products: productsList[index]['product_count']);
                    return SalesCard(
                      docID: order.orderID!,
                      order: order,
                    );
                  } else if (widget.whereToSearch == 'products') {
                    final product = ProductModel(
                      name: productsList[index]['name'],
                      brandName: productsList[index]['brand'].toString(),
                      category: productsList[index]['category'].toString(),
                      cost: productsList[index]['cost'],
                      gramm: productsList[index]['gramm'],
                      image: productsList[index]['image'].toString(),
                      location: productsList[index]['location'].toString(),
                      material: productsList[index]['material'].toString(),
                      quantity: productsList[index]['quantity'],
                      sellPrice: productsList[index]['sell_price'].toString(),
                      note: productsList[index]['note'].toString(),
                      package: productsList[index]['package'].toString(),
                      documentID: productsList[index].id,
                    );
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: ProductCard(
                        product: product,
                        orderView: false,
                      ),
                    );
                  }
                  return const Text("No error text find it ");
                },
              ),
            ),
    );
  }
}
