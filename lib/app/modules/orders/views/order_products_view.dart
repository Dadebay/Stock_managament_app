import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrderProductsView extends StatefulWidget {
  const OrderProductsView({
    super.key,
    required this.order,
  });

  final OrderModel order;

  @override
  State<OrderProductsView> createState() => _OrderProductsViewState();
}

class _OrderProductsViewState extends State<OrderProductsView> {
  final SalesController salesController = Get.put(SalesController());
  SortOptions _selectedSortOption = SortOptions.preparing;
  late OrderModel orderData;
  @override
  void initState() {
    super.initState();
    orderData = widget.order;

    _updateStatus(orderData.status.toLowerCase());
  }

  void _updateStatus(String status) {
    setState(() {
      _selectedSortOption = _getSortOptionFromStatus(status);
    });
  }

  SortOptions _getSortOptionFromStatus(String status) {
    switch (status) {
      case 'readyToShip':
      case 'ready to ship':
      case 'Ready to ship':
        return SortOptions.readyToShip;
      case 'shipped':
        return SortOptions.shipped;
      case 'canceled':
        return SortOptions.canceled;
      case 'refund':
        return SortOptions.refund;
      default:
        return SortOptions.preparing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backArrow: true,
        miniTitle: true,
        centerTitle: true,
        actionIcon: false,
        name: '${"order".tr}  -  ${orderData.clientDetailModel!.name}',
      ),
      // body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      //   stream: FirebaseFirestore.instance.collection('sales').doc(orderData.orderID).snapshots(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return spinKit();
      //     } else if (snapshot.hasData) {
      //       return ListView(
      //         padding: context.padding.horizontalNormal,
      //         children: [
      //           _buildStatusChangeButton(context),
      //           Divider(color: Colors.grey.shade200),
      //           _buildOrderDetails(snapshot.data!),
      //           _buildProductList(),
      //           SizedBox(
      //             height: context.padding.onlyBottomMedium.vertical,
      //           )
      //         ],
      //       );
      //     }
      //     return emptyData();
      //   },
      // ),
    );
  }

  Widget _buildStatusChangeButton(BuildContext context) {
    Future<void> showStatusChangeDialog(BuildContext context) async {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.center,
          title: Text('Status', textAlign: TextAlign.center, style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ListConstants.statusMapping.entries.map((entry) {
              final status = entry.key.toLowerCase();
              return RadioListTile(
                title: Text(entry.value),
                value: _getSortOptionFromStatus(status),
                groupValue: _selectedSortOption,
                onChanged: (value) {
                  setState(() => _selectedSortOption = value!);
                  // salesController.updateOrderStatus(value!, orderData.orderID);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // salesController.updateOrderStatus(_selectedSortOption, orderData.orderID);
                Navigator.pop(context);
              },
              child: Text('OK', style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => showStatusChangeDialog(context),
      child: Container(
        color: Colors.white,
        padding: context.padding.verticalLow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "status".tr,
              style: context.general.textTheme.titleMedium!.copyWith(color: Colors.grey.withOpacity(.6), fontWeight: FontWeight.bold),
            ),
            Text(
              ListConstants.statusMapping[_selectedSortOption.name]!,
              style: context.general.textTheme.titleMedium!.copyWith(color: ListConstants.colorMapping[_selectedSortOption.name], fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    List values = [orderData.date, snapshot['package'], '${snapshot['client_number']}', snapshot['client_name'], snapshot['client_address'], '${snapshot['discount']}%', snapshot['sum_price'], snapshot['coupon'], snapshot['note'], orderData.products.toString()];

    Future<void> showEditDialog(String field, String currentValue) async {
      final controller = TextEditingController(text: currentValue);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(field.tr, style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
          content: CustomTextField(
            labelName: field,
            controller: controller,
            focusNode: FocusNode(),
            requestfocusNode: FocusNode(),
            unFocus: false,
            readOnly: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('no'.tr, style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                print(field);

                // await FirebaseFirestore.instance.collection('sales').doc(orderData.orderID).update({field: controller.text});
                showSnackBar("Success", "Field updated successfully", Colors.green);
                Navigator.pop(context);
              },
              child: Text('yes'.tr, style: context.general.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: values.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (ListConstants.fieldNames[index]['value'] == true) {
              showEditDialog(ListConstants.fieldNames[index]['field'].toString(), values[index].toString());
            }
          },
          child: Container(
            color: Colors.white,
            padding: context.padding.verticalNormal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 1, child: Text(ListConstants.fieldNames[index]['field'].toString().tr, overflow: TextOverflow.ellipsis, maxLines: 1, style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey.withOpacity(.5), fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text(values[index].toString(), textAlign: TextAlign.end, maxLines: 3, style: context.general.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.grey.shade200,
        );
      },
    );
  }

  // Widget _buildProductList() {
  //   // return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  //   //   stream: FirebaseFirestore.instance.collection('sales').doc(orderData.orderID).collection('products').snapshots(),
  //   //   builder: (context, snapshot) {
  //   //     if (snapshot.connectionState == ConnectionState.waiting) {
  //   //       return spinKit();
  //   //     } else if (snapshot.hasError) {
  //   //       return errorData();
  //   //     } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //   //       return emptyData();
  //   //     } else {
  //   //       return ListView.builder(
  //   //         shrinkWrap: true,
  //   //         scrollDirection: Axis.vertical,
  //   //         itemCount: snapshot.data!.docs.length,
  //   //         physics: const NeverScrollableScrollPhysics(),
  //   //         itemBuilder: (context, index) {
  //   //           return null;

  //   //           // final product = SearchModel.fromDocument(snapshot.data!.docs[index]);
  //   //           // return ProductCard(
  //   //           //   product: product,
  //   //           //   orderView: true,
  //   //           //   addCounterWidget: false,
  //   //           // );
  //   //         },
  //   //       );
  //   //     }
  //   //   },
  //   // );
  // }
}
