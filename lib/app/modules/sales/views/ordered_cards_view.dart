import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/sales_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
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
    salesController.isFiltered.value = false;
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {});
    }
    int length = salesController.cardsList.length;

    final secondQuery = salesController.isFiltered.value == true
        ? salesController.collectionReference.where('status', isEqualTo: salesController.isFilteredStatusName.value).startAfterDocument(salesController.cardsList.last).limit(limit)
        : salesController.collectionReference.orderBy("date", descending: true).startAfterDocument(salesController.cardsList.last).limit(limit);

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
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      footer: customFooter(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: salesController.cardsList.isEmpty
          ? emptyData()
          : ListView.builder(
              itemCount: salesController.cardsList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final order = OrderModel(
                    orderID: salesController.cardsList[index].id,
                    clientAddress: salesController.cardsList[index]['client_address'],
                    clientName: salesController.cardsList[index]['client_name'],
                    clientNumber: salesController.cardsList[index]['client_number'],
                    coupon: salesController.cardsList[index]['coupon'].toString(),
                    date: salesController.cardsList[index]['date'],
                    discount: salesController.cardsList[index]['discount'].toString(),
                    note: salesController.cardsList[index]['note'],
                    package: salesController.cardsList[index]['package'],
                    status: salesController.cardsList[index]['status'],
                    sumCost: salesController.cardsList[index]['sum_cost'].toString(),
                    sumPrice: salesController.cardsList[index]['sum_price'].toString(),
                    products: salesController.cardsList[index]['product_count']);
                return SalesCard(
                  order: order,
                  docID: order.orderID.toString(),
                );
              },
            ),
    );
  }
}
