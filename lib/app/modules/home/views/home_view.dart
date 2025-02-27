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
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        header: const WaterDropHeader(),
        footer: customFooter(),
        child: CustomScrollView(
          slivers: [
            _sliverAppBar(context),
            Obx(() {
              if (_homeController.loadingData.value && _homeController.productsListHomeView.isEmpty) {
                return SliverFillRemaining(
                  child: spinKit(),
                );
              } else if (_homeController.productsListHomeView.isEmpty) {
                return SliverFillRemaining(
                  child: emptyData(),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = ProductModel.fromDocument(_homeController.productsListHomeView[index]);
                      return Padding(
                        padding: context.padding.horizontalNormal,
                        child: ProductCard(product: product, orderView: false, addCounterWidget: false),
                      );
                    },
                    childCount: _homeController.productsListHomeView.length,
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  SliverAppBar _sliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      foregroundColor: Colors.white,
      toolbarHeight: 0.0,
      collapsedHeight: 0.0,
      elevation: 0.0,
      floating: false,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: context.padding.horizontalNormal,
          child: Column(
            children: [
              Obx(() {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ProductCountViewer(
                      totalProducts: _homeController.totalProductCount.toString(),
                      text: 'totalProducts'.tr,
                    ),
                    ProductCountViewer(
                      totalProducts: _homeController.stockInHand.toString(),
                      text: 'stockInHand'.tr,
                    ),
                  ],
                );
              }),
              Divider(color: kPrimaryColor2.withOpacity(.2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'products'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Obx(() => IconButton(
                        onPressed: () async {
                          DialogUtils.filter(context);
                        },
                        icon: const Icon(IconlyLight.filter),
                        color: _homeController.isFiltered.value ? Colors.blue : Colors.black54,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
