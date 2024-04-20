import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/app/modules/sales/views/create_order.dart';
import 'package:stock_managament_app/app/modules/search/views/search_view.dart';
import 'package:stock_managament_app/constants/cards/sales_card.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_managament_app/constants/custom_app_bar.dart';
import 'package:stock_managament_app/constants/widgets.dart';

enum SortOption { date, price, status }

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  SortOption _selectedSortOption = SortOption.date; // Default sort option

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sort by',
            style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 20.sp),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              radioButton(SortOption.date, 'Date'),
              radioButton(SortOption.price, 'Price'),
              radioButton(SortOption.status, 'Status'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sort'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder radioButton(SortOption option, String text) {
    return StatefulBuilder(builder: (context, setState) {
      return RadioListTile(
        title: Text(text),
        value: option,
        groupValue: _selectedSortOption,
        onChanged: (SortOption? value) {
          setState(() {
            _selectedSortOption = value!;
            Get.back();
          });
        },
      );
    });
  }

  final SalesController salesController = Get.put(SalesController());
  @override
  void initState() {
    super.initState();
    salesController.collectionReference.orderBy("date", descending: true).limit(limit).get().then((value) {
      salesController.cardsList = value.docs;
      setState(() {});
    });
  }

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    salesController.cardsList.clear();
    setState(() {});

    await FirebaseFirestore.instance.collection('sales').orderBy("date", descending: true).limit(limit).get().then((value) {
      salesController.cardsList = value.docs;
      setState(() {});
    });

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {});
    }
    int length = salesController.cardsList.length;

    final secondQuery = salesController.collectionReference.orderBy("date", descending: true).startAfterDocument(salesController.cardsList.last).limit(limit);

    secondQuery.get().then((value) {
      salesController.cardsList.addAll(value.docs);
      setState(() {});
      if (length == salesController.cardsList.length) {
        showSnackBar("Done", "End of the products", Colors.green);
      }
    });

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const CreateOrderView());
        },
        backgroundColor: kPrimaryColor2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: CustomAppBar(
          backArrow: false,
          actionIcon: true,
          centerTitle: false,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    Get.to(() => SearchView(
                          productList: salesController.cardsList,
                          whereToSearch: 'orders',
                        ));
                  },
                  icon: const Icon(IconlyLight.search, color: Colors.black)),
              IconButton(
                  onPressed: () {
                    _showSortDialog();
                  },
                  icon: const Icon(IconlyLight.filter, color: Colors.black)),
            ],
          ),
          name: "sales"),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: customFooter(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: salesController.cardsList.isEmpty
            ? spinKit()
            : ListView.builder(
                itemCount: salesController.cardsList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final order = OrderModel(
                      orderID: salesController.cardsList[index].id,
                      clientAddress: salesController.cardsList[index]['client_address'],
                      clientName: salesController.cardsList[index]['client_name'],
                      clientNumber: salesController.cardsList[index]['client_number'],
                      coupon: salesController.cardsList[index]['coupon'],
                      date: salesController.cardsList[index]['date'],
                      discount: salesController.cardsList[index]['discount'],
                      note: salesController.cardsList[index]['note'],
                      package: salesController.cardsList[index]['package'],
                      status: salesController.cardsList[index]['status'],
                      sumCost: salesController.cardsList[index]['sum_cost'],
                      sumPrice: salesController.cardsList[index]['sum_price'],
                      products: salesController.cardsList[index]['product_count']);
                  return SalesCard(
                    order: order,
                    docID: order.orderID.toString(),
                  );
                },
              ),
      ),
    );
  }
}
