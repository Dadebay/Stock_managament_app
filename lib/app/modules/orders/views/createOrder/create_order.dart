import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_service.dart';
import 'package:stock_managament_app/app/modules/orders/views/createOrder/select_order_products.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/phone_number.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrderCreateView extends StatefulWidget {
  const OrderCreateView({super.key});

  @override
  State<OrderCreateView> createState() => _OrderCreateViewState();
}

class _OrderCreateViewState extends State<OrderCreateView> {
  List<FocusNode> focusNodes = List.generate(9, (_) => FocusNode());
  final SearchViewController _searchController = Get.find<SearchViewController>();

  final OrderController salesController = Get.find<OrderController>();
  String selectedStatus = "Preparing"; // Set an initial value
  List<TextEditingController> textControllers = List.generate(9, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    _searchController.selectedProductsToOrder.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: 'createOrder'.tr),
      body: ListView(
        padding: context.padding.horizontalLow,
        children: [
          CustomTextField(
            onTap: () {
              DateTime? selectedDateTime;
              showDateTimePicker(BuildContext context) async {
                final result = await showDateTimePickerWidget(context: context);
                if (result != null) {
                  setState(() {
                    selectedDateTime = result;
                    textControllers[0].text = DateFormat('yyyy-MM-dd , HH:mm').format(selectedDateTime!);
                  });
                }
              }

              showDateTimePicker(context);
            },
            labelName: "date",
            controller: textControllers[0],
            focusNode: focusNodes[0],
            requestfocusNode: focusNodes[1],
            unFocus: false,
            readOnly: true,
          ),
          Container(
            margin: EdgeInsets.only(top: 15.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(.5), width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                focusColor: Colors.transparent,
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
          CustomTextField(
            labelName: "package",
            controller: textControllers[1],
            focusNode: focusNodes[1],
            requestfocusNode: focusNodes[2],
            unFocus: true,
            readOnly: true,
          ),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  PhoneNumber(
                    mineFocus: focusNodes[2],
                    controller: textControllers[2],
                    requestFocus: focusNodes[3],
                    style: false,
                    unFocus: true,
                  ),
                  CustomTextField(
                    labelName: "userName",
                    controller: textControllers[3],
                    focusNode: focusNodes[3],
                    requestfocusNode: focusNodes[4],
                    unFocus: true,
                    readOnly: true,
                  ),
                ],
              )),
          CustomTextField(
            labelName: "clientAddress",
            controller: textControllers[4],
            focusNode: focusNodes[4],
            requestfocusNode: focusNodes[5],
            unFocus: true,
            readOnly: true,
          ),
          CustomTextField(
            labelName: "Coupon",
            controller: textControllers[5],
            focusNode: focusNodes[5],
            requestfocusNode: focusNodes[6],
            unFocus: true,
            readOnly: true,
          ),
          CustomTextField(
            labelName: "Discount",
            isNumber: true,
            controller: textControllers[7],
            focusNode: focusNodes[6],
            requestfocusNode: focusNodes[7],
            unFocus: true,
            readOnly: true,
          ),
          CustomTextField(
            labelName: "note",
            maxline: 3,
            controller: textControllers[6],
            focusNode: focusNodes[7],
            requestfocusNode: focusNodes[0],
            unFocus: true,
            readOnly: true,
          ),
          selectedProductsView(),
          AgreeButton(
              onTap: () {
                Get.to(() => const SelectOrderProducts());
              },
              text: 'selectProducts'),
          submitOrder(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  AgreeButton submitOrder() {
    return AgreeButton(
        onTap: () async {
          int key = 0;
          for (var status in ListConstants.statusMapping) {
            if (status['name'] == selectedStatus) {
              key = int.parse(status['sortName'].toString());
            }
          }
          List<Map<String, int>> products = [];
          for (var element in _searchController.selectedProductsToOrder) {
            products.add({'id': element['product'].id, 'count': element['count']});
          }

          final isValid = _formKey.currentState?.validate() ?? false;

          if (isValid) {
            final OrderModel model = OrderModel(
              id: 0,
              status: key.toString(),
              date: textControllers[0].text.substring(0, 10),
              gaplama: textControllers[1].text,
              coupon: textControllers[5].text,
              discount: textControllers[7].text,
              description: textControllers[6].text,
              name: "${textControllers[3].text} - ${textControllers[2].text}",
              clientID: 0,
              clientDetailModel: ClientDetailModel(
                id: 0,
                name: textControllers[3].text,
                address: textControllers[4].text,
                phone: textControllers[2].text,
                description: textControllers[6].text,
                ordercount: '',
                sumprice: '',
              ),
              products: [],
              count: _searchController.selectedProductsToOrder.length,
              totalsum: '',
              totalchykdajy: '',
            );
            await OrderService().createOrder(model: model, products: products);
          } else {
            showSnackBar('errorTitle', 'loginErrorFillBlanks', Colors.red);
          }
        },
        text: 'agree');
  }

  Obx selectedProductsView() {
    return Obx(() {
      return _searchController.selectedProductsToOrder.isEmpty
          ? const SizedBox.shrink()
          : Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h, left: 10.w, bottom: 10.h),
                  child: Text(
                    "selectedProducts".tr,
                    style: TextStyle(color: Colors.black, fontSize: 22.sp),
                  ),
                ),
                ListView.builder(
                  itemCount: _searchController.selectedProductsToOrder.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final SearchModel product = _searchController.selectedProductsToOrder[index]['product'];
                    return ProductCard(
                      product: product,
                      addCounterWidget: true,
                      orderView: true,
                    );
                  },
                ),
              ],
            );
    });
  }
}
