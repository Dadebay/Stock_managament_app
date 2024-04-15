import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxInt stockInHand = 0.obs;
  RxInt totalProductCount = 0.obs;
  List productList = [];
  void updateStock(int quantity) {
    stockInHand.value += quantity;
  }

  changeValues(List productsList) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productList = productsList;
      totalProductCount.value = productsList.length;
      for (var element in productList) {
        // updateStock(int.parse(element['quantity'].toString()));
        // stockInHand.value += int.parse(element['quantity'].toString());
      }
    });
  }
}
