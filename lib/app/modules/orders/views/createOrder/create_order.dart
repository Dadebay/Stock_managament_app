import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/app/modules/orders/views/createOrder/orders_progress_view.dart';
import 'package:stock_managament_app/app/modules/orders/views/createOrder/select_order_products.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/phone_number.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

import '../../../../data/models/product_model.dart';

class CreateOrderView extends StatefulWidget {
  const CreateOrderView({super.key});

  @override
  State<CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<CreateOrderView> {
  List<FocusNode> focusNodes = List.generate(9, (_) => FocusNode());
  final HomeController homeController = Get.find<HomeController>();
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  final SalesController salesController = Get.find<SalesController>();
  final OrderController orderController = Get.put(OrderController());
  String selectedStatus = "Preparing"; // Set an initial value
  List<TextEditingController> textControllers = List.generate(9, (_) => TextEditingController());

  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    salesController.selectedProductsList.clear();
    salesController.productList.clear();
    homeController.agreeButton.value = false;
    super.initState();
  }

  Obx selectedProductsView(BuildContext context) {
    return Obx(() {
      return salesController.selectedProductsList.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: context.padding.verticalNormal,
              child: Wrap(
                children: [
                  Padding(
                    padding: context.padding.normal,
                    child: Text(
                      "selectedProducts".tr,
                      style: context.general.textTheme.titleLarge!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    itemCount: salesController.selectedProductsList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final ProductModel product = salesController.selectedProductsList[index]['product'];
                      return ProductCard(product: product, orderView: false, addCounterWidget: true);
                    },
                  ),
                ],
              ),
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'createOrder'.tr),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        children: [
          CustomTextField(labelName: "date", controller: textControllers[0], focusNode: focusNodes[0], requestfocusNode: focusNodes[1], unFocus: false, readOnly: false),
          selectOrderStatus(context),
          CustomTextField(labelName: "package", controller: textControllers[1], focusNode: focusNodes[1], requestfocusNode: focusNodes[2], unFocus: false, readOnly: true),
          PhoneNumber(mineFocus: focusNodes[2], controller: textControllers[2], requestFocus: focusNodes[3], style: false, unFocus: true),
          CustomTextField(labelName: "userName", controller: textControllers[3], focusNode: focusNodes[3], requestfocusNode: focusNodes[4], unFocus: false, readOnly: true),
          CustomTextField(labelName: "clientAddress", controller: textControllers[4], focusNode: focusNodes[4], requestfocusNode: focusNodes[5], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Coupon", isNumber: true, controller: textControllers[5], focusNode: focusNodes[5], requestfocusNode: focusNodes[6], unFocus: false, readOnly: true),
          CustomTextField(labelName: "Discount", isNumber: true, controller: textControllers[7], focusNode: focusNodes[6], requestfocusNode: focusNodes[7], unFocus: false, readOnly: true),
          CustomTextField(labelName: "note", maxline: 3, controller: textControllers[6], focusNode: focusNodes[7], requestfocusNode: focusNodes[0], unFocus: false, readOnly: true),
          selectedProductsView(context),
          Center(
            child: AgreeButton(
                onTap: () {
                  Get.to(() => const SelectOrderProducts());
                },
                text: 'selectProducts'.tr),
          ),
          Center(
            child: AgreeButton(
                onTap: () {
                  if (textControllers[1].text.isNotEmpty && textControllers[2].text.isNotEmpty && textControllers[3].text.isNotEmpty) {
                    if (salesController.selectedProductsList.isEmpty) {
                      showSnackBar('errorTitle', 'selectMoreProducts', Colors.red);
                    } else {
                      if (homeController.agreeButton.value == false) {
                        Get.to(() => OrderProgressView(textControllers: textControllers, status: selectedStatus));
                      } else {
                        showSnackBar("pleaseWait", "waitMyManSubtitle", Colors.red);
                      }
                    }
                  } else {
                    showSnackBar('errorTitle', 'loginErrorFillBlanks', Colors.red);
                  }
                },
                text: 'agree'),
          ),
          SizedBox(
            height: 30.h,
          ),
        ],
      ),
    );
  }

  Container selectOrderStatus(BuildContext context) {
    return Container(
      margin: context.padding.onlyTopNormal,
      padding: context.padding.normal.copyWith(bottom: 8, top: 8),
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
    );
  }
}
