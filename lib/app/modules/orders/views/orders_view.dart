import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/orders/components/order_card.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_service.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  TextEditingController searchController = TextEditingController();
  final OrderController orderController = Get.find<OrderController>();

  Widget listViewStyle(List<OrderModel> list) {
    return ListView.builder(
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return OrderCard(order: list[index]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<OrderModel>>(
        future: OrderService().getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return spinKit();
          } else if (snapshot.hasError) {
            return errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return emptyData();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            orderController.allOrders.assignAll(snapshot.data!);
            orderController.searchResult.assignAll(snapshot.data!);
            orderController.calculateTotals();
          });
          return Obx(() {
            final isSearching = searchController.text.isNotEmpty;
            final hasResult = orderController.searchResult.isNotEmpty;
            final displayList = (isSearching) ? (hasResult ? orderController.searchResult.toList() : <OrderModel>[]) : orderController.allOrders.toList();
            return orderController.loading.value == true
                ? spinKit()
                : displayList.isEmpty && isSearching
                    ? Center(child: Text("No results found for '${searchController.text}'"))
                    : displayList.isEmpty
                        ? emptyData()
                        : listViewStyle(displayList);
          });
        },
      ),
    );
  }
}
