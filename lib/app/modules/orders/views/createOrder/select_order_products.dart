import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SelectOrderProducts extends StatefulWidget {
  const SelectOrderProducts({super.key});

  @override
  State<SelectOrderProducts> createState() => _SelectOrderProductsState();
}

class _SelectOrderProductsState extends State<SelectOrderProducts> {
  final SalesController salesController = Get.put(SalesController());
  TextEditingController controller = TextEditingController();
  final List _searchResult = [];

  @override
  void initState() {
    super.initState();
    salesController.getDataSelectProductsView();
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
        appBar: const CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'selectProducts'),
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
            Expanded(
              child: Obx(() {
                return _searchResult.isNotEmpty || controller.text.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
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
                    : salesController.loadingDataSelectProductView.value == true
                        ? spinKit()
                        : ListView.builder(
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
                          );
              }),
            ),
          ],
        ));
  }
}
