import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/app/modules/orders/controllers/sales_controller.dart';

import '../../../../constants/customWidget/widgets.dart';
import '../../home/controllers/home_controller.dart';

class OrderController {
  final HomeController homeController = Get.find<HomeController>();
  final SalesController salesController = Get.find<SalesController>();
  RxDouble sumCost = 0.0.obs;
  RxDouble sumPrice = 0.0.obs;
  RxString saleID = ''.obs;

  Future<void> submitSale2({required List<TextEditingController> textControllers, required String status}) async {
    // Firestore'da daha önce eklenmiş bir satış olup olmadığını kontrol et
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('sales').where('client_number', isEqualTo: textControllers[2].text).where('client_name', isEqualTo: textControllers[3].text).where('client_address', isEqualTo: textControllers[4].text).get();
    log(snapshot.docs.toString());
    if (snapshot.docs.isNotEmpty) {
      // Eğer satış zaten eklenmişse, mevcut satışı güncelle
      saleID.value = snapshot.docs.first.id;
      await _updateSale(textControllers, status);
      return;
    }

    int productUpdatedCount = 0;
    double discountPrice = textControllers[7].text.isEmpty ? 0.0 : double.parse(textControllers[7].text.replaceAll(',', '.'));

    for (var element in salesController.selectedProductsList) {
      final ProductModel product = element['product'];
      sumCost.value += double.parse(product.cost.toString().replaceAll(',', '.')) * int.parse(element['count'].toString());
      sumPrice.value += double.parse(product.sellPrice.toString().replaceAll(',', '.')) * int.parse(element['count'].toString());
      productUpdatedCount = int.parse(product.quantity.toString()) - int.parse(element['count'].toString());
      await FirebaseFirestore.instance.collection('products').doc(product.documentID).update({'quantity': productUpdatedCount});
    }

    double sumPriceExample = sumPrice.value;
    if (discountPrice >= sumPrice.value || sumPriceExample - discountPrice < 0) {
      showSnackBar("Error", "A discount price cannot be greater than the sum price.", Colors.red);
      homeController.agreeButton.value = false;
    } else {
      sumPrice.value -= discountPrice;

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
      }).then((value) {
        saleID.value = value.id;
        log('saleID: $saleID');
      });

      homeController.agreeButton.value = false;
      salesController.getData();
      showSnackBar("doneTitle", "doneSubtitle", Colors.green);
    }
  }

  Future<void> _updateSale(List<TextEditingController> textControllers, String status) async {
    if (saleID.value.isEmpty) return;

    await FirebaseFirestore.instance.collection('sales').doc(saleID.value).update({
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
    }).then((value) {
      log('Sale updated: ${saleID.value}');
    });
  }

  Future<void> submitClientStep({required List<TextEditingController> textControllers}) async {
    FirebaseFirestore.instance.collection('clients').get().then((value) async {
      bool valueAddClient = false;
      for (var element in value.docs) {
        if (element['number'] == textControllers[2].text) {
          valueAddClient = true;
          double sumClientPrice = double.parse(element['sum_price'].toString()) + double.parse(sumPrice.value.toString());
          element.reference.update({'sum_price': sumClientPrice, 'order_count': element['order_count'] + 1, 'name': textControllers[3].text});
        }
      }
      if (valueAddClient == false) {
        FirebaseFirestore.instance.collection('clients').add({
          'address': textControllers[4].text,
          'name': textControllers[3].text,
          'number': textControllers[2].text,
          'sum_price': sumPrice.value.toString(),
          'order_count': 1,
          'date': textControllers[0].text,
        });
      }
    }).then((value) {
      log('value Cleint step: $value');
    });
  }

  Future<void> submitProductsStep() async {
    log(saleID.value);
    if (saleID.value == '') {
    } else {
      for (var element in salesController.selectedProductsList) {
        final ProductModel product = element['product'];
        await FirebaseFirestore.instance.collection('sales').doc(saleID.value).collection('products').add({
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
          log('value submitProductsStep step: $value');
        });
      }
    }
  }
}
