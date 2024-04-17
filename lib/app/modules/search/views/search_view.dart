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
  final List productList;
  final bool orderedProductsSearch;
  const SearchView({super.key, required this.productList, required this.orderedProductsSearch});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController controller = TextEditingController();

  final List _searchResult = [];

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail in widget.productList) {
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

    setState(() {});
  }

  onSearchTextChangedOrdered(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    for (var userDetail in widget.productList) {
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
                    onChanged: widget.orderedProductsSearch ? onSearchTextChangedOrdered : onSearchTextChanged,
                  ),
                  contentPadding: EdgeInsets.only(left: 15.w),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle),
                    onPressed: () {
                      controller.clear();
                      widget.orderedProductsSearch ? onSearchTextChangedOrdered("") : onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
            widget.orderedProductsSearch ? orderedCardSearch() : searchFromProducts()
          ],
        ));
  }

  Expanded orderedCardSearch() {
    return Expanded(
      child: _searchResult.isNotEmpty || controller.text.isNotEmpty
          ? ListView.builder(
              itemCount: _searchResult.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                final OrderModel order = _searchResult[i]['order'];
                return SalesCard(
                  index: _searchResult.length - i,
                  order: order,
                );
              },
            )
          : ListView.builder(
              itemCount: widget.productList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final order = OrderModel(
                    orderID: widget.productList[index].id,
                    clientAddress: widget.productList[index]['client_address'],
                    clientName: widget.productList[index]['client_name'],
                    clientNumber: widget.productList[index]['client_number'],
                    coupon: widget.productList[index]['coupon'],
                    date: widget.productList[index]['date'],
                    discount: widget.productList[index]['discount'],
                    note: widget.productList[index]['note'],
                    package: widget.productList[index]['package'],
                    status: widget.productList[index]['status'],
                    sumCost: widget.productList[index]['sum_cost'],
                    sumPrice: widget.productList[index]['sum_price'],
                    products: widget.productList[index]['product_count']);
                return SalesCard(
                  index: widget.productList.length - index,
                  order: order,
                );
              },
            ),
    );
  }

  Expanded searchFromProducts() {
    return Expanded(
      child: _searchResult.isNotEmpty || controller.text.isNotEmpty
          ? ListView.builder(
              itemCount: _searchResult.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                final ProductModel product = _searchResult[i]['product'];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: ProductCard(
                    product: product,
                    orderView: false,
                  ),
                );
              },
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              itemCount: widget.productList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final product = ProductModel(
                  name: widget.productList[index]['name'],
                  brandName: widget.productList[index]['brand'].toString(),
                  category: widget.productList[index]['category'].toString(),
                  cost: widget.productList[index]['cost'],
                  gramm: widget.productList[index]['gramm'],
                  image: widget.productList[index]['image'].toString(),
                  location: widget.productList[index]['location'].toString(),
                  material: widget.productList[index]['material'].toString(),
                  quantity: widget.productList[index]['quantity'],
                  sellPrice: widget.productList[index]['sell_price'].toString(),
                  note: widget.productList[index]['note'].toString(),
                  package: widget.productList[index]['package'].toString(),
                  documentID: widget.productList[index].id,
                );
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: ProductCard(
                    product: product,
                    orderView: false,
                  ),
                );
              },
            ),
    );
  }
}
