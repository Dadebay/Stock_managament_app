import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxInt stockInHand = 0.obs;
  RxInt totalProductCount = 0.obs;
  List productList = [];
  changeValues(List productList) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stockInHand.value = 0;
      productList = productList;
      totalProductCount.value = productList.length;
      for (var element in productList) {
        stockInHand.value += int.parse(element['quantity'].toString());
      }
    });
  }
}
