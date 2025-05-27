// // ignore_for_file: file_names, must_be_immutable, always_use_package_imports, avoid_void_async, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/modules/orders/views/createOrder/create_order.dart';
import 'package:stock_managament_app/app/modules/search/views/search_view.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/app/product/utils/dialog_utils.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final SearchViewController _searchViewController = Get.find();
  final storage = GetStorage();
  int selectedIndex = 0;
  late final bool isAdmin;

  @override
  void initState() {
    super.initState();
    isAdmin = storage.read('isAdmin') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const OrderCreateView()),
        backgroundColor: kPrimaryColor2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 5,
        iconSize: 22,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: kPrimaryColor2,
        useLegacyColorScheme: true,
        selectedLabelStyle: context.general.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: context.textTheme.bodyLarge,
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: buildBottomNavItems(),
      ),
      body: isAdmin ? ListConstants.adminPages[selectedIndex] : ListConstants.pages[selectedIndex],
    );
  }

  final OrderController orderController = Get.find<OrderController>();

  /// 🔹 AppBar Builder
  PreferredSizeWidget buildAppBar(BuildContext context) {
    final isSalesPage = selectedIndex == 1;
    final isHomePage = selectedIndex == 0;

    return CustomAppBar(
      backArrow: false,
      centerTitle: true,
      actionIcon: isHomePage || isSalesPage,
      icon: isHomePage
          ? _homeIcons()
          : isSalesPage
              ? _ordersIcons()
              : null,
      leadingWidget: isSalesPage
          ? IconButton(
              icon: const Icon(Icons.refresh, color: kPrimaryColor),
              onPressed: () {
                orderController.onRefreshController();
              },
            )
          : null,
      name: isAdmin ? ListConstants.adminName[selectedIndex] : ListConstants.names[selectedIndex],
    );
  }

  /// 🔹 Home sayfası action iconları
  Widget _homeIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh, color: kPrimaryColor),
          onPressed: () => _searchViewController.onRefreshController(),
        ),
        IconButton(
          icon: const Icon(IconlyLight.search),
          onPressed: () => Get.to(() => const SearchView()),
        ),
      ],
    );
  }

  /// 🔹 Sales sayfası action iconları
  Row _ordersIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(IconlyLight.search, color: Colors.black),
          onPressed: () => Get.to(() => const OrderSearchView()),
        ),
        IconButton(
          icon: const Icon(IconlyLight.filter, color: Colors.black),
          onPressed: () => DialogUtils.orderFilterDialog(),
        ),
      ],
    );
  }

  /// 🔹 Alt menü butonları
  List<BottomNavigationBarItem> buildBottomNavItems() {
    final items = [
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
      BottomNavigationBarItem(
        icon: const Icon(IconlyLight.setting),
        activeIcon: const Icon(IconlyBold.setting),
        label: 'settings'.tr,
        tooltip: 'settings'.tr,
      ),
    ];

    if (isAdmin) {
      items.insert(
        2,
        BottomNavigationBarItem(
          icon: const Icon(IconlyLight.chat),
          activeIcon: const Icon(IconlyBold.chat),
          label: 'SMS'.tr,
          tooltip: 'SMS'.tr,
        ),
      );
    }

    return items;
  }
}
