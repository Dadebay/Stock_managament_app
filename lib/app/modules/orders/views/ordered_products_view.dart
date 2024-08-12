import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/order_model.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrderCardsProfil extends StatefulWidget {
  const OrderCardsProfil({super.key, required this.order, required this.docID});

  final String docID;
  final OrderModel order;

  @override
  State<OrderCardsProfil> createState() => _OrderCardsProfilState();
}

enum SortOptions { preparing, readyToShip, shipped, canceled, refund }

class _OrderCardsProfilState extends State<OrderCardsProfil> {
  Map<String, Color> colorMapping = {"shipped": Colors.green, "canceled": Colors.red, "refund": Colors.red, "preparing": Colors.black, "readyToShip": Colors.purple};
  final SalesController salesController = Get.put(SalesController());
  Map<String, String> statusMapping = {"preparing": 'Preparing', "readyToShip": 'Ready to ship', "shipped": "Shipped", "canceled": "Canceled", "refund": 'Refund'};
  int statusRemover = 0;
  Map<String, SortOptions> statusSortOption = {
    "preparing": SortOptions.preparing,
    "readyToShip": SortOptions.readyToShip,
    "shipped": SortOptions.shipped,
    "canceled": SortOptions.canceled,
    "refund": SortOptions.refund
  };

  SortOptions _selectedSortOption = SortOptions.preparing; // Default sort option

  @override
  void initState() {
    super.initState();
    doStatusFunction(widget.order.status!.toLowerCase());
  }

  doStatusFunction(String status) {
    if (status == 'preparing') {
      _selectedSortOption = SortOptions.preparing;
    } else if (status == 'readyToShip' || status == "ready to ship" || status == "Ready to ship") {
      statusMapping.remove("preparing");
      statusSortOption.remove("preparing");
      _selectedSortOption = SortOptions.readyToShip;
    } else if (status == 'shipped') {
      statusMapping.remove("readyToShip");
      statusSortOption.remove("readyToShip");
      statusMapping.remove("preparing");
      statusSortOption.remove("preparing");
      _selectedSortOption = SortOptions.shipped;
    } else if (status == 'canceled') {
      statusMapping.remove("readyToShip");
      statusSortOption.remove("readyToShip");
      statusMapping.remove("shipped");
      statusSortOption.remove("shipped");
      statusMapping.remove("preparing");
      statusSortOption.remove("preparing");
      _selectedSortOption = SortOptions.canceled;
    } else if (status == 'refund') {
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

  Widget radioButton(SortOptions option, String text) {
    return RadioListTile(
      title: Text(text),
      value: option,
      groupValue: _selectedSortOption,
      onChanged: (SortOptions? value) async {
        if (option == SortOptions.canceled || option == SortOptions.refund) {
          await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).collection('products').get().then((value) async {
            for (var element in value.docs) {
              await FirebaseFirestore.instance.collection('products').where('name', isEqualTo: element['name']).get().then((value2) {
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(value2.docs[0].id)
                    .update({'quantity': int.parse(value2.docs[0]['quantity'].toString()) + int.parse(element['quantity'].toString())});
              });
            }
          });
        }
        _selectedSortOption = value!;
        doStatusFunction(statusMapping[_selectedSortOption.name.toString()].toString());
        FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).update({
          "status": statusMapping[_selectedSortOption.name.toString()].toString(),
        }).then((value) {
          showSnackBar("Done", "Status changed succefully", Colors.green);
        });
        salesController.getData();
        Get.back();
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${"order".tr}   #${widget.docID.substring(0, 5).toString()}'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(IconlyLight.arrowLeftCircle, color: Colors.black)),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID!).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return spinKit();
            } else if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                children: [statusChangeButton(context, 'Name'), textsWidgetsListview(context, snapshot), productsListview()],
              );
            }
            return emptyData();
          }),
    );
  }

  Wrap textsWidgetsListview(BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    return Wrap(
      children: [
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'dateOrder',
            text2: widget.order.date!,
            context: context,
            labelName: 'date',
            ontap: false,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'package',
            text2: snapshot.data!['package'],
            context: context,
            labelName: 'package',
            ontap: true,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'clientNumber',
            text2: snapshot.data!['client_number'],
            context: context,
            labelName: 'client_number',
            ontap: true,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'userName',
            text2: snapshot.data!['client_name'],
            context: context,
            labelName: 'client_name',
            ontap: true,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'clientAddress',
            text2: snapshot.data!['client_address'],
            context: context,
            labelName: 'client_address',
            ontap: true,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'discount',
            text2: snapshot.data!['discount'],
            context: context,
            labelName: 'discount',
            ontap: true,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'priceProduct',
            text2: snapshot.data!['sum_price'].toString(),
            context: context,
            labelName: 'priceProduct',
            ontap: false,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'Coupon',
            text2: snapshot.data!['coupon'].toString() == "" ? '0.0' : snapshot.data!['coupon'].toString(),
            context: context,
            labelName: 'coupon',
            ontap: statusMapping[_selectedSortOption.name.toString()].toString().toLowerCase() == 'shipped' ? false : true,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order, text1: 'note', text2: snapshot.data!['note'], context: context, labelName: 'note', ontap: true, status: statusMapping[_selectedSortOption.name.toString()].toString()),
        textWidgetOrderedPage(
            order: widget.order,
            text1: 'productCount',
            text2: widget.order.products!.toString(),
            context: context,
            labelName: 'Product count',
            ontap: false,
            status: statusMapping[_selectedSortOption.name.toString()].toString()),
      ],
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> productsListview() {
    return StreamBuilder(
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
                  cost: snapshot.data!.docs[index]['cost'].toString(),
                  gramm: snapshot.data!.docs[index]['gramm'].toString(),
                  image: snapshot.data!.docs[index]['image'].toString(),
                  location: snapshot.data!.docs[index]['location'].toString(),
                  material: snapshot.data!.docs[index]['material'].toString(),
                  quantity: snapshot.data!.docs[index]['quantity'],
                  sellPrice: snapshot.data!.docs[index]['sell_price'].toString(),
                  note: snapshot.data!.docs[index]['note'].toString(),
                  package: snapshot.data!.docs[index]['package'].toString(),
                  documentID: snapshot.data!.docs[index].id,
                );
                return ProductCard(
                  product: product,
                  orderView: true,
                  addCounterWidget: false,
                );
              },
            );
          }

          return const Text("No data");
        });
  }
}
