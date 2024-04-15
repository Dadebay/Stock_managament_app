import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/app/modules/sales/views/select_products_view.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/cards/product_card_with_counter.dart';
import 'package:stock_managament_app/constants/constants.dart';
import 'package:stock_managament_app/constants/custom_text_field.dart';
import 'package:stock_managament_app/constants/phone_number.dart';
import 'package:stock_managament_app/constants/widgets.dart';

import '../../../data/models/product_model.dart';

class CreateOrderView extends StatefulWidget {
  const CreateOrderView({super.key});

  @override
  State<CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<CreateOrderView> {
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  List<TextEditingController> textControllers = List.generate(9, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(9, (_) => FocusNode());
  final SalesController salesController = Get.put(SalesController());
  String selectedStatus = "Preparing"; // Set an initial value
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              IconlyLight.arrowLeftCircle,
              color: Colors.black,
            )),
        title: Text(
          'Create order'.tr,
          style: TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18.sp),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          children: [
            CustomTextField(labelName: "Date", borderRadius: true, controller: textControllers[0], focusNode: focusNodes[0], requestfocusNode: focusNodes[1], unFocus: false, readOnly: false),
            Container(
              margin: EdgeInsets.only(top: 15.h),
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
              decoration: BoxDecoration(
                  borderRadius: borderRadius20, // Add border radius
                  border: Border.all(color: Colors.grey.shade300)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                  items: <String>["Preparing", "Ready to ship", "Shipped", "Canceled", "Refund"].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            CustomTextField(labelName: "Package", borderRadius: true, controller: textControllers[1], focusNode: focusNodes[1], requestfocusNode: focusNodes[2], unFocus: false, readOnly: true),
            PhoneNumber(mineFocus: focusNodes[2], controller: textControllers[2], requestFocus: focusNodes[3], style: false, unFocus: true),
            CustomTextField(labelName: "Client Name", borderRadius: true, controller: textControllers[3], focusNode: focusNodes[3], requestfocusNode: focusNodes[4], unFocus: false, readOnly: true),
            CustomTextField(labelName: "Client Address", borderRadius: true, controller: textControllers[4], focusNode: focusNodes[4], requestfocusNode: focusNodes[5], unFocus: false, readOnly: true),
            CustomTextField(
                labelName: "Coupon",
                isNumber: true,
                tmtValueShow: true,
                borderRadius: true,
                controller: textControllers[5],
                focusNode: focusNodes[5],
                requestfocusNode: focusNodes[6],
                unFocus: false,
                readOnly: true),
            CustomTextField(
                labelName: "Discount",
                isNumber: true,
                tmtValueShow: true,
                borderRadius: true,
                controller: textControllers[7],
                focusNode: focusNodes[6],
                requestfocusNode: focusNodes[7],
                unFocus: false,
                readOnly: true),
            CustomTextField(
                labelName: "Note", borderRadius: true, maxline: 3, controller: textControllers[6], focusNode: focusNodes[7], requestfocusNode: focusNodes[0], unFocus: false, readOnly: true),
            Obx(() {
              return salesController.selectedProductsList.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      itemCount: salesController.selectedProductsList.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final ProductModel product = salesController.selectedProductsList[index]['product'];
                        return ProductCardMine(
                          count: int.parse(salesController.selectedProductsList[index]['count'].toString()),
                          product: product,
                        );
                      },
                    );
            }),
            AgreeButton(
                onTap: () {
                  Get.to(() => const SelectProductsView());
                },
                text: 'Select products'),
            AgreeButton(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    sumbitSale();
                  } else {
                    showSnackBar('Error', 'Please fill the blanks', Colors.red);
                  }

                  showSnackBar("Done", "All missing fields changed", Colors.green);
                },
                text: 'Submit')
          ],
        ),
      ),
    );
  }

  sumbitSale() {
    double sumCost = 0.0;
    double sumPrice = 0.0;
    for (var element in salesController.selectedProductsList) {
      final ProductModel product = element['product'];
      sumCost += double.parse(product.cost.toString()).toDouble() * int.parse(element['count'].toString());
      sumPrice += double.parse(product.sellPrice.toString()).toDouble() * int.parse(element['count'].toString());
      int.parse(product.quantity.toString()) - int.parse(element['count'].toString());
      FirebaseFirestore.instance.collection('products').doc(product.documentID).update({'quantity': int.parse(product.quantity.toString()) - int.parse(element['count'].toString())});
    }
    sumPrice -= double.parse(textControllers[7].text.toString());
    FirebaseFirestore.instance.collection('sales').add({
      'client_address': textControllers[4].text,
      'client_name': textControllers[3].text,
      'client_number': textControllers[2].text,
      'coupon': textControllers[5].text,
      'date': textControllers[0].text,
      'discount': textControllers[7].text,
      'note': textControllers[6].text,
      'package': textControllers[1].text,
      'status': selectedStatus,
      'product_count': salesController.selectedProductsList.length.toString(),
      'sum_price': sumPrice.toString(),
      'sum_cost': sumCost.toString(),
    }).then((value) {
      for (var element in salesController.selectedProductsList) {
        final ProductModel product = element['product'];
        FirebaseFirestore.instance.collection('sales').doc(value.id).collection('products').add({
          'brand': product.brandName,
          'category': product.category,
          'cost': product.cost,
          'gramm': product.gramm,
          'image': product.image,
          'location': product.location,
          'material': product.material,
          'name': product.name,
          'note': product.note,
          'package': product.package,
          'quantity': element['count'],
          'sell_price': product.sellPrice,
        });
      }

      // for (var controller in textControllers) {
      //   controller.clear();
      // }
    });
  }
}
