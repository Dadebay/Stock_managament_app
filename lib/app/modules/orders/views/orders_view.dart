// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:stock_managament_app/app/data/models/order_model.dart';
// import 'package:stock_managament_app/app/modules/orders/components/order_card.dart';
// import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
// import 'package:stock_managament_app/constants/customWidget/constants.dart';
// import 'package:stock_managament_app/constants/customWidget/widgets.dart';

// class OrdersView extends StatefulWidget {
//   const OrdersView({super.key});

//   @override
//   State<OrdersView> createState() => _OrdersViewState();
// }

// class _OrdersViewState extends State<OrdersView> {
//   final SalesController salesController = Get.put(SalesController());
//   final RefreshController _refreshController = RefreshController(initialRefresh: false);

//   void _onRefresh() async {
//     await salesController.onRefreshController();
//     _refreshController.refreshCompleted();
//   }

//   void _onLoading() async {
//     await salesController.onLoadingController();
//     _refreshController.loadComplete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SmartRefresher(
//       enablePullDown: true,
//       enablePullUp: true,
//       header: const WaterDropHeader(waterDropColor: kPrimaryColor),
//       footer: customFooter(),
//       controller: _refreshController,
//       onRefresh: _onRefresh,
//       onLoading: _onLoading,
//       child: Obx(() {
//         if (salesController.loadingDataOrders.value && salesController.orderCardList.isEmpty) return spinKit();
//         if (salesController.orderCardList.isEmpty) return emptyData();
//         return ListView.builder(
//           itemCount: salesController.orderCardList.length,
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           itemBuilder: (BuildContext context, int index) {
//             final order = OrderModel.fromJson(salesController.orderCardList[index]);
//             return OrderCard(order: order);
//           },
//         );
//       }),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_service.dart';
import 'package:stock_managament_app/app/modules/orders/views/order_card_view.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  TextEditingController searchController = TextEditingController();
  final OrderController orderController = Get.put(OrderController());

  ListView listViewStyle(List<OrderModel> list) {
    return ListView.builder(
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return OrderProductsView(order: list[index]);
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
          orderController.allOrders.assignAll(snapshot.data!);
          orderController.searchResult.assignAll(snapshot.data!);
          orderController.calculateTotals();
          return Obx(() {
            final isSearching = searchController.text.isNotEmpty;
            final hasResult = orderController.searchResult.isNotEmpty;
            final displayList = (isSearching) ? (hasResult ? orderController.searchResult.toList() : <OrderModel>[]) : orderController.allOrders.toList();
            return displayList.isEmpty && isSearching
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
