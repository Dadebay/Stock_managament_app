import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_managament_app/app/data/models/product_model.dart';
import 'package:stock_managament_app/constants/widgets.dart';

class SalesController extends GetxController {
  RxList selectedProductsList = [].obs;
  RxList productList = [].obs;
  RxList productListDocuments = [].obs;

  CollectionReference collectionReference = FirebaseFirestore.instance.collection('sales');
  List<QueryDocumentSnapshot<Object?>> cardsList = [];

  addProduct({required ProductModel product, required int count}) {
    productList.add({'product': product, 'count': count});
  }

  upgradeCount(int id, int count) {
    for (var element in productList) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count.toString();
      }
    }

    productList.refresh();
  }

  decreaseCount(int id, int count) {
    for (var element in productList) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count;
      }
    }

    productList.refresh();
    for (var element in selectedProductsList) {
      final ProductModel product = element['product'];
      if (product.documentID.toString() == id.toString()) {
        element['count'] = count;
      }
    }

    selectedProductsList.refresh();
  }

  addProductMain({required int count, required ProductModel product}) {
    if (selectedProductsList.isEmpty) {
      selectedProductsList.add({'product': product, 'count': count});
    } else {
      bool value = false;

      for (var element in selectedProductsList) {
        final ProductModel productMine = element['product'];
        if (product.documentID.toString() == productMine.documentID) {
          element['count'] = count;
          value = true;
        }
      }
      if (!value) {
        selectedProductsList.add({'product': product, 'count': count});
      }
    }
    selectedProductsList.refresh();
  }

  sumbitSale({required List<TextEditingController> textControllers, required String status}) {
    double sumCost = 0.0;
    double sumPrice = 0.0;
    for (var element in selectedProductsList) {
      final ProductModel product = element['product'];
      sumCost += double.parse(product.cost.toString()).toDouble() * int.parse(element['count'].toString());
      sumPrice += double.parse(product.sellPrice.toString()).toDouble() * int.parse(element['count'].toString());
      int.parse(product.quantity.toString()) - int.parse(element['count'].toString());
      FirebaseFirestore.instance.collection('products').doc(product.documentID).update({'quantity': int.parse(product.quantity.toString()) - int.parse(element['count'].toString())});
    }
    sumPrice -= double.parse(textControllers[7].text.toString());
    if (double.parse(textControllers[7].text.toString()) > sumPrice) {
      showSnackBar("Error", "A discount price cannot be greater than the sum price.", Colors.red);
    } else {
      FirebaseFirestore.instance.collection('sales').add({
        'client_address': textControllers[4].text,
        'client_name': textControllers[3].text,
        'client_number': textControllers[2].text,
        'coupon': textControllers[5].text,
        'date': textControllers[0].text,
        'discount': textControllers[7].text,
        'note': textControllers[6].text,
        'package': textControllers[1].text,
        'status': status,
        'product_count': selectedProductsList.length.toString(),
        'sum_price': sumPrice.toString(),
        'sum_cost': sumCost.toString(),
      }).then((value) {
        for (var element in selectedProductsList) {
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
      });
      Get.back();
      selectedProductsList.clear();
      productList.clear();
      showSnackBar("Done", "Your purchase submitted ", Colors.green);
    }
  }
}
