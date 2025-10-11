import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kartal/kartal.dart';
import 'package:stock_managament_app/app/modules/home/controllers/search_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_controller.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/order_service.dart';
import 'package:stock_managament_app/app/product/constants/list_constants.dart';
import 'package:stock_managament_app/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_app/constants/cards/product_card.dart';
import 'package:stock_managament_app/constants/customWidget/custom_app_bar.dart';
import 'package:stock_managament_app/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_app/constants/customWidget/widgets.dart';

class OrderProductsView extends StatefulWidget {
  const OrderProductsView({super.key, required this.order});

  final OrderModel order;

  @override
  State<OrderProductsView> createState() => _OrderProductsViewState();
}

class _OrderProductsViewState extends State<OrderProductsView> {
  final OrderController orderController = Get.find<OrderController>();

  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  List<Map<String, dynamic>> buildOrderDetailsFields(OrderModel order) {
    return [
      {'label': 'status', 'editable': true},
      {'label': 'date', 'editable': true},
      {'label': 'clientName', 'editable': true}, // Bu alan için sorun yaşanıyor
      {'label': 'phone', 'editable': true},
      {'label': 'address', 'editable': true},
      {'label': 'gaplama', 'editable': true},
      {'label': 'discount', 'editable': false},
      {'label': 'coupon', 'editable': true},
      {'label': 'description', 'editable': true},
      {'label': 'count', 'editable': false},
      {'label': 'totalchykdajy', 'editable': false},
    ];
  }

  Widget _buildProductList() {
    if (_currentOrder.id == 0) {
      return SizedBox(height: 300, child: Center(child: Text("Order ID is missing".tr)));
    }
    return FutureBuilder<List<ProductModel>>(
      future: OrderService().getOrderProduct(_currentOrder.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return spinKit();
        if (snapshot.hasError) return SizedBox(height: 300, child: Center(child: Text('Error: ${snapshot.error}'.tr)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(height: 300, child: emptyData());
        }

        final products = snapshot.data!;

        return ListView.builder(
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            itemBuilder: (context, index) {
              final productModel = products[index];
              return ProductCard(
                product: productModel.product!,
                externalCount: productModel.count,
                addCounterWidget: false,
                orderView: true,
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldDefinitions = buildOrderDetailsFields(_currentOrder);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backArrow: true,
        centerTitle: true,
        actionIcon: true,
        name: _currentOrder.name,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Column(
            children: List.generate(fieldDefinitions.length, (index) {
              final fieldDef = fieldDefinitions[index];
              return OrderDetailField(
                key: ValueKey(_currentOrder.id.toString() + fieldDef['label']!),
                label: fieldDef['label']!,
                isEditable: fieldDef['editable'] as bool,
                currentOrder: _currentOrder,
                onUpdate: (updatedOrderFromField) {
                  setState(() {
                    _currentOrder = updatedOrderFromField;
                  });
                  orderController.editOrderInList(updatedOrderFromField);
                },
              );
            }),
          ),
          _buildProductList(),
        ],
      ),
    );
  }
}

class OrderDetailField extends StatefulWidget {
  const OrderDetailField({
    super.key,
    required this.label,
    required this.isEditable,
    required this.currentOrder,
    required this.onUpdate,
  });

  final OrderModel currentOrder;
  final bool isEditable;
  final String label;
  final Function(OrderModel) onUpdate;

  @override
  State<OrderDetailField> createState() => _OrderDetailFieldState();
}

class _OrderDetailFieldState extends State<OrderDetailField> {
  late String _displayedValue;

  @override
  void didUpdateWidget(covariant OrderDetailField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentOrder != oldWidget.currentOrder) {
      final newValue = _getValue(widget.label, widget.currentOrder);
      if (_displayedValue != newValue) {
        setState(() {
          _displayedValue = newValue;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _displayedValue = _getValue(widget.label, widget.currentOrder);
  }

  void showEditDialog({
    required BuildContext context,
    required String label,
    required String initialValue,
    required OrderModel currentOrder,
    required Function(OrderModel) onSave,
  }) {
    final TextEditingController controller = TextEditingController();

    if (label == 'status') {
      Get.defaultDialog(
        title: label.tr,
        titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: context.padding.normal,
          child: SingleChildScrollView(
            child: Column(
              children: ListConstants.statusMapping2.map((statusItem) {
                return GestureDetector(
                  onTap: () async {
                    final updatedOrder = currentOrder.copyWith(status: statusItem['sortName']!);
                    _copyUpdatedOrder(label, '', updatedOrder);

                    await onSave(updatedOrder);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: (statusItem['color'] as Color).withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: (statusItem['color'] as Color).withOpacity(0.2),
                    ),
                    child: Text(
                      statusItem['name']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: statusItem['color'] as Color, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
      return;
    }

    if (label == 'discount') {
      controller.text = currentOrder.discount.replaceAll(" % ", "").trim();
    } else if (label == 'phone') {
      final phoneNum = currentOrder.clientDetailModel?.phone ?? '';
      controller.text = phoneNum.startsWith('+993') ? phoneNum.substring(4) : phoneNum;
    } else {
      controller.text = initialValue == 'N/A' ? '' : initialValue;
    }

    Get.defaultDialog(
      title: label.tr,
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return Container(
            padding: context.padding.normal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelName: label.tr,
                  controller: controller,

                  isNumber: ['discount'].contains(label) || (label == 'phone'), // Telefon için de sayısal olabilir
                  readOnly: true,
                  onTap: label == 'date'
                      ? () async {
                          final resultTime = await showDateTimePickerWidget(context: context);
                          if (resultTime != null) {
                            controller.text = DateFormat('yyyy-MM-dd HH:mm').format(resultTime);
                            setStateDialog(() {});
                          }
                        }
                      : null,
                  focusNode: FocusNode(),
                  requestfocusNode: FocusNode(), unFocus: false,
                ),
                SizedBox(height: 10.h),
                AgreeButton(
                  text: 'Change Data'.tr,
                  onTap: () async {
                    final newValueFromInput = controller.text;
                    OrderModel updatedOrderWithNewValue = _copyUpdatedOrder(label, newValueFromInput, currentOrder);
                    await onSave(updatedOrderWithNewValue); // onSave çağrısı
                  },
                ),
                SizedBox(height: 5.h),
                AgreeButton(onTap: () => Get.back(), text: 'Cancel'.tr, showBorder: true),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getValue(String label, OrderModel order) {
    switch (label) {
      case 'status':
        return ListConstants.statusMapping.firstWhere((s) => s['sortName'] == order.status, orElse: () => {'name': 'Unknown'})['name']!;
      case 'date':
        return order.date.toString().substring(0, 16).replaceAll("T", ' ');
      case 'clientName':
        return order.clientDetailModel?.name ?? 'N/A';
      case 'phone':
        final phoneNum = order.clientDetailModel?.phone ?? 'N/A';
        return phoneNum.startsWith('+993') ? phoneNum.substring(4) : phoneNum; // Display without +993
      case 'address':
        return order.clientDetailModel?.address ?? 'N/A';
      case 'gaplama':
        return order.gaplama.toString();
      case 'discount':
        return "${order.discount} % ";
      case 'coupon':
        return order.coupon.toString();
      case 'description':
        return order.description.toString();
      case 'count':
        return order.count.toString();
      case 'totalsum':
        return "${order.totalchykdajy} \$";
      case 'totalchykdajy':
        return "${order.totalsum} \$";
      default:
        return 'Bilinmeyen Alan'.tr;
    }
  }

  OrderModel _copyUpdatedOrder(String label, String value, OrderModel current) {
    ClientDetailModel clientDetails = current.clientDetailModel ?? ClientDetailModel(id: current.clientID, name: '');
    switch (label) {
      case 'date':
        return current.copyWith(date: value.replaceAll(" ", "T"));
      case 'clientName':
        return current.copyWith(clientDetailModel: clientDetails.copyWith(name: value));
      case 'phone':
        final String phoneNumber = value.startsWith('+993') || value.isEmpty ? value : '+993$value';
        return current.copyWith(clientDetailModel: clientDetails.copyWith(phone: phoneNumber));
      case 'address':
        return current.copyWith(clientDetailModel: clientDetails.copyWith(address: value));
      case 'gaplama':
        return current.copyWith(gaplama: value);
      case 'discount':
        return current.copyWith(discount: value); // Modeldeki discount string ise
      case 'coupon':
        return current.copyWith(coupon: value);
      case 'description':
        return current.copyWith(description: value);
      default:
        return current;
    }
  }

  @override
  Widget build(BuildContext context) {
    _displayedValue = _getValue(widget.label, widget.currentOrder);
    return GestureDetector(
      onTap: !widget.isEditable
          ? null
          : () => showEditDialog(
                context: context,
                label: widget.label,
                initialValue: _displayedValue, // Dialog için başlangıç değeri
                currentOrder: widget.currentOrder,
                onSave: (locallyUpdatedOrder) async {
                  await OrderService().editOrderManually(model: locallyUpdatedOrder);
                  widget.onUpdate(locallyUpdatedOrder);
                },
              ),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label == "date" ? widget.label.tr : "${widget.label.tr} :",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                  ),
                  SizedBox(width: 20.w),
                  widget.label == 'status'
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: ListConstants.statusMapping.firstWhere((s) => s['name'] == _displayedValue)['color']?.withOpacity(0.15),
                              border: Border.all(color: ListConstants.statusMapping.firstWhere((s) => s['name'] == _displayedValue)['color']!, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            "${ListConstants.statusMapping.firstWhere((s) => s['name'] == _displayedValue)['name']} ",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: ListConstants.statusMapping.firstWhere((s) => s['name'] == _displayedValue)['color'], fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Expanded(
                          child: Text(
                            _displayedValue, // Her zaman güncel olan _displayedValue'yu kullan
                            textAlign: TextAlign.end,
                            maxLines: 5,
                            style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                        )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Divider(color: Colors.grey.shade200, height: 1),
            )
          ],
        ),
      ),
    );
  }
}
