// // ignore_for_file: file_names, must_be_immutable, always_use_package_imports, avoid_void_async, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/app/modules/orders/views/createOrder/create_order.dart';
import 'package:stock_managament_app/app/modules/orders/views/ordered_cards_view.dart';
import 'package:stock_managament_app/app/modules/search/views/search_view.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

import 'home_view.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  List page = [];
  int selectedIndex = 0;
  final SalesController _salesController = Get.put(SalesController());

  Future<dynamic> filter() {
    return Get.bottomSheet(Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Wrap(
        children: [
          filterTextWidget('filter'.tr),
          ListView.builder(
            itemCount: _salesController.statuses.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  _salesController.sortSalesCards(index);
                },
                title: Text(_salesController.statuses[index]),
                trailing: const Icon(IconlyLight.arrowRightCircle),
              );
            },
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backArrow: false,
        actionIcon: true,
        icon: selectedIndex == 0
            ? IconButton(onPressed: () => Get.to(() => const SearchView(whereToSearch: 'products')), icon: const Icon(IconlyLight.search))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(onPressed: () => Get.to(() => const SearchView(whereToSearch: 'orders')), icon: const Icon(IconlyLight.search, color: Colors.black)),
                IconButton(onPressed: () => filter(), icon: const Icon(IconlyLight.filter, color: Colors.black)),
              ]),
        name: selectedIndex == 1 ? 'sales' : "products",
      ),
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => Get.to(() => const CreateOrderView()),
              backgroundColor: kPrimaryColor2,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : const SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        iconSize: 22,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: kPrimaryColor2,
        useLegacyColorScheme: true,
        selectedLabelStyle: const TextStyle(fontFamily: gilroySemiBold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontFamily: gilroyMedium, fontSize: 12),
        currentIndex: selectedIndex,
        onTap: (index) async => setState(() => selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(IconlyLight.home),
            activeIcon: const Icon(IconlyBold.home),
            label: 'home'.tr,
            tooltip: 'home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(IconlyLight.chart),
            activeIcon: const Icon(IconlyBold.chart),
            label: 'sales'.tr,
            tooltip: 'sales'.tr,
          ),
        ],
      ),
      body: Center(
        child: selectedIndex == 0 ? const HomeView() : const OrdersView(),
      ),
    );
  }
}
