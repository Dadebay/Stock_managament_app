import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card_with_counter.dart';
import 'package:stock_managament_app/constants/constants.dart';

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

  @override
  void initState() {
    super.initState();
    products.get().then((value) {
      salesController.productList.clear();
      for (var element in value.docs) {
        salesController.addProduct(
            name: element['name'] ?? 'name',
            image: element['image'] ?? 'image',
            price: element['sell_price'] ?? '',
            count: 0,
            id: element.id.toString(),
            brand: element['brand'] ?? 'brand',
            category: element['category'] ?? 'category',
            location: element['location'] ?? 'location',
            material: element['material'] ?? 'material',
            note: element['note'] ?? 'note',
            package: element['package'] ?? 'package',
            quantity: int.parse(element['quantity'].toString()),
            cost: int.parse(element['cost'].toString()),
            gramm: int.parse(element['gramm'].toString()));
      }
      print(salesController.productList);
      // for (var element in salesController.selectedProductsList) {
      //   salesController.upgradeCount(int.parse(element['id'].toString()), int.parse(element['count'].toString()));
      // }
      setState(() {});
    });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    salesController.productList.refresh();
    for (var userDetail in salesController.productList) {
      String name = userDetail['name'];
      if (name.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add({
          'id': userDetail['id'],
          'name': userDetail['name'],
          'image': userDetail['image'],
          'sell_price': userDetail['sell_price'],
          'count': userDetail['count'],
        });
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.search),
                    title: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Search', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              return Expanded(
                child: _searchResult.isNotEmpty || controller.text.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResult.length,
                        itemBuilder: (context, i) {
                          return ProductCardMine(
                            name: _searchResult[i]['name'],
                            image: _searchResult[i]['image'],
                            price: _searchResult[i]['sell_price'],
                            id: _searchResult[i]['id'],
                            count: int.parse(_searchResult[i]['count'].toString()),
                            brand: _searchResult[i]['brand'],
                            category: _searchResult[i]['category'],
                            location: _searchResult[i]['location'],
                            material: _searchResult[i]['material'],
                            note: _searchResult[i]['note'],
                            package: _searchResult[i]['package'],
                            quantity: _searchResult[i]['quantity'],
                            cost: _searchResult[i]['cost'],
                            gramm: _searchResult[i]['gramm'],
                          );
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        itemCount: salesController.productList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ProductCardMine(
                            name: salesController.productList[index]['name'] ?? 'Name',
                            image: salesController.productList[index]['image'] ?? "image",
                            price: salesController.productList[index]['sell_price'] ?? 'sellprice',
                            id: salesController.productList[index]['id'],
                            count: int.parse(salesController.productList[index]['count'].toString()),
                            brand: salesController.productList[index]['brand'] ?? 'brand',
                            category: salesController.productList[index]['category'] ?? 'categ',
                            location: salesController.productList[index]['location'] ?? 'loca',
                            material: salesController.productList[index]['material'] ?? 'material',
                            note: salesController.productList[index]['note'] ?? 'note',
                            package: salesController.productList[index]['package'] ?? 'packa',
                            quantity: salesController.productList[index]['quantity'] ?? 0,
                            cost: salesController.productList[index]['cost'] ?? 0,
                            gramm: salesController.productList[index]['gramm'] ?? 0,
                          );
                        },
                      ),
              );
            }),
          ],
        ));
  }
}
