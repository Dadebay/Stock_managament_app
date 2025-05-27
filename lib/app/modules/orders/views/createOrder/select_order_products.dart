import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_service.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class SelectOrderProducts extends StatefulWidget {
  const SelectOrderProducts({super.key});

  @override
  State<SelectOrderProducts> createState() => _SelectOrderProductsState();
}

class _SelectOrderProductsState extends State<SelectOrderProducts> {
  TextEditingController controller = TextEditingController();
  final SearchViewController _searchViewController = Get.find<SearchViewController>();

  List<SearchModel> _searchResult = [];

  void onSearchTextChanged(String word) {
    _searchResult.clear();
    if (word.isEmpty) {
      _searchResult.assignAll(_searchViewController.productsList);
      return;
    }
    List<String> words = word.trim().toLowerCase().split(' ');
    _searchResult = _searchViewController.productsList.where((product) {
      final name = product.name.toLowerCase();
      final price = product.price.toLowerCase();

      return words.every((w) => name.contains(w) || price.contains(w));
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'selectProducts'),
        body: Column(
          children: [
            searchWidget(context),
            Expanded(
                child: FutureBuilder<List<SearchModel>>(
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
                        return _searchViewController.productsList.isEmpty
                            ? emptyData()
                            : _searchResult.isEmpty && controller.text.isNotEmpty
                                ? emptyData()
                                : controller.text.isEmpty
                                    ? ListView.builder(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        itemCount: _searchViewController.productsList.length,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final product = _searchViewController.productsList[index];
                                          return Padding(
                                            padding: context.padding.horizontalNormal,
                                            child: ProductCard(
                                              product: product,
                                              orderView: true,
                                              addCounterWidget: true,
                                            ),
                                          );
                                        },
                                      )
                                    : _searchResults(context);
                      });
                    })),
          ],
        ));
  }

  ListView _searchResults(BuildContext context) {
    return ListView.builder(
      padding: context.padding.horizontalNormal,
      itemCount: _searchResult.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, i) {
        return ProductCard(
          product: _searchResult[i],
          orderView: false,
          addCounterWidget: true,
        );
      },
    );
  }

  Widget searchWidget(BuildContext context) {
    return Padding(
      padding: context.padding.normal,
      child: ListTile(
        leading: const Icon(
          IconlyLight.search,
          color: Colors.black,
        ),
        tileColor: Colors.grey.withOpacity(.2),
        shape: RoundedRectangleBorder(
          borderRadius: context.border.normalBorderRadius,
          side: BorderSide(color: kPrimaryColor2.withOpacity(.4)),
        ),
        title: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'search'.tr, hintStyle: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey, fontSize: 20), border: InputBorder.none),
          onChanged: onSearchTextChanged,
        ),
        contentPadding: EdgeInsets.only(left: 15.w),
        trailing: IconButton(
          icon: const Icon(CupertinoIcons.xmark_circle),
          onPressed: () {
            controller.clear();
            onSearchTextChanged('');
          },
        ),
      ),
    );
  }
}
