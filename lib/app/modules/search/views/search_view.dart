import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/orders/components/order_card.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController controller = TextEditingController();
  final SearchViewController searchController = Get.find<SearchViewController>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(backArrow: true, actionIcon: false, centerTitle: true, name: "search"),
        body: Column(
          children: [
            searchWidget(),
            Expanded(
              child: Obx(() {
                return searchController.searchResult.isEmpty
                    ? emptyData()
                    : ListView.builder(
                        itemCount: controller.text.isNotEmpty ? searchController.searchResult.length : searchController.productsList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          final product = controller.text.isEmpty ? searchController.productsList[index] : searchController.searchResult[index];
                          return Padding(
                            padding: context.padding.horizontalNormal,
                            child: ProductCard(
                              product: product,
                              orderView: false,
                              addCounterWidget: false,
                            ),
                          );
                        },
                      );
              }),
            )
          ],
        ));
  }

  Widget searchWidget() {
    return Padding(
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
              searchController.onSearchTextChanged(value.toString());
            },
          ),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle),
            onPressed: () {
              controller.clear();
              searchController.onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }
}

class OrderSearchView extends StatefulWidget {
  const OrderSearchView({super.key});

  @override
  State<OrderSearchView> createState() => _OrderSearchViewState();
}

class _OrderSearchViewState extends State<OrderSearchView> {
  TextEditingController controller = TextEditingController();
  final OrderController searchController = Get.find<OrderController>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(backArrow: true, actionIcon: false, centerTitle: true, name: "search"),
        body: Column(
          children: [
            searchWidget(),
            Expanded(
              child: Obx(() {
                return searchController.searchResult.isEmpty
                    ? emptyData()
                    : ListView.builder(
                        itemCount: controller.text.isNotEmpty ? searchController.searchResult.length : searchController.allOrders.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          final product = controller.text.isEmpty ? searchController.allOrders[index] : searchController.searchResult[index];
                          return OrderCard(order: product);
                        },
                      );
              }),
            )
          ],
        ));
  }

  Widget searchWidget() {
    return Padding(
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
              searchController.onSearchTextChanged(value.toString());
            },
          ),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle),
            onPressed: () {
              controller.clear();
              searchController.onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }
}
