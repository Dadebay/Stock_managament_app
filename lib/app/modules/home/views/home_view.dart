import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/api_constants.dart';
import 'package:stock_managament_app/app/modules/home/components/product_count_widget.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_service.dart';
import 'package:stock_managament_app/app/modules/product/views/product_profil_view.dart';
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
            _searchViewController.sortProductsByDate();
            _searchViewController.calculateTotals();
          });
          return Obx(() {
            final headerContent = Padding(
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _searchViewController.toggleViewMode();
                            },
                            icon: Icon(
                              _searchViewController.isGridView.value ? IconlyLight.category : IconlyLight.document,
                            ),
                            color: Colors.black54,
                          ),
                          IconButton(
                            onPressed: () {
                              DialogUtils.filterDialogSearchView(context);
                            },
                            icon: const Icon(IconlyLight.filter),
                            color: Colors.black54,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            );

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false,
                  elevation: 0,
                  scrolledUnderElevation: 0.0,
                  foregroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 0,
                  expandedHeight: 190,
                  flexibleSpace: FlexibleSpaceBar(
                    background: SafeArea(
                      bottom: false,
                      child: headerContent,
                    ),
                  ),
                ),
                if (_searchViewController.productsList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: emptyData(),
                  )
                else if (_searchViewController.isGridView.value)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = _searchViewController.productsList[index];
                          String url = '';
                          if (product.img != null && product.img!.contains(ApiConstants.imageURL)) {
                            url = product.img!;
                          } else if (product.img != null) {
                            url = ApiConstants.imageURL2 + product.img!;
                          }
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => ProductProfilView(product: product));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 3,
                                    spreadRadius: 2,
                                  )
                                ],
                                border: Border.all(color: kPrimaryColor2.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: url.isEmpty
                                          ? Container(
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: Icon(IconlyLight.image, size: 40, color: Colors.grey),
                                              ),
                                            )
                                          : Image.network(
                                              url,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Center(
                                                    child: Icon(IconlyLight.image, size: 40, color: Colors.grey),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.price,
                                          style: TextStyle(
                                            color: kPrimaryColor2,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'count'.tr + ': ${product.count}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: _searchViewController.productsList.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        childCount: _searchViewController.productsList.length,
                      ),
                    ),
                  ),
              ],
            );
          });
        });
  }
}
