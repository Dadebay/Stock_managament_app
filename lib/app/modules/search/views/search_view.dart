import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/orders/components/order_card.dart';
import 'package:stock_managament_app/app/modules/search/controller/search_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SearchView extends StatefulWidget {
  final String whereToSearch;

  const SearchView({super.key, required this.whereToSearch});
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController controller = TextEditingController();
  final SearchViewController searchController = Get.put(SearchViewController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchController.getClientStream(widget.whereToSearch);
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
                return searchController.loadingData.value == true
                    ? spinKit()
                    : searchController.searchResult.isEmpty && controller.text.isNotEmpty
                        ? emptyData()
                        : ListView.builder(
                            itemCount: controller.text.isNotEmpty ? searchController.searchResult.length : searchController.productsList.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              if (widget.whereToSearch == 'orders') {
                                final order = controller.text.isEmpty ? OrderModel.fromJson(searchController.productsList[index]) : OrderModel.fromJson(searchController.searchResult[index]);
                                return OrderCard(order: order);
                              } else {
                                final product = controller.text.isEmpty ? ProductModel.fromDocument(searchController.productsList[index]) : ProductModel.fromDocument(searchController.searchResult[index]);
                                return Padding(
                                  padding: context.padding.normal,
                                  child: ProductCard(
                                    product: product,
                                    orderView: false,
                                    addCounterWidget: false,
                                  ),
                                );
                              }
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
              searchController.onSearchTextChanged(value.toString(), widget.whereToSearch);
            },
          ),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle),
            onPressed: () {
              controller.clear();
              searchController.onSearchTextChanged('', widget.whereToSearch);
            },
          ),
        ),
      ),
    );
  }
}
