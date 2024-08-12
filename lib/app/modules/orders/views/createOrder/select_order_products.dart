import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
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
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'selectProducts'),
        body: Column(
          children: [
            searchWidget(),
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

  Container searchWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: borderRadius20,
        border: Border.all(color: kPrimaryColor1.withOpacity(0.4)),
      ),
      margin: const EdgeInsets.all(8.0),
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
    );
  }
}
