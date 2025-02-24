import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
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
            searchWidget(context),
            Expanded(
              child: Obx(() {
                return _searchResult.isNotEmpty || controller.text.isNotEmpty
                    ? _searchResults(context)
                    : salesController.loadingDataSelectProductView.value == true
                        ? spinKit()
                        : _normalListview(context);
              }),
            ),
          ],
        ));
  }

  ListView _normalListview(BuildContext context) {
    return ListView.builder(
      padding: context.padding.horizontalNormal,
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
  }

  ListView _searchResults(BuildContext context) {
    return ListView.builder(
      padding: context.padding.horizontalNormal,
      itemCount: _searchResult.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, i) {
        return ProductCard(
          product: _searchResult[i]['product'],
          orderView: false,
          addCounterWidget: true,
        );
      },
    );
  }

  Widget searchWidget(BuildContext context) {
    return Padding(
      padding: context.padding.normal,
      child: ListTile(
        leading: const Icon(
          IconlyLight.search,
          color: Colors.black,
        ),
        tileColor: Colors.grey.withOpacity(.2),
        shape: RoundedRectangleBorder(
          borderRadius: context.border.normalBorderRadius,
          side: BorderSide(color: kPrimaryColor2.withOpacity(.4)),
        ),
        title: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'search'.tr, hintStyle: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey, fontSize: 20), border: InputBorder.none),
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
