import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/home/components/product_count_widget.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/product/utils/dialog_utils.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.put(HomeController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  Future<void> _onRefresh() async {
    await _homeController.onRefreshController();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await _homeController.onLoadingController();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padding.horizontalNormal,
      child: Column(
        children: [
          Obx(() {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ProductCountViewer(totalProducts: _homeController.totalProductCount.toString(), text: 'totalProducts'.tr),
                ProductCountViewer(totalProducts: _homeController.stockInHand.toString(), text: 'stockInHand'.tr),
              ],
            );
          }),
          Divider(color: kPrimaryColor2.withOpacity(.2)),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'products'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    DialogUtils.filter();
                  },
                  icon: const Icon(IconlyLight.filter),
                  color: _homeController.isFiltered.value ? Colors.blue : Colors.black54,
                ),
              ],
            );
          }),
          Expanded(
            flex: 3,
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              header: const WaterDropHeader(),
              footer: customFooter(),
              child: Obx(() {
                if (_homeController.loadingData.value) {
                  return spinKit();
                } else if (_homeController.productsListHomeView.isEmpty) {
                  return emptyData();
                } else {
                  return ListView.separated(
                    itemCount: _homeController.productsListHomeView.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final product = ProductModel.fromDocument(_homeController.productsListHomeView[index]);
                      return ProductCard(product: product, orderView: false, addCounterWidget: false);
                    },
                    separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey.shade200),
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}
