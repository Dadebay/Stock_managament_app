import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stock_managament_app/app/modules/home/components/product_count_widget.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_service.dart';
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
  final SearchViewController _searchViewController = Get.find<SearchViewController>();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SearchModel>>(
        future: SearchService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return spinKit();
          } else if (snapshot.hasError) {
            return errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return emptyData();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _searchViewController.historyList.assignAll(snapshot.data!.toList());
            _searchViewController.productsList.assignAll(snapshot.data!.toList());
            _searchViewController.calculateTotals();
          });
          return Obx(() {
            return Column(
              children: [
                Padding(
                  padding: context.padding.horizontalNormal,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductCountViewer(
                            totalProducts: _searchViewController.productsList.length.toString(),
                            text: 'totalProducts'.tr,
                          ),
                          ProductCountViewer(
                            totalProducts: _searchViewController.sumCount.value.toString(),
                            text: 'stockInHand'.tr,
                          ),
                        ],
                      ),
                      Divider(color: kPrimaryColor2.withOpacity(.2)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'products'.tr,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              DialogUtils.filterDialogSearchView(context);
                            },
                            icon: const Icon(IconlyLight.filter),
                            color: Colors.black54,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _searchViewController.productsList.isEmpty
                      ? emptyData()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _searchViewController.productsList.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final product = _searchViewController.productsList[index];
                            return Padding(
                              padding: context.padding.horizontalNormal,
                              child: ProductCard(
                                product: product,
                                orderView: false,
                                addCounterWidget: false,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          });
        });
  }
}
