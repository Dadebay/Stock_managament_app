import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/search/controller/search_controller.dart';
import 'package:stock_managament_app/constants/cards/ordered_card.dart';
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
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            itemCount: controller.text.isNotEmpty ? searchController.searchResult.length : searchController.productsList.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              if (widget.whereToSearch == 'orders') {
                                final order = controller.text.isEmpty
                                    ? OrderModel(
                                        orderID: searchController.productsList[index].id,
                                        clientAddress: searchController.productsList[index]['client_address'],
                                        clientName: searchController.productsList[index]['client_name'],
                                        clientNumber: searchController.productsList[index]['client_number'],
                                        coupon: searchController.productsList[index]['coupon'].toString(),
                                        date: searchController.productsList[index]['date'],
                                        discount: searchController.productsList[index]['discount'].toString(),
                                        note: searchController.productsList[index]['note'],
                                        package: searchController.productsList[index]['package'],
                                        status: searchController.productsList[index]['status'],
                                        sumCost: searchController.productsList[index]['sum_cost'].toString(),
                                        sumPrice: searchController.productsList[index]['sum_price'].toString(),
                                        products: searchController.productsList[index]['product_count'])
                                    : OrderModel(
                                        orderID: searchController.searchResult[index].id,
                                        clientAddress: searchController.searchResult[index]['client_address'],
                                        clientName: searchController.searchResult[index]['client_name'],
                                        clientNumber: searchController.searchResult[index]['client_number'],
                                        coupon: searchController.searchResult[index]['coupon'].toString(),
                                        date: searchController.searchResult[index]['date'],
                                        discount: searchController.searchResult[index]['discount'].toString(),
                                        note: searchController.searchResult[index]['note'],
                                        package: searchController.searchResult[index]['package'],
                                        status: searchController.searchResult[index]['status'],
                                        sumCost: searchController.searchResult[index]['sum_cost'].toString(),
                                        sumPrice: searchController.searchResult[index]['sum_price'].toString(),
                                        products: searchController.searchResult[index]['product_count']);
                                return OrderedCard(
                                  docID: order.orderID!,
                                  order: order,
                                );
                              } else {
                                final product = controller.text.isEmpty
                                    ? ProductModel(
                                        name: searchController.productsList[index]['name'],
                                        brandName: searchController.productsList[index]['brand'].toString(),
                                        category: searchController.productsList[index]['category'].toString(),
                                        cost: searchController.productsList[index]['cost'],
                                        gramm: searchController.productsList[index]['gramm'],
                                        image: searchController.productsList[index]['image'].toString(),
                                        location: searchController.productsList[index]['location'].toString(),
                                        material: searchController.productsList[index]['material'].toString(),
                                        quantity: searchController.productsList[index]['quantity'],
                                        sellPrice: searchController.productsList[index]['sell_price'].toString(),
                                        note: searchController.productsList[index]['note'].toString(),
                                        package: searchController.productsList[index]['package'].toString(),
                                        documentID: searchController.productsList[index].id,
                                      )
                                    : ProductModel(
                                        name: searchController.searchResult[index]['name'],
                                        brandName: searchController.searchResult[index]['brand'].toString(),
                                        category: searchController.searchResult[index]['category'].toString(),
                                        cost: searchController.searchResult[index]['cost'],
                                        gramm: searchController.searchResult[index]['gramm'],
                                        image: searchController.searchResult[index]['image'].toString(),
                                        location: searchController.searchResult[index]['location'].toString(),
                                        material: searchController.searchResult[index]['material'].toString(),
                                        quantity: searchController.searchResult[index]['quantity'],
                                        sellPrice: searchController.searchResult[index]['sell_price'].toString(),
                                        note: searchController.searchResult[index]['note'].toString(),
                                        package: searchController.searchResult[index]['package'].toString(),
                                        documentID: searchController.searchResult[index].id,
                                      );
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
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

  Padding searchWidget() {
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
              searchController.onSearchTextChanged(value, widget.whereToSearch);
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
