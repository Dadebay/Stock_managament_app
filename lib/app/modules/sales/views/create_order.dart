import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_app/app/modules/sales/views/select_products_view.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/cards/product_card_with_counter.dart';
import 'package:stock_managament_app/constants/custom_text_field.dart';
import 'package:stock_managament_app/constants/phone_number.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class CreateOrderView extends StatefulWidget {
  const CreateOrderView({super.key});

  @override
  State<CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<CreateOrderView> {
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  List productsList = [];

  TextEditingController dateTextEditingController = TextEditingController();
  TextEditingController packageTextEditingController = TextEditingController();
  TextEditingController clNumberTextEditingController = TextEditingController();
  TextEditingController clNameTextEditingController = TextEditingController();
  TextEditingController clAddressTextEditingController = TextEditingController();
  TextEditingController couponTextEditingController = TextEditingController();
  TextEditingController noteTextEditingController = TextEditingController();
  TextEditingController discountTextEditingController = TextEditingController();
  FocusNode dateFocusNode = FocusNode();
  FocusNode packageFocusNode = FocusNode();
  FocusNode clNumberFocusNode = FocusNode();
  FocusNode clNameFocusNode = FocusNode();
  FocusNode clAddressFocusNode = FocusNode();
  FocusNode couponFocusNode = FocusNode();
  FocusNode noteFocusNode = FocusNode();
  FocusNode discountFocusNode = FocusNode();
  @override
  void initState() {
    dateTextEditingController.text = DateTime.now().toString().substring(0, 19);
    products.get().then((value) {
      productsList = value.docs;
      setState(() {});
    });
    super.initState();
  }

  final SalesController salesController = Get.put(SalesController());
  String selectedStatus = "preparing"; // Set an initial value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        children: [
          CustomTextField(labelName: "Date", controller: dateTextEditingController, focusNode: dateFocusNode, requestfocusNode: packageFocusNode, isNumber: false, unFocus: false, readOnly: false),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // Add border radius
                border: Border.all(color: Colors.grey.shade300)),
            child: DropdownButton<String>(
              value: selectedStatus,
              onChanged: (newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              items: <String>[
                "preparing",
                "ready to ship",
                "shipped",
                "canceled",
                "refund",
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          CustomTextField(
              labelName: "Package", controller: packageTextEditingController, focusNode: dateFocusNode, requestfocusNode: clNumberFocusNode, isNumber: false, unFocus: false, readOnly: true),
          PhoneNumber(mineFocus: clNumberFocusNode, controller: clNumberTextEditingController, requestFocus: clNameFocusNode, style: false, unFocus: true),
          CustomTextField(
              labelName: "Client Name", controller: clNameTextEditingController, focusNode: clNameFocusNode, requestfocusNode: clAddressFocusNode, isNumber: false, unFocus: false, readOnly: true),
          CustomTextField(
              labelName: "Client Address",
              controller: clAddressTextEditingController,
              focusNode: clAddressFocusNode,
              requestfocusNode: discountFocusNode,
              isNumber: false,
              unFocus: false,
              readOnly: true),
          CustomTextField(
              labelName: "Discount", controller: discountTextEditingController, focusNode: discountFocusNode, requestfocusNode: couponFocusNode, isNumber: false, unFocus: false, readOnly: true),
          CustomTextField(labelName: "Coupon", controller: couponTextEditingController, focusNode: couponFocusNode, requestfocusNode: noteFocusNode, isNumber: false, unFocus: false, readOnly: true),
          CustomTextField(labelName: "Note", controller: noteTextEditingController, focusNode: noteFocusNode, requestfocusNode: dateFocusNode, isNumber: false, unFocus: false, readOnly: true),
          Obx(() {
            return salesController.selectedProductsList.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    itemCount: salesController.selectedProductsList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return ProductCardMine(
                        name: salesController.selectedProductsList[index]['name'],
                        image: salesController.selectedProductsList[index]['image'],
                        price: salesController.selectedProductsList[index]['sell_price'],
                        id: salesController.selectedProductsList[index]['id'],
                        count: int.parse(salesController.selectedProductsList[index]['count'].toString()),
                        brand: salesController.selectedProductsList[index]['brand'],
                        category: salesController.selectedProductsList[index]['category'],
                        location: salesController.selectedProductsList[index]['location'],
                        material: salesController.selectedProductsList[index]['material'],
                        note: salesController.selectedProductsList[index]['note'],
                        package: salesController.selectedProductsList[index]['package'],
                        quantity: salesController.selectedProductsList[index]['quantity'],
                        cost: salesController.selectedProductsList[index]['cost'],
                        gramm: salesController.selectedProductsList[index]['gramm'],
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
                double sumCost = 0.0;
                double sumPrice = 0.0;
                for (var element in salesController.selectedProductsList) {
                  sumCost += double.parse(element['cost'].toString()).toDouble() * int.parse(element['count'].toString());
                  sumPrice += double.parse(element['sell_price'].toString()).toDouble() * int.parse(element['count'].toString());
                }
                print(sumCost);
                print(salesController.selectedProductsList);
                FirebaseFirestore.instance.collection('sales').add({
                  'client_address': clAddressTextEditingController.text,
                  'client_name': clNameTextEditingController.text,
                  'client_number': clNumberTextEditingController.text,
                  'coupon': couponTextEditingController.text,
                  'date': dateTextEditingController.text,
                  'discount': discountTextEditingController.text,
                  'note': noteTextEditingController.text,
                  'package': packageTextEditingController.text,
                  'status': selectedStatus,
                  'sum_price': sumPrice.toString(),
                  'sum_cost': sumCost.toString(),
                });
                showSnackBar("Done", "All missing fields changed", Colors.green);
              },
              text: 'Submit')
        ],
      ),
    );
  }
}
