import 'dart:async';

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
import 'package:stock_managament_app/constants/cards/ordered_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.whereToSearch, required this.productList});
  final List productList;
  final String whereToSearch;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController controller = TextEditingController();
  List productsList = [];
  Timer? _debounceTimer;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
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
    print(widget.productList);
    productsList = widget.productList;
    _searchResult.clear();
    setState(() {});
  }

  void _runSearch(String word) {
    List results = [];
    print(word);
    if (word.isEmpty) {
      results = productsList;
    } else {
      List<String> words = word.toLowerCase().trim().split(' ');
      results = productsList.where((p) {
        bool result = true;
        for (final word in words) {
          if (!(p.partNumber!.toLowerCase().contains(word) ||
              p.vendorCode!.toLowerCase().contains(word) ||
              p.description!.toLowerCase().contains(word) ||
              p.description2!.toLowerCase().contains(word))) {
            result = false;
          }
        }
        return result;
      }).toList();
      print(words);
    }
    // setState(() {
    //   foundItems = results.toSet().toList();
    // });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();

    // if (text.isEmpty) {
    //   _searchResult.clear();

    //   setState(() {});
    //   return;
    // }
    // if (_debounceTimer != null) {
    //   _debounceTimer!.cancel();
    // }
    // _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
    //   if (widget.whereToSearch == 'orders') {
    //     await FirebaseFirestore.instance
    //         .collection('sales')
    //         // .orderBy('date', descending: true)
    //         .where('client_number', isGreaterThanOrEqualTo: text)
    //         .where('client_number', isLessThanOrEqualTo: '$text\uf8ff')
    //         .get()
    //         .then((value) {
    //       print(value.docs);
    //       for (var element in value.docs) {
    //         final order = OrderModel(
    //             orderID: element.id,
    //             clientAddress: element['client_address'].toString(),
    //             clientName: element['client_name'],
    //             clientNumber: element['client_number'],
    //             coupon: element['coupon'].toString(),
    //             date: element['date'],
    //             discount: element['discount'].toString(),
    //             note: element['note'],
    //             package: element['package'],
    //             status: element['status'],
    //             sumCost: element['sum_cost'].toString(),
    //             sumPrice: element['sum_price'].toString(),
    //             products: element['product_count']);
    //         _searchResult.add({'order': order});
    //       }
    //     });
    //   } else {
    //     print('{{{{{{{object}}}}}}}');
    //     print(text);

    //     await FirebaseFirestore.instance
    //         .collection('products')
    //         // .orderBy('date', descending: true)
    //         .where('name', isGreaterThanOrEqualTo: text)
    //         .where('name', isLessThanOrEqualTo: '$text\uf8ff')
    //         .get()
    //         .then((value) {
    //       for (var element in value.docs) {
    //         final product = ProductModel(
    //           name: element['name'],
    //           brandName: element['brand'].toString(),
    //           category: element['category'].toString(),
    //           cost: element['cost'],
    //           gramm: element['gramm'],
    //           image: element['image'].toString(),
    //           location: element['location'].toString(),
    //           material: element['material'].toString(),
    //           quantity: element['quantity'],
    //           sellPrice: element['sell_price'].toString(),
    //           note: element['note'].toString(),
    //           package: element['package'].toString(),
    //           documentID: element.id,
    //         );
    //         print('{{{{{{{object}}}}}}}');
    //         print(value.docs);
    //         _searchResult.add({'product': product});
    //         print(_searchResult);
    //       }
    //     });
    //   }
    //   setState(() {});
    // });
  }

  Expanded searchWidget() {
    return Expanded(
      child: SmartRefresher(
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
            final order = OrderModel(
                orderID: productsList[index].id,
                clientAddress: productsList[index]['client_address'],
                clientName: productsList[index]['client_name'],
                clientNumber: productsList[index]['client_number'],
                coupon: productsList[index]['coupon'].toString(),
                date: productsList[index]['date'],
                discount: productsList[index]['discount'].toString(),
                note: productsList[index]['note'],
                package: productsList[index]['package'],
                status: productsList[index]['status'],
                sumCost: productsList[index]['sum_cost'].toString(),
                sumPrice: productsList[index]['sum_price'].toString(),
                products: productsList[index]['product_count']);
            return OrderedCard(
              docID: order.orderID!,
              order: order,
            );
          },
        ),
      ),
    );
  }

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
                      onSearchTextChanged(value);
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
}
