import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/modules/sales/views/create_order.dart';
import 'package:stock_managament_app/app/modules/search/views/search_view.dart';
import 'package:stock_managament_app/constants/cards/sales_card.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_managament_app/constants/custom_app_bar.dart';

enum SortOption { date, price, status }

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  SortOption _selectedSortOption = SortOption.date;

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sort by',
            style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 20.sp),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              radioButton(SortOption.date, 'Date'),
              radioButton(SortOption.price, 'Price'),
              radioButton(SortOption.status, 'Status'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sort'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder radioButton(SortOption option, String text) {
    return StatefulBuilder(builder: (context, setState) {
      return RadioListTile(
        title: Text(text),
        value: option,
        groupValue: _selectedSortOption,
        onChanged: (SortOption? value) {
          setState(() {
            _selectedSortOption = value!;
            Get.back();
          });
        },
      );
    });
  }

  bool onRefresh = false;
  Future<Null> _refreshLocalGallery() async {
    print('refreshing stocks...');
    onRefresh = true;
    setState(() {});
    Future.delayed(const Duration(seconds: 1), () {
      onRefresh = false;
      setState(() {});
    });
    print(onRefresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => const CreateOrderView());
          },
          backgroundColor: kPrimaryColor2,
          child: const Icon(Icons.add, color: Colors.white)),
      appBar: appBar(),
      body: RefreshIndicator(
        onRefresh: _refreshLocalGallery,
        child: onRefresh
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : FirestoreListView<Map<String, dynamic>>(
                query: FirebaseFirestore.instance.collection('sales').orderBy("date", descending: true),
                pageSize: 3,
                shrinkWrap: true,
                showFetchingIndicator: true,
                fetchingIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
                emptyBuilder: (context) => const Text('No data'),
                errorBuilder: (context, error, stackTrace) => Text(error.toString()),
                loadingBuilder: (context) => const Center(
                    child: CircularProgressIndicator(
                  color: Colors.amber,
                )),
                itemBuilder: (context, doc) {
                  Map<String, dynamic> user = doc.data();
                  final order = OrderModel(
                      orderID: doc.id,
                      clientAddress: user['client_address'],
                      clientName: user['client_name'],
                      clientNumber: user['client_number'],
                      coupon: user['coupon'],
                      date: user['date'],
                      discount: user['discount'],
                      note: user['note'],
                      package: user['package'],
                      status: user['status'],
                      sumCost: user['sum_cost'],
                      sumPrice: user['sum_price'],
                      products: user['product_count']);
                  return SalesCard(
                    docID: doc.id,
                    order: order,
                  );
                },
              ),
      ),
    );
  }

  CustomAppBar appBar() {
    return CustomAppBar(
        backArrow: false,
        actionIcon: true,
        centerTitle: false,
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  Get.to(() => SearchView(
                        productList: const [],
                        whereToSearch: 'orders',
                        collectionReference: FirebaseFirestore.instance.collection('sales'),
                      ));
                },
                icon: const Icon(IconlyLight.search, color: Colors.black)),
            IconButton(
                onPressed: () {
                  _showSortDialog();
                },
                icon: const Icon(IconlyLight.filter, color: Colors.black)),
          ],
        ),
        name: "sales");
  }
}
