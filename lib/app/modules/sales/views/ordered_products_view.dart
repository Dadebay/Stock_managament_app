import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class SalesProductView extends StatefulWidget {
  final OrderModel order;
  final String docID;

  const SalesProductView({super.key, required this.order, required this.docID});

  @override
  State<SalesProductView> createState() => _SalesProductViewState();
}

enum SortOptions { preparing, readyToShip, shipped, canceled, refund }

class _SalesProductViewState extends State<SalesProductView> {
  SortOptions _selectedSortOption = SortOptions.preparing; // Default sort option
  Map<String, Color> colorMapping = {"shipped": Colors.green, "canceled": Colors.red, "refund": Colors.red, "preparing": Colors.black, "readyToShip": Colors.purple};
  Map<String, String> statusMapping = {"preparing": 'Preparing', "readyToShip": 'Ready to ship', "shipped": "Shipped", "canceled": "Canceled", "refund": 'Refund'};
  Map<String, SortOptions> statusSortOption = {
    "preparing": SortOptions.preparing,
    "readyToShip": SortOptions.readyToShip,
    "shipped": SortOptions.shipped,
    "canceled": SortOptions.canceled,
    "refund": SortOptions.refund
  };
  int statusRemover = 0;
  @override
  void initState() {
    print(widget.order.orderID);
    super.initState();
    if (widget.order.status!.toLowerCase() == 'preparing') {
      _selectedSortOption = SortOptions.preparing;
    } else if (widget.order.status!.toLowerCase() == 'readyToShip' || widget.order.status!.toLowerCase() == "ready to ship") {
      statusMapping.remove("preparing");
      statusSortOption.remove("preparing");
      _selectedSortOption = SortOptions.readyToShip;
    } else if (widget.order.status!.toLowerCase() == 'shipped') {
      statusMapping.remove("readyToShip");
      statusSortOption.remove("readyToShip");
      statusMapping.remove("preparing");
      statusSortOption.remove("preparing");
      _selectedSortOption = SortOptions.shipped;
    } else if (widget.order.status!.toLowerCase() == 'canceled') {
      statusMapping.remove("readyToShip");
      statusSortOption.remove("readyToShip");
      statusMapping.remove("shipped");
      statusSortOption.remove("shipped");
      statusMapping.remove("preparing");
      statusSortOption.remove("preparing");
      _selectedSortOption = SortOptions.canceled;
    } else if (widget.order.status!.toLowerCase() == 'refund') {
      statusMapping.remove("readyToShip");
      statusSortOption.remove("readyToShip");
      statusMapping.remove("shipped");
      statusSortOption.remove("shipped");
      statusMapping.remove("preparing");
      statusSortOption.remove("preparing");
      statusMapping.remove("canceled");
      statusSortOption.remove("canceled");
      _selectedSortOption = SortOptions.refund;
    }
    setState(() {});
  }

  final SalesController salesController = Get.put(SalesController());

  Widget radioButton(SortOptions option, String text) {
    return RadioListTile(
      title: Text(text),
      value: option,
      groupValue: _selectedSortOption,
      onChanged: (SortOptions? value) {
        _selectedSortOption = value!;
        setState(() {});
        FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).update({
          "status": statusMapping[_selectedSortOption.name.toString()].toString(),
        }).then((value) {
          showSnackBar("Done", "Status changed succefully", Colors.green);
        });
        setState(() {});
        salesController.collectionReference.orderBy("date", descending: true).get();
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${"order".tr}   #${widget.docID.toString()}'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(IconlyLight.arrowLeftCircle, color: Colors.black)),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        children: [
          statusChangeButton(context, 'Name'),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'dateOrder',
              text2: widget.order.date!,
              context: context,
              labelName: 'date',
              ontap: false,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'package',
              text2: widget.order.package!,
              context: context,
              labelName: 'package',
              ontap: true,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'clientNumber',
              text2: widget.order.clientNumber!,
              context: context,
              labelName: 'client_number',
              ontap: true,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'userName',
              text2: widget.order.clientName!,
              context: context,
              labelName: 'client_name',
              ontap: true,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'clientAddress',
              text2: widget.order.clientAddress!,
              context: context,
              labelName: 'client_address',
              ontap: true,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'discount',
              text2: widget.order.discount!,
              context: context,
              labelName: 'discount',
              ontap: true,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'priceProduct',
              text2: widget.order.sumPrice!,
              context: context,
              labelName: 'Sum Price',
              ontap: false,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'note',
              text2: widget.order.note!,
              context: context,
              labelName: 'note',
              ontap: true,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          textWidgetOrderedPage(
              documentID: widget.order.orderID!,
              text1: 'productCount',
              text2: widget.order.products!.toString(),
              context: context,
              labelName: 'Product count',
              ontap: false,
              status: statusMapping[_selectedSortOption.name.toString()].toString()),
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return spinKit();
                } else if (snapshot.hasError) {
                  return errorData();
                } else if (snapshot.data!.docs.isEmpty) {
                  return emptyData();
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final product = ProductModel(
                        name: snapshot.data!.docs[index]['name'],
                        brandName: snapshot.data!.docs[index]['brand'].toString(),
                        category: snapshot.data!.docs[index]['category'].toString(),
                        cost: snapshot.data!.docs[index]['cost'],
                        gramm: snapshot.data!.docs[index]['gramm'],
                        image: snapshot.data!.docs[index]['image'].toString(),
                        location: snapshot.data!.docs[index]['location'].toString(),
                        material: snapshot.data!.docs[index]['material'].toString(),
                        quantity: snapshot.data!.docs[index]['quantity'],
                        sellPrice: snapshot.data!.docs[index]['sell_price'].toString(),
                        note: snapshot.data!.docs[index]['note'].toString(),
                        package: snapshot.data!.docs[index]['package'].toString(),
                        documentID: snapshot.data!.docs[index].id,
                      );
                      return ProductCard(product: product, orderView: true);
                    },
                  );
                }

                return const Text("No data");
              })
        ],
      ),
    );
  }

  GestureDetector statusChangeButton(BuildContext context, String labelName) {
    return GestureDetector(
      onTap: () {
        statusChangeDialog(context);
      },
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "status".tr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontFamily: gilroyMedium, fontSize: 14.sp),
                ),
                Text(
                  statusMapping[_selectedSortOption.name.toString()].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorMapping[_selectedSortOption.name], fontFamily: gilroyBold, fontSize: 16.sp),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.grey.shade200,
          )
        ],
      ),
    );
  }

  Future<dynamic> statusChangeDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          title: Text(
            'Status',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 20.sp),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusMapping.entries.map(
              (e) {
                String a = e.value.toLowerCase();
                if (a == "Ready to ship") a = "readyToShip";
                return radioButton(statusSortOption[a == "ready to ship" ? 'readyToShip' : a] ?? SortOptions.readyToShip, e.value);
              },
            ).toList(),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(fontFamily: gilroyMedium, fontSize: 18.sp),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(fontFamily: gilroyBold, fontSize: 18.sp),
              ),
              onPressed: () {
                FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).update({
                  "status": statusMapping[_selectedSortOption.name.toString()].toString(),
                }).then((value) {
                  showSnackBar("Done", "Status changed succefully", Colors.green);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
