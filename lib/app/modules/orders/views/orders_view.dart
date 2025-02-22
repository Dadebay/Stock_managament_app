import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/modules/orders/components/order_card.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final SalesController salesController = Get.put(SalesController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await salesController.onRefreshController();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await salesController.onLoadingController();
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
      child: Obx(() {
        if (salesController.loadingDataOrders.value) return spinKit();
        if (salesController.orderCardList.isEmpty) return emptyData();
        return ListView.builder(
          itemCount: salesController.orderCardList.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final order = OrderModel.fromJson(salesController.orderCardList[index]);
            return OrderCard(order: order);
          },
        );
      }),
    );
  }
}
