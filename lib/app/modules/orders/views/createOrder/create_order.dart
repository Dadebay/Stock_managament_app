import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
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
  final HomeController homeController = Get.put(HomeController());
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  final SalesController salesController = Get.put(SalesController());
  String selectedStatus = "Preparing"; // Set an initial value
  List<TextEditingController> textControllers = List.generate(9, (_) => TextEditingController());

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    salesController.selectedProductsList.clear();
    salesController.productList.clear();
    homeController.agreeButton.value = false;
    super.initState();
  }

  Obx selectedProductsView() {
    return Obx(() {
      return salesController.selectedProductsList.isEmpty
          ? const SizedBox.shrink()
          : Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h, left: 10.w, bottom: 10.h),
                  child: Text(
                    "selectedProducts".tr,
                    style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 22.sp),
                  ),
                ),
                ListView.builder(
                  itemCount: salesController.selectedProductsList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final ProductModel product = salesController.selectedProductsList[index]['product'];
                    return ProductCard(product: product, orderView: false, addCounterWidget: true);
                  },
                ),
              ],
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'createOrder'.tr),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        children: [
          CustomTextField(labelName: "date", borderRadius: true, controller: textControllers[0], focusNode: focusNodes[0], requestfocusNode: focusNodes[1], unFocus: false, readOnly: false),
          selectOrderStatus(),
          CustomTextField(labelName: "package", borderRadius: true, controller: textControllers[1], focusNode: focusNodes[1], requestfocusNode: focusNodes[2], unFocus: false, readOnly: true),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  PhoneNumber(mineFocus: focusNodes[2], controller: textControllers[2], requestFocus: focusNodes[3], style: false, unFocus: true),
                  CustomTextField(labelName: "userName", borderRadius: true, controller: textControllers[3], focusNode: focusNodes[3], requestfocusNode: focusNodes[4], unFocus: false, readOnly: true),
                ],
              )),
          CustomTextField(labelName: "clientAddress", borderRadius: true, controller: textControllers[4], focusNode: focusNodes[4], requestfocusNode: focusNodes[5], unFocus: false, readOnly: true),
          CustomTextField(
              labelName: "Coupon", isNumber: true, borderRadius: true, controller: textControllers[5], focusNode: focusNodes[5], requestfocusNode: focusNodes[6], unFocus: false, readOnly: true),
          CustomTextField(
              labelName: "Discount", isNumber: true, borderRadius: true, controller: textControllers[7], focusNode: focusNodes[6], requestfocusNode: focusNodes[7], unFocus: false, readOnly: true),
          CustomTextField(labelName: "note", borderRadius: true, maxline: 3, controller: textControllers[6], focusNode: focusNodes[7], requestfocusNode: focusNodes[0], unFocus: false, readOnly: true),
          selectedProductsView(),
          GestureDetector(
              onTap: () {
                Get.to(() => const SelectOrderProducts());
              },
              child: AnimatedContainer(
                decoration: const BoxDecoration(borderRadius: borderRadius20, color: kPrimaryColor2),
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8.h),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.h),
                width: Get.size.width,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  'selectProducts'.tr,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
                ),
              )),
          Center(
            child: AgreeButton(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    if (salesController.selectedProductsList.isEmpty) {
                      showSnackBar('errorTitle', 'selectMoreProducts', Colors.red);
                    } else {
                      if (homeController.agreeButton.value == false) {
                        homeController.agreeButton.value = true;

                        showSnackBar("error", "submit sale gidip dur garas sykla", Colors.green);
                        salesController.sumbitSale(textControllers: textControllers, context: context, status: selectedStatus);
                      } else {
                        showSnackBar("wait", "waitMyManSubtitle", Colors.red);
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

  Container selectOrderStatus() {
    return Container(
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
    );
  }
}
