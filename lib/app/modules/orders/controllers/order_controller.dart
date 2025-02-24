import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';
import 'package:stock_managament_app/constants/customWidget/constants.dart';

import '../../../../constants/customWidget/widgets.dart';
import '../../home/controllers/home_controller.dart';

class OrderController {
  final HomeController homeController = Get.find<HomeController>();
  final SalesController salesController = Get.find<SalesController>();
  submitSale2({required List<TextEditingController> textControllers, required String status, required BuildContext context}) async {
    double sumCost = 0.0;
    double sumPrice = 0.0;
    int productUpdatedCount = 0;
    double discountPrice = textControllers[7].text.isEmpty ? 0.0 : double.parse(textControllers[7].text.replaceAll(',', '.'));

    for (var element in salesController.selectedProductsList) {
      final ProductModel product = element['product'];
      sumCost += double.parse(product.cost.toString().replaceAll(',', '.')) * int.parse(element['count'].toString());
      sumPrice += double.parse(product.sellPrice.toString().replaceAll(',', '.')) * int.parse(element['count'].toString());
      productUpdatedCount = int.parse(product.quantity.toString()) - int.parse(element['count'].toString());
      await FirebaseFirestore.instance.collection('products').doc(product.documentID).update({'quantity': productUpdatedCount});
    }
    log('sumCost: $sumCost');
    log('sumPrice: $sumPrice');
    log('discountPrice: $discountPrice');
    if (discountPrice >= sumPrice || sumPrice - discountPrice < 0) {
      showSnackBar("Error", "A discount price cannot be greater than the sum price.", Colors.red);
      homeController.agreeButton.value = false;
    } else {
      sumPrice -= discountPrice;

      await FirebaseFirestore.instance.collection('sales').add({
        'client_address': textControllers[4].text,
        'client_name': textControllers[3].text,
        'client_number': textControllers[2].text,
        'coupon': textControllers[5].text,
        'date': textControllers[0].text,
        'discount': textControllers[7].text,
        'note': textControllers[6].text,
        'package': textControllers[1].text,
        'status': status,
        'product_count': salesController.selectedProductsList.length.toString(),
        'sum_price': sumPrice.toString(),
        'sum_cost': sumCost.toString(),
      }).then((value) async {
        showSnackBar("orderCreated", "pleaseWait", kPrimaryColor2);
        writeProductToSaleID(value.id);
      });

      // write client to clients column
      findClientOrAddNewOne(textControllers: textControllers, sumPrice: sumPrice.toString());

      Navigator.of(context).pop();
      homeController.agreeButton.value = false;
      showSnackBar("doneTitle", "doneSubtitle", Colors.green);
    }
  }

  findClientOrAddNewOne({required List<TextEditingController> textControllers, required String sumPrice}) {
    showSnackBar("clientSearchTitle", "clientSearchSubtitle", kPrimaryColor1);

    FirebaseFirestore.instance.collection('clients').get().then((value) async {
      bool valueAddClient = false;
      for (var element in value.docs) {
        if (element['number'] == textControllers[2].text) {
          valueAddClient = true;
          double sumClientPrice = double.parse(element['sum_price'].toString()) + double.parse(sumPrice.toString());
          element.reference.update({'sum_price': sumClientPrice, 'order_count': element['order_count'] + 1, 'name': textControllers[3].text});
        }
      }
      if (valueAddClient == false) {
        FirebaseFirestore.instance.collection('clients').add({
          'address': textControllers[4].text,
          'name': textControllers[3].text,
          'number': textControllers[2].text,
          'sum_price': sumPrice.toString(),
          'order_count': 1,
          'date': textControllers[0].text,
        });
      }
    });
  }

  writeProductToSaleID(String id) async {
    for (var element in salesController.selectedProductsList) {
      final ProductModel product = element['product'];
      await FirebaseFirestore.instance.collection('sales').doc(id).collection('products').add({
        'brand': product.brandName.toString(),
        'category': product.category.toString(),
        'cost': product.cost.toString(),
        'gramm': product.gramm.toString(),
        'image': product.image.toString(),
        'date': product.date.toString(),
        'location': product.location.toString(),
        'material': product.material.toString(),
        'name': product.name.toString(),
        'note': product.note.toString(),
        'package': product.package.toString(),
        'quantity': int.parse(element['count'].toString()),
        'sell_price': product.sellPrice.toString(),
      }).then((value) {
        print("++++product added+++++++++++++++++++++++++++++++++++");

        print(value.id);
      });
    }
  }
}
