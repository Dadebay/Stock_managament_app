import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/sales/views/create_order.dart';
import 'package:stock_managament_app/constants/cards/sales_card.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/sales_controller.dart';

enum SortOption { date, price, status }

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  SortOption _selectedSortOption = SortOption.date; // Default sort option

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => const CreateOrderView());
          },
          backgroundColor: kPrimaryColor2,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(
          title: const Text('SalesView'),
          centerTitle: false,
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  IconlyLight.search,
                  color: Colors.black,
                )),
            IconButton(
                onPressed: () {
                  _showSortDialog();
                },
                icon: const Icon(
                  IconlyLight.filter,
                  color: Colors.black,
                )),
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('sales').snapshots(),
            builder: (context, snapshot) {
              print(snapshot.hasData);
              print(snapshot.data);
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return SalesCard(
                      date: snapshot.data!.docs[index]['date'],
                      status: snapshot.data!.docs[index]['status'],
                      productCount: snapshot.data!.docs[index]['date'],
                      clientNumber: snapshot.data!.docs[index]['client_number'],
                      orderSum: snapshot.data!.docs[index]['sum_price'],
                      orderID: snapshot.data!.docs[index].id,
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("No data"),
                );
              }
            }));
  }
}
