import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/ordered_card.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final SalesController salesController = Get.put(SalesController());
  final RefreshController _refreshControllerOrders = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    salesController.onRefreshController();
    _refreshControllerOrders.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    salesController.onLoadingController();
    _refreshControllerOrders.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      footer: customFooter(),
      controller: _refreshControllerOrders,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: Obx(() {
        return salesController.loadingDataOrders.value == true
            ? spinKit()
            : salesController.orderCardList.isEmpty
                ? emptyData()
                : ListView.builder(
                    itemCount: salesController.orderCardList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final order = OrderModel(
                          orderID: salesController.orderCardList[index].id,
                          clientAddress: salesController.orderCardList[index]['client_address'],
                          clientName: salesController.orderCardList[index]['client_name'],
                          clientNumber: salesController.orderCardList[index]['client_number'],
                          coupon: salesController.orderCardList[index]['coupon'].toString(),
                          date: salesController.orderCardList[index]['date'],
                          discount: salesController.orderCardList[index]['discount'].toString(),
                          note: salesController.orderCardList[index]['note'],
                          package: salesController.orderCardList[index]['package'],
                          status: salesController.orderCardList[index]['status'],
                          sumCost: salesController.orderCardList[index]['sum_cost'].toString(),
                          sumPrice: salesController.orderCardList[index]['sum_price'].toString(),
                          products: salesController.orderCardList[index]['product_count']);
                      return OrderedCard(
                        order: order,
                        docID: order.orderID.toString(),
                      );
                    },
                  );
      }),
    );
  }
}
