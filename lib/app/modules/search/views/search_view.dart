import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/cards/sales_card.dart';
import 'package:stock_managament_app/constants/custom_app_bar.dart';

class SearchView extends StatefulWidget {
  final CollectionReference collectionReference;
  final List productList;
  final String whereToSearch;

  const SearchView({super.key, required this.collectionReference, required this.whereToSearch, required this.productList});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController controller = TextEditingController();
  List productsList = [];
  final List _searchResult = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  @override
  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }

  getClientStream() {
    if (widget.whereToSearch == 'orders') {
      widget.collectionReference.orderBy("date", descending: true).get().then((value) {
        productsList = value.docs;
        setState(() {});
      });
    } else {
      productsList = widget.productList;
      setState(() {});
    }
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    for (var userDetail in productsList) {
      if (widget.whereToSearch == 'orders') {
        final order = OrderModel(
            orderID: userDetail.id,
            clientAddress: userDetail['client_address'],
            clientName: userDetail['client_name'],
            clientNumber: userDetail['client_number'],
            coupon: userDetail['coupon'],
            date: userDetail['date'],
            discount: userDetail['discount'],
            note: userDetail['note'],
            package: userDetail['package'],
            status: userDetail['status'],
            sumCost: userDetail['sum_cost'],
            sumPrice: userDetail['sum_price'],
            products: userDetail['product_count']);
        String name = order.clientNumber!;
        if (name.toLowerCase().contains(text.toLowerCase())) {
          _searchResult.add({'order': order});
        }
      } else if (widget.whereToSearch == 'products') {
        final product = ProductModel(
          name: userDetail['name'],
          brandName: userDetail['brand'].toString(),
          category: userDetail['category'].toString(),
          cost: userDetail['cost'],
          gramm: userDetail['gramm'],
          image: userDetail['image'].toString(),
          location: userDetail['location'].toString(),
          material: userDetail['material'].toString(),
          quantity: userDetail['quantity'],
          sellPrice: userDetail['sell_price'].toString(),
          note: userDetail['note'].toString(),
          package: userDetail['package'].toString(),
          documentID: userDetail.id,
        );
        String name = product.name!;
        if (name.toLowerCase().contains(text.toLowerCase())) {
          _searchResult.add({'product': product});
        }
      }
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
            searchWidget()
          ],
        ));
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
          : ListView.builder(
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
    );
  }
}
